import 'package:ctrlfirl/screens/chat_screen.dart';
import 'package:ctrlfirl/screens/home_screen.dart';
import 'package:ctrlfirl/screens/sign_up/phone_number_verified_screen.dart';
import 'package:ctrlfirl/splash_screen.dart';

import 'package:flutter/material.dart';

import 'package:ctrlfirl/screens/sign_up/fill_your_profile_screen.dart';
import 'package:ctrlfirl/screens/sign_up/otp_screen.dart';
import 'package:ctrlfirl/screens/sign_up/sign_up.dart';

class Routes {
  static const String splash = '/splash';
  // static const String onboarding = '/onboarding';
  // static const String welcome = '/welcome';
  static const String signUp = '/signUp';
  static const String otp = '/otp';
  static const String phoneNumberVerified = '/phoneNumberVerified';
  static const String fillYourProfile = '/fillYourProfile';
  static const String home = '/home';
  static const String bookAppointment = '/bookAppointment';
  static const String myAppointments = '/myAppointments';
  static const String noticeBoard = '/noticeBoard';
  static const String aboutUs = '/aboutUs';
  static const String contactDetail = '/contactDetail';
  static const String chats = '/chats';

  static final Map<String, WidgetBuilder> routes = {
    splash: (BuildContext context) => const SplashScreen(),
    signUp: (BuildContext context) => const SignUpScreen(),
    otp: (BuildContext context) => OtpScreen(
          argument: ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>,
        ),
    phoneNumberVerified: (BuildContext context) =>
        const PhoneNumberVerifiedScreen(),
    fillYourProfile: (BuildContext context) => const FillYourProfileScreen(),
    home: (BuildContext context) => const HomeScreen(),
    chats: (BuildContext context) => const ChatScreen(),
  };
}
