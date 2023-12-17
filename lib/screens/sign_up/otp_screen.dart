import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ctrlfirl/common/button.dart';
import 'package:ctrlfirl/common/loading_overlay.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/routes.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final Map<String, dynamic> argument;

  const OtpScreen({super.key, required this.argument});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late AuthController _authController;
  late List<TextEditingController> _otpController;
  late List<FocusNode> _focusNodes;
  late Timer timer;
  int _currentIndex = 0;
  late String _phoneNumber;
  int _resendTimer = 59;

  @override
  void initState() {
    _authController = Provider.of<AuthController>(context, listen: false);
    _otpController =
        List.generate(6, (index) => TextEditingController(text: ''));
    _focusNodes = List.generate(6, (index) => FocusNode());
    _phoneNumber = widget.argument['phoneNumber'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController.signUp(_phoneNumber);
      _startResendTimer();
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _otpController) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    timer.cancel();
    super.dispose();
  }

  void _onOtpChanged(String value) {
    if (value.length == 1 && _currentIndex != 5) {
      _focusNodes[_currentIndex].unfocus();
      _currentIndex++;
      _focusNodes[_currentIndex].requestFocus();
    } else if (value.isEmpty && _currentIndex != 0) {
      _focusNodes[_currentIndex].unfocus();
      _currentIndex--;
      _focusNodes[_currentIndex].requestFocus();
    }
  }

  void _startResendTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _resendOtp() {
    _authController.signUp(_phoneNumber);
    _startResendTimer();
    setState(() {
      _resendTimer = 60;
    });
  }

  void onPressed() async {
    final otp = _otpController.map((controller) => controller.text).join();

    await _authController.verifyOtp(otp).then((value) async {
      if (value) {
        await _authController.doesUserDocumentExist().then((value) {
          if (value) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.home, (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.phoneNumberVerified, (route) => false);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthController>(
          builder: (context, authControllerConsumer, child) {
        return LoadingOverlay(
          isLoading: authControllerConsumer.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Enter the verification code',
                  style: AppTheme.textTheme.titleMedium),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Column(
                    children: [
                      Center(
                        child: Text(
                          "We just send you a verification code via phone $_phoneNumber",
                          style: AppTheme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 40,
                              child: TextField(
                                maxLines: 1,
                                maxLength: 1,
                                autofocus: index == 0,
                                controller: _otpController[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: AppTheme.textTheme.displayMedium,
                                decoration: InputDecoration(
                                  hintStyle:
                                      AppTheme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                                  hintText: "${index + 1}",
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  fillColor: Colors.transparent,
                                  enabledBorder: const UnderlineInputBorder(),
                                  border: const UnderlineInputBorder(),
                                  counterText: '',
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: _onOtpChanged,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _resendTimer > 0 ? null : _resendOtp,
                        child: Text(
                          _resendTimer > 0
                              ? 'Resend code in $_resendTimer seconds'
                              : 'Resend code',
                          style: TextStyle(
                            color: _resendTimer > 0
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Button(
                    text: 'Submit Code',
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
