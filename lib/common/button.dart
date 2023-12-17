import 'package:flutter/material.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/colors.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool disabled;
  final double? radius;
  final TextStyle? textStyle;

  const Button({
    super.key,
    this.text = 'Text here',
    this.disabled = false,
    this.onPressed,
    this.textStyle,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            textStyle: AppTheme.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius ?? 100)),
            elevation: 0),
        onPressed: disabled ? null : onPressed,
        child: Text(text, style: textStyle),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool shadow;

  const CancelButton({
    super.key,
    this.text = 'Text here',
    this.shadow = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: shadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.transparentBlue,
            foregroundColor: AppColors.primary,
            textStyle: AppTheme.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            elevation: 0),
        onPressed: onPressed,
        child: Text(
          text,
        ),
      ),
    );
  }
}

class BorderedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool shadow;
  final TextStyle? textStyle;

  const BorderedButton({
    super.key,
    this.text = 'Text here',
    this.shadow = false,
    this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: shadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.white,
            textStyle: AppTheme.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(100)),
            elevation: 0),
        onPressed: onPressed,
        child: Text(text, style: textStyle),
      ),
    );
  }
}
