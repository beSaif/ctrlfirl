import 'package:ctrlfirl/common/button.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/routes.dart';
import 'package:ctrlfirl/services/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PhoneNumberVerifiedScreen extends StatefulWidget {
  const PhoneNumberVerifiedScreen({super.key});

  @override
  State<PhoneNumberVerifiedScreen> createState() =>
      _PhoneNumberVerifiedScreenState();
}

class _PhoneNumberVerifiedScreenState extends State<PhoneNumberVerifiedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
              image:
                  const AssetImage('assets/graphics/success_splash_image.png'),
              height: 30.h),
          SizedBox(height: 5.h),
          Text('Phone Number Verified',
              style: AppTheme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          Text(
            'Congratulations, your phone number has been verified. You can start using the app',
            style: AppTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Button(
            text: 'Continue',
            onPressed: () {
              FirebaseHelper().doesUserDocumentExist().then((value) {
                if (value) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.home, (route) => false);
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.fillYourProfile, (route) => false);
                }
              });
            },
          )
        ],
      ),
    )));
  }
}
