import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ctrlfirl/constants/colors.dart';
import 'package:ctrlfirl/constants/routes.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late bool isFirstLaunch;
  Timer _timer = Timer(Duration.zero, () {});
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Future<bool> checkIfFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      // Do something on first launch
      await prefs.setBool('isFirstLaunch', false);
    }
    debugPrint('isFirstLaunch: $isFirstLaunch');
    return isFirstLaunch;
  }

  startTimer() async {
    checkIfFirstLaunch().then((isFirstLaunchValue) {
      setState(() {
        isFirstLaunch = isFirstLaunchValue;
      });
      var duration = const Duration(seconds: 2);
      _timer = Timer(duration, () {
        AuthController authController =
            Provider.of<AuthController>(context, listen: false);

        _getInitialRoute(context, authController).then((value) async {
          Navigator.restorablePushNamedAndRemoveUntil(
            context,
            value,
            (route) => false,
          );
        });
      });
    });
  }

  Future<String> _getInitialRoute(
      BuildContext context, AuthController authController) async {
    if (authController.isLoggedIn()) {
      debugPrint('User is signed in');
      // if user document does not exist but is logged in, redirect to fill your profile screen
      if (!await authController.doesUserDocumentExist()) {
        debugPrint('User document does not exist');
        return Routes.fillYourProfile;
      }
      return Routes.home;
    } else {
      debugPrint('User is not signed in');
      // User is not signed in, redirect to sign in screen
      return Routes.signUp;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/graphics/splash.png',
                      height: 27.h,
                    ),
                  ],
                ),
                const SpinKitCircle(
                  //itemBuilder: (context) {},
                  color: AppColors.primary,
                )
              ]),
        ),
      ),
    );
  }
}
