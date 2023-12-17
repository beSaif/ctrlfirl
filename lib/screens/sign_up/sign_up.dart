import 'package:ctrlfirl/common/button.dart';
import 'package:ctrlfirl/constants/colors.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late FocusNode _phoneFocusNode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _phoneFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: 2.h, right: 2.h, bottom: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                            image: const AssetImage(
                              'assets/graphics/splash.png',
                            ),
                            color: Colors.white,
                            height: 12.h),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Center(
                    child: Text(
                        "Behind every snapshot, a story's waiting. Ask the picture.",
                        textAlign: TextAlign.center,
                        style: AppTheme.textTheme.titleLarge),
                  ),
                ],
              ),
              Column(
                children: [
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Phone number cannot be empty';
                        } else if (value.length != 10) {
                          return 'Phone number must be 10 digits long';
                        }
                        return null;
                      },
                      focusNode: _phoneFocusNode,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTheme.textTheme.bodyMedium,
                      maxLength: 10,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.phone,
                            size: 18,
                            color: AppColors.white,
                          ),
                          counterText: '',
                          border: const OutlineInputBorder(),
                          hintText: 'Enter your phone number',
                          hintStyle: AppTheme.textTheme.labelMedium),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Column(
                    children: [
                      Button(
                        text: 'Continue',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _phoneFocusNode.unfocus();
                            _phoneFocusNode.canRequestFocus = false;
                            String phoneNumber = '+91${_phoneController.text}';
                            Provider.of<AuthController>(context, listen: false)
                                .signUp(phoneNumber);
                            Navigator.pushNamed(context, '/otp', arguments: {
                              'phoneNumber': phoneNumber,
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
