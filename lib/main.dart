import 'package:ctrlfirl/models/recognition_response.dart';
import 'package:ctrlfirl/models/test_model.dart';
import 'package:ctrlfirl/recognizer/interface/text_recognizer.dart';
import 'package:ctrlfirl/recognizer/mlkit_text_recognizer.dart';
import 'package:ctrlfirl/recognizer/tesseract_text_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late ImagePicker _picker;
  RecognitionResponse? _response;
  late ITextRecognizer _recognizer;

  XFile? image;
  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();

    /// Can be [MLKitTextRecognizer] or [TesseractTextRecognizer]
    // _recognizer = MLKitTextRecognizer();
    _recognizer = TesseractTextRecognizer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    await pickImage();
                    processImage(image!.path);
                  },
                  child: const Text('Hello World!')),
            ],
          ),
        ),
      ),
    );
  }

  pickImage() async {
    // Pick an image.
    final XFile? _image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = _image;
    });
  }

  void processImage(String imgPath) async {
    final recognizedText = await _recognizer.processImage(imgPath);
    setState(() {
      _response = RecognitionResponse(
        imgPath: imgPath,
        recognizedText: recognizedText,
      );
    });
    debugPrint(recognizedText);
  }
}
