# GardenGuard

GardenGuard is a Flutter app that predicts plant leaf diseases from images using an ONNX model.

This repository contains three parts:
- Model training pipeline in [training_files/train.py](training_files/train.py)
- Flutter app in [garden_gaurd_app](garden_gaurd_app)
- Field Images for Real-World Testing

## Prerequisites

- Python 3.10+ (for training)
- Flutter SDK (stable channel)
- A device target for Flutter (Windows desktop, Android emulator, or physical Android device)
- Optional: Kaggle API credentials if you want automatic dataset download

## Stage 1: Training (Python)

Use this stage if you want to retrain the classifier from PlantVillage data.

1. Open a terminal in the repo root.
2. Install Python dependencies:

```bash
pip install -r training_files/requirements.txt
```

3. Configure Kaggle credentials (only needed when downloading dataset automatically).

Set environment variables

```bash
export KAGGLE_USERNAME="your_username"
export KAGGLE_KEY="your_api_key"
```

PowerShell equivalent:

```powershell
$env:KAGGLE_USERNAME="your_username"
$env:KAGGLE_KEY="your_api_key"
```

4. Run training:

```bash
python training_files/train.py
```

If the dataset is already present, skip download:

```bash
python training_files/train.py --skip-download
```

### Training outputs

The script writes:
- model_full.pth
- model_package.zip

Note: the Flutter app currently loads an ONNX file at [garden_gaurd/assets/models/plant_model.onnx](garden_gaurd/assets/models/plant_model.onnx). Retraining in PyTorch does not automatically replace that ONNX model.

## Stage 2: Running Flutter

This stage runs the app with the bundled ONNX model.

1. Move into the app directory:

```bash
cd garden_gaurd
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Confirm available devices:

```bash
flutter devices
```

4. Run the app:

```bash
flutter run
```

## Quick Troubleshooting

- If training fails with Kaggle authentication errors, re-check Kaggle credentials.
- If Flutter cannot find the model, verify [garden_gaurd/assets/models/plant_model.onnx](garden_gaurd/assets/models/plant_model.onnx) exists and that [garden_gaurd/pubspec.yaml](garden_gaurd/pubspec.yaml) includes it under assets.
- If image picking fails on Android, ensure device permissions are granted.