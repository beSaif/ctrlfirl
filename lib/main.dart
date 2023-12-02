import 'package:ctrlfirl/models/test_model.dart';
import 'package:ctrlfirl/services/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseHelper().createDocument(
                      TestModel(id: '1'),
                    );
                  },
                  child: const Text('Hello World!')),
            ],
          ),
        ),
      ),
    );
  }
}
