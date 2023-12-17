import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/routes.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:ctrlfirl/screens/home_screen.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
          ),
          ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController(),
          )
        ],
        child:
            Consumer<AuthController>(builder: (context, authController, child) {
          return ResponsiveSizer(builder: (context, orientation, screenType) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              initialRoute: Routes.splash,
              routes: Routes.routes,
            );
          });
        }));
  }
}
