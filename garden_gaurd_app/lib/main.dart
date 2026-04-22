import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onnxruntime/onnxruntime.dart';

import 'classes.dart';
import 'remedies.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GardenGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 22, 78, 24),
        ),
      ),
      home: const MyHomePage(title: 'GardenGuard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Inference state.
  bool modelLoaded = false;
  late OrtSession session;

  // UI state.
  String prediction = "Loading model...";
  Map<String, String>? remedyInfo;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Color getCropColor(String? plantName) {
    // Maps detected crop names to display accents in the result header.
    switch (plantName) {
      case 'Apple':
        return Colors.red;
      case 'Peach':
        return Colors.orange;
      case 'Tomato':
        return Colors.redAccent;
      case 'Grape':
        return Colors.purple;
      case 'Potato':
        return Colors.brown;
      case 'Strawberry':
        return Colors.red;
      case 'Corn':
        return Colors.yellow.shade700;
      case 'Orange':
        return Colors.orange;
      case 'Bell Pepper':
        return Colors.green;
      case 'Cherry':
        return Colors.redAccent;
      case 'Blueberry':
        return Colors.blue;
      case 'Raspberry':
        return Colors.pink;
      case 'Soybean':
        return Colors.lightGreen;
      case 'Squash':
        return Colors.deepOrange;
      default:
        return Colors.green;
    }
  }

  Future<void> loadModel() async {
    final rawAsset = await rootBundle.load('assets/models/plant_model.onnx');
    final bytes = rawAsset.buffer.asUint8List();
    final options = OrtSessionOptions();

    session = OrtSession.fromBuffer(bytes, options);

    setState(() {
      modelLoaded = true;
      prediction = "Model loaded. Press analyze.";
    });
  }

  Future<void> pickImageFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;

    setState(() {
      _selectedImage = File(result.files.single.path!);
      prediction = "Analysing...";
    });
    final stopwatch = Stopwatch()..start();
    await analyzeImage(_selectedImage!);
    stopwatch.stop();
    print("Total UI-to-Result Latency: ${stopwatch.elapsedMilliseconds}ms");
  }

  Future<void> pickImageFromCamera(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        prediction = "Analysing...";
      });

      await analyzeImage(_selectedImage!);
    } catch (e) {
      setState(() => prediction = "Camera error: $e");
    }
  }

  Future<void> analyzeImage(File imageFile) async {
    if (!modelLoaded) {
      setState(() => prediction = "Model still loading...");
      return;
    }

    try {
      setState(() {
        prediction = "Analysing...";
        remedyInfo = null;
      });

      final tensor = await preprocessImage(imageFile);
      final result = await runModel(tensor);

      setState(() {
        prediction = result;
        remedyInfo = REMEDIATION_DATA[result];
      });
    } catch (e) {
      setState(() {
        prediction = "Analysis error: $e";
        remedyInfo = null;
      });
    }
  }

  Future<Float32List> preprocessImage(File imageFile) async {
    final Uint8List rawBytes = await imageFile.readAsBytes();

    final codec = await instantiateImageCodec(
      rawBytes,
      targetWidth: 224,
      targetHeight: 224,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final data = await image.toByteData(format: ImageByteFormat.rawRgba);
    final rgb = data!.buffer.asUint8List();

    // ONNX model expects channel-first tensor shape [1, 3, 224, 224].
    var tensor = Float32List(3 * 224 * 224);
    for (int i = 0; i < 224 * 224; i++) {
      int idx = i * 4;

      tensor[i] = ((rgb[idx] / 255.0) - 0.485) / 0.229;
      tensor[i + 224 * 224] = ((rgb[idx + 1] / 255.0) - 0.456) / 0.224;
      tensor[i + 224 * 224 * 2] = ((rgb[idx + 2] / 255.0) - 0.406) / 0.225;
    }

    return tensor;
  }

  Future<String> runModel(Float32List inputTensor) async {
    final inputTensorObj = OrtValueTensor.createTensorWithDataList(
      inputTensor,
      [1, 3, 224, 224],
    );

    final runOptions = OrtRunOptions();

    final outputs = await session.run(
      runOptions,
      {'input': inputTensorObj},
      ['output'],
    );

    final outputTensor = outputs[0] as OrtValueTensor;

    final raw = outputTensor.value as List<List<double>>;
    final scores = raw[0];

    int maxIndex = 0;
    double maxScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    return CLASS_NAMES[maxIndex];
  }

  @override
  Widget build(BuildContext context) {
    final bool isWindows = Platform.isWindows;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shows selected photo, or placeholder icon if none selected yet
              _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        width: 280,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.local_florist,
                      size: 100,
                      color: Colors.green,
                    ),

              const SizedBox(height: 30),

              if (remedyInfo != null) ...[
                Text(
                  remedyInfo!['Plant'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: getCropColor(remedyInfo!['Plant']),
                    letterSpacing: 1.2,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  remedyInfo!['title'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ] else ...[
                Text(
                  prediction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (remedyInfo != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            remedyInfo!['title'] ?? 'Unknown Condition',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Plant: ${remedyInfo!['Plant'] ?? 'Unknown'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Risk: ${remedyInfo!['risk'] ?? 'Unknown'}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Recommended Action",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            remedyInfo!['advice'] ?? 'No advice available.',
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Windows: file browser button
              if (isWindows)
                ElevatedButton.icon(
                  onPressed: modelLoaded ? pickImageFromFile : null,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Choose Leaf Photo"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),

              // Android: camera + gallery buttons
              if (!isWindows) ...[
                ElevatedButton.icon(
                  onPressed: modelLoaded
                      ? () => pickImageFromCamera(ImageSource.camera)
                      : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: modelLoaded
                      ? () => pickImageFromCamera(ImageSource.gallery)
                      : null,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Choose from Gallery"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
              ],

              // Re-analyse button appears only after a photo is selected
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => analyzeImage(_selectedImage!),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Re-analyse"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
