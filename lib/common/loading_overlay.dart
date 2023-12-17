import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ctrlfirl/constants/colors.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay(
      {super.key, required this.child, required this.isLoading});

  final Widget child;
  final bool isLoading;

  static LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<LoadingOverlayState>()!;
  }

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.isLoading;

    return Stack(
      children: [
        widget.child,
        if (isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (isLoading)
          const Center(
            child: SpinKitCircle(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
