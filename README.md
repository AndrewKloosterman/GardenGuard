# GardenGuard

GardenGuard is a plant disease detection project with a Colab-based training notebook and a Flutter app for inference.

## Demo Video

Click the image below to watch the demo:

[![Garden Guard Demo](https://img.youtube.com/vi/i9WkSNy3jGY/hqdefault.jpg)](https://youtube.com/shorts/i9WkSNy3jGY)

## Repository Structure

```text
.
├── training_files/
│   └── GardenGuard_Training.ipynb   # Model training & ONNX export pipeline
├── garden_guard_app/                # Flutter Project Root
│   ├── assets/
│   │   └── models/
│   │       └── plant_model.onnx     # Deployed production model
│   ├── lib/                         # Application source code
│   └── pubspec.yaml                 # Asset & dependency declarations
├── field_test_images.zip            # Manually collected field validation data
└── README.md
```

## Code Structure

- [training_files/GardenGaurd_Training.ipynb](training_files/GardenGaurd_Training.ipynb) contains the training workflow, including dataset download, preprocessing, model training, and model packaging.
- [garden_gaurd_app](garden_gaurd_app) contains the Flutter application that loads the ONNX model and performs predictions.
- [garden_gaurd_app/assets/models/plant_model.onnx](garden_gaurd_app/assets/models/plant_model.onnx) is the model bundled with the app.
- [garden_gaurd_app/pubspec.yaml](garden_gaurd_app/pubspec.yaml) declares the Flutter dependencies and registers the model asset.


## Dependencies

### Colab Training Notebook

The notebook expects these Python packages and services:

- `kaggle`
- `torch`
- `torchvision`
- `tqdm`
- `google.colab`
- Kaggle API credentials for dataset access

### Flutter App

The Flutter app uses the following packages from [garden_gaurd_app/pubspec.yaml](garden_gaurd_app/pubspec.yaml):

- `flutter`
- `cupertino_icons`
- `file_picker`
- `image_picker`
- `onnxruntime`

## Run In Google Colab

Use Google Colab to run the training notebook instead of a local Python environment.

1. Open [training_files/GardenGaurd_Training.ipynb](training_files/GardenGaurd_Training.ipynb) in Google Colab.
2. If needed, upload the notebook to Google Drive first, then open it from Colab.
3. In Colab, choose `Runtime` > `Change runtime type`.
4. Set `Hardware accelerator` to `GPU` and select `T4 GPU` if it is available.
5. Enter your Kaggle username and key in the first notebook cell.
6. Run the notebook cells from top to bottom.

### What the notebook does automatically

- Installs the Kaggle CLI inside Colab.
- Downloads the PlantVillage dataset from Kaggle.
- Unzips the dataset into the working directory.
- Trains a MobileNetV2-based classifier.
- Packages the trained model into `model_package.zip`.
- Mounts Google Drive so outputs can be saved from the Colab session.

### Data and model access

- The PlantVillage dataset is downloaded automatically by the notebook from Kaggle.
- The app model is already bundled in the repository at [garden_gaurd_app/assets/models/plant_model.onnx](garden_gaurd_app/assets/models/plant_model.onnx), so no extra model download is needed to run the app.
- If you want to use your own model trained in Colab, copy the new ONNX model into [garden_gaurd_app/assets/models/plant_model.onnx](garden_gaurd_app/assets/models/plant_model.onnx) before running the Flutter app.

## Install Flutter

Install Flutter before running the app in [garden_gaurd_app](garden_gaurd_app).

1. Download the Flutter SDK from https://docs.flutter.dev/get-started/install.
2. Follow the instructions for your operating system (Windows, macOS, or Linux).
3. Add the Flutter `bin` folder to your system `PATH`.
4. Open a new terminal and verify installation:

```bash
flutter --version
flutter doctor
```

5. Resolve all issues reported by `flutter doctor`, especially:
- Android toolchain setup (Android Studio + SDK)
- Connected device setup (emulator or physical device)
- License acceptance with `flutter doctor --android-licenses` (Android only)

### Windows Quick Setup

1. Download the Flutter SDK zip for Windows.
2. Extract it to a stable location such as `C:\src\flutter`.
3. Add `C:\src\flutter\bin` to the user `Path` environment variable.
4. Install Android Studio and the Android SDK.
5. In Android Studio, install the Flutter and Dart plugins.
6. Run `flutter doctor` again and fix any remaining warnings.

## Run The Flutter App

If you want to test the mobile or desktop app after training, use the Flutter project in [garden_gaurd_app](garden_gaurd_app).

1. Open a terminal in [garden_gaurd_app](garden_gaurd_app).
2. Run `flutter pub get`.
3. Check available devices with `flutter devices`.
4. Launch the app with `flutter run`.

## Provenance

No prior code was used for this project.

- The repository source is original to this project.
- No external repositories were copied or adapted into the codebase.
- Third-party packages are used only as dependencies, not as copied source code.

## Troubleshooting

- If Kaggle download fails in Colab, verify the Kaggle username and key values entered in the notebook.
- If Colab runs out of memory, restart the runtime and try again with the T4 GPU runtime selected.
- If the Flutter app cannot find the model, confirm [garden_gaurd_app/assets/models/plant_model.onnx](garden_gaurd_app/assets/models/plant_model.onnx) exists and is listed in [garden_gaurd_app/pubspec.yaml](garden_gaurd_app/pubspec.yaml).