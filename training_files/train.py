"""
PlantVillage Disease Classifier - Training Script
Uses MobileNetV2 with transfer learning on the PlantVillage dataset.

Usage:
    python train.py
    python train.py --data-dir path/to/color --epochs-warmup 3 --epochs-finetune 7

Requirements:
    pip install -r requirements.txt

Dataset:
    Downloaded automatically from Kaggle. Set KAGGLE_USERNAME and KAGGLE_KEY
    as environment variables, or create a kaggle.json file at ~/.kaggle/kaggle.json.
    See README.md for details.
"""

import os
import argparse
import zipfile

import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, models, transforms as T
from torch.utils.data import DataLoader, random_split
from tqdm import tqdm


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

def parse_args():
    """Parse command-line options for training and dataset handling."""
    parser = argparse.ArgumentParser(description="Train a MobileNetV2 plant disease classifier.")
    parser.add_argument("--data-dir", default="dataset/plantvillage dataset/color",
                        help="Path to the PlantVillage 'color' folder (default: %(default)s)")
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--epochs-warmup", type=int, default=3,
                        help="Epochs to train only the classifier head (default: 3)")
    parser.add_argument("--epochs-finetune", type=int, default=7,
                        help="Epochs to fine-tune with top MobileNetV2 layers unfrozen (default: 7)")
    parser.add_argument("--lr", type=float, default=0.001)
    parser.add_argument("--output", default="model_full.pth",
                        help="Where to save the trained model weights (default: %(default)s)")
    parser.add_argument("--skip-download", action="store_true",
                        help="Skip Kaggle dataset download (use if dataset already exists)")
    return parser.parse_args()


# ---------------------------------------------------------------------------
# Dataset download
# ---------------------------------------------------------------------------

def download_dataset():
    """Download and unzip the PlantVillage dataset from Kaggle."""
    try:
        import kaggle  # noqa: F401  (imported for side-effect: validates credentials)
    except ImportError:
        raise SystemExit("kaggle package not found. Run: pip install kaggle")

    username = os.environ.get("KAGGLE_USERNAME")
    key = os.environ.get("KAGGLE_KEY")
    if username and key:
        os.environ["KAGGLE_USERNAME"] = username
        os.environ["KAGGLE_KEY"] = key

    print("Downloading PlantVillage dataset from Kaggle...")
    os.system("kaggle datasets download -d abdallahalidev/plantvillage-dataset")
    print("Unzipping...")
    os.system("unzip -q plantvillage-dataset.zip -d dataset")
    print("Dataset ready.")


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def get_dataloaders(data_dir: str, batch_size: int):
    """Build train/validation dataloaders and return class names from ImageFolder."""
    # Input normalization matches ImageNet stats used by pretrained MobileNetV2.
    transform = T.Compose([
        T.Resize((224, 224)),
        T.RandomHorizontalFlip(p=0.5),
        T.RandomResizedCrop(224, scale=(0.8, 1.0)),
        T.RandomRotation(15),
        T.ColorJitter(brightness=0.2),
        T.ToTensor(),
        T.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    full_dataset = datasets.ImageFolder(root=data_dir, transform=transform)
    train_size = int(0.8 * len(full_dataset))
    val_size = len(full_dataset) - train_size
    train_data, val_data = random_split(full_dataset, [train_size, val_size])

    train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True, num_workers=2, pin_memory=True)
    val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False, num_workers=2, pin_memory=True)

    return train_loader, val_loader, full_dataset.classes


# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------

def build_model(num_classes: int, device: torch.device) -> nn.Module:
    """Load pretrained MobileNetV2, freeze backbone, and replace classifier head."""
    model = models.mobilenet_v2(weights="DEFAULT")
    for param in model.parameters():
        param.requires_grad = False
    model.classifier[1] = nn.Linear(model.last_channel, num_classes)
    return model.to(device)


# ---------------------------------------------------------------------------
# Training helpers
# ---------------------------------------------------------------------------

def train_epoch(model, loader, optimizer, criterion, device):
    """Run one training epoch and return mean batch loss."""
    model.train()
    running_loss = 0.0
    for inputs, labels in tqdm(loader, desc="Training", leave=False):
        inputs, labels = inputs.to(device), labels.to(device)
        optimizer.zero_grad()
        loss = criterion(model(inputs), labels)
        loss.backward()
        optimizer.step()
        running_loss += loss.item()
    return running_loss / len(loader)


def validate(model, loader, device):
    """Evaluate model on validation data and return accuracy percentage."""
    model.eval()
    correct, total = 0, 0
    with torch.no_grad():
        for inputs, labels in loader:
            inputs, labels = inputs.to(device), labels.to(device)
            _, predicted = torch.max(model(inputs), 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    return 100 * correct / total


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    """Train in two phases (warm-up + fine-tune) and export model artifacts."""
    args = parse_args()
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    # Download dataset if needed
    if not args.skip_download:
        if not os.path.exists(args.data_dir):
            download_dataset()
        else:
            print(f"Dataset folder '{args.data_dir}' already exists, skipping download.")
            print("Pass --skip-download to suppress this check.")

    # Data
    train_loader, val_loader, class_names = get_dataloaders(args.data_dir, args.batch_size)
    print(f"Found {len(class_names)} classes. Example: {class_names[:3]}")

    # Model
    model = build_model(len(class_names), device)
    print(f"MobileNetV2 loaded → {device}")

    criterion = nn.CrossEntropyLoss()
    scheduler_kwargs = dict(mode="max", factor=0.5, patience=2)

    # ------------------------------------------------------------------
    # Phase 1: Warm-up — train classifier head only
    # ------------------------------------------------------------------
    print(f"\n--- Warm-up phase ({args.epochs_warmup} epochs) ---")
    # Warm-up only updates the new classifier layer.
    optimizer = optim.Adam(model.classifier[1].parameters(), lr=args.lr)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, **scheduler_kwargs)

    for epoch in range(args.epochs_warmup):
        loss = train_epoch(model, train_loader, optimizer, criterion, device)
        acc = validate(model, val_loader, device)
        print(f"  Epoch {epoch+1}/{args.epochs_warmup} | Loss: {loss:.4f} | Val Acc: {acc:.2f}%")
        scheduler.step(acc)

    # ------------------------------------------------------------------
    # Phase 2: Fine-tune — unfreeze top MobileNetV2 blocks
    # ------------------------------------------------------------------
    print(f"\n--- Fine-tune phase ({args.epochs_finetune} epochs) ---")
    # Unfreezing later feature blocks helps adapt pretrained features to plant classes.
    for param in model.features[14:].parameters():
        param.requires_grad = True

    optimizer = optim.Adam(model.parameters(), lr=args.lr)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, **scheduler_kwargs)

    for epoch in range(args.epochs_finetune):
        loss = train_epoch(model, train_loader, optimizer, criterion, device)
        acc = validate(model, val_loader, device)
        print(f"  Epoch {epoch+1}/{args.epochs_finetune} | Loss: {loss:.4f} | Val Acc: {acc:.2f}%")
        scheduler.step(acc)

    # ------------------------------------------------------------------
    # Save
    # ------------------------------------------------------------------
    torch.save(model.state_dict(), args.output)
    print(f"\nModel weights saved → {args.output}")

    zip_path = "model_package.zip"
    with zipfile.ZipFile(zip_path, "w") as zf:
        zf.write(args.output)
    print(f"Model packaged   → {zip_path}")


if __name__ == "__main__":
    main()