import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:ctrlfirl/services/ocr_screen.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import './.env';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OpenAI.apiKey = OPENAI_API_KEY;
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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatController>(
            create: (context) => ChatController(),
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const OCRScreen(),
        ));
  }
}
