# GardenGuard

GardenGuard is a plant disease detection project with a Colab-based training notebook and a Flutter app for inference.

## Demo Video

Click the image below to watch the demo!

[![Garden Guard Demo](https://img.youtube.com/vi/42Z146qCd5c/maxresdefault.jpg)](https://www.youtube.com/shorts/42Z146qCd5c)


## Quick Start

1. Train the model in Google Colab using [training_files/GardenGuard_Training.ipynb](training_files/GardenGuard_Training.ipynb).
2. Download `plant_model.onnx` from Colab and place it in [garden_guard_app/assets/models/plant_model.onnx](garden_guard_app/assets/models/plant_model.onnx) if you want to use your own model.
3. Install Flutter using the [official setup guide](https://docs.flutter.dev/get-started/install).
4. Open [garden_guard_app](garden_guard_app) and run `flutter pub get`.
5. Launch the app with `flutter run`.

## Repository Structure

```text
.
├── training_files/
│   ├── field_test_images.zip        # Manually collected field validation data
│   └── GardenGuard_Training.ipynb   # Model training & ONNX export pipeline
├── garden_guard_app/                # Flutter Project Root
│   ├── assets/
│   │   └── models/
│   │       └── plant_model.onnx     # Deployed production model
│   ├── lib/                         # Application source code
│   └── pubspec.yaml                 # Asset & dependency declarations
└── README.md
```

## Code Structure and Files of Interest

- [training_files/field_test_images.zip](training_files/field_test_images.zip) contains sample field images for manual testing.
- [training_files/GardenGuard_Training.ipynb](training_files/GardenGuard_Training.ipynb) contains the training workflow, including dataset download, preprocessing, model training, and ONNX export.
- [garden_guard_app](garden_guard_app) contains the Flutter application that loads the ONNX model and performs predictions.
- [garden_guard_app/assets/models/plant_model.onnx](garden_guard_app/assets/models/plant_model.onnx) is the model bundled with the app.
- [garden_guard_app/lib/main.dart](garden_guard_app/lib/main.dart) contains the app entry point and main source code.
- [garden_guard_app/pubspec.yaml](garden_guard_app/pubspec.yaml) declares the Flutter dependencies and registers the model asset.


## Dependencies

### Colab Training Notebook

The notebook expects these Python packages and services:

- `kaggle`
- `torch`
- `torchvision`
- `tqdm`
- `google.colab`
- `onnx`
- Kaggle API credentials for dataset access

### Flutter App

The Flutter app uses the following packages from [garden_guard_app/pubspec.yaml](garden_guard_app/pubspec.yaml):

- `flutter`
- `cupertino_icons`
- `file_picker`
- `image_picker`
- `onnxruntime`

## Run In Google Colab

Use Google Colab to run the training notebook.

1. Open [training_files/GardenGuard_Training.ipynb](training_files/GardenGuard_Training.ipynb) in Google Colab.
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
- Exports the trained model to `plant_model.onnx`.
- Downloads the ONNX file directly to your computer from Colab.

### Data and model access

- The PlantVillage dataset is downloaded automatically by the notebook from Kaggle.
- After the Google Colab workflow exports and downloads `plant_model.onnx` to your computer, you can use your own trained model in the app!
- If you want to keep the included model, use the existing file at [garden_guard_app/assets/models/plant_model.onnx](garden_guard_app/assets/models/plant_model.onnx).
- If you want to use your own model, replace [garden_guard_app/assets/models/plant_model.onnx](garden_guard_app/assets/models/plant_model.onnx) with the ONNX file downloaded from Colab.
- Keep the filename exactly `plant_model.onnx` so the app can load it correctly.
- Once your model file is in place, the next step is installing Flutter.

## Install Flutter

Install Flutter before running the app in [garden_guard_app](garden_guard_app).

1. Download the Flutter SDK from [the official Flutter installation guide](https://docs.flutter.dev/get-started/install).
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

If you want to test the app after training, use the Flutter project in [garden_guard_app](garden_guard_app).  
For this demo, use Windows (or Windows emulator) or an Android emulator. Physical Android devices also work when connected via USB with Developer Mode and USB debugging enabled. Linux is not officially supported for the app workflow.

1. Open a terminal in [garden_guard_app](garden_guard_app).
2. Run `flutter pub get`.
3. Check available devices with `flutter devices`.
4. Launch the app with `flutter run -d <device-id>`.


## Run Field Tests
To evaluate the app on real-world images, use the manually collected samples in [training_files/field_test_images.zip](training_files/field_test_images.zip). These images were chosen to better reflect field conditions than lab-curated data.

1. Extract [training_files/field_test_images.zip](training_files/field_test_images.zip) into a folder on your computer.
2. Start the app with `flutter run` and wait for it to open on your selected device.
3. In the app, tap or click `Choose Leaf Photo`.
4. Select one of the extracted field test images.
5. Compare the app prediction with the image filename or the expected plant disease label.
6. Repeat the test with several images to see how the model performs across different real-world samples!

## Provenance

No prior code was used for this project.

- The repository source is original to this project.
- No external repositories were copied or adapted into the codebase.
- Third-party packages are used only as dependencies, not as copied source code.

## Troubleshooting

- If Kaggle download fails in Colab, verify the Kaggle username and key values entered in the notebook.
- If Colab runs out of memory, restart the runtime and try again with the T4 GPU runtime selected.
- If the Flutter app cannot find the model, confirm [garden_guard_app/assets/models/plant_model.onnx](garden_guard_app/assets/models/plant_model.onnx) exists and is listed in [garden_guard_app/pubspec.yaml](garden_guard_app/pubspec.yaml).