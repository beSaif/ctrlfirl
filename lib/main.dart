import 'package:ctrlfirl/chat_screen.dart';
import 'package:ctrlfirl/models/recognition_response.dart';
import 'package:ctrlfirl/ocr_screen.dart';
import 'package:ctrlfirl/recognizer/interface/text_recognizer.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const OCRScreen(),
    );
  }
}
