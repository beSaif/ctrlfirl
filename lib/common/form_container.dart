import 'package:flutter/material.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/colors.dart';

class FormContainer extends StatelessWidget {
  final Widget child;
  // validator
  final String? Function(String?)? validator;
  final String? initialValue;
  const FormContainer(
      {super.key, required this.child, this.validator, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return FormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: initialValue != null ? Key(initialValue!) : null,
        validator: validator,
        initialValue: initialValue,
        builder: (field) {
          return Column(
            children: [
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: field.hasError
                          ? AppColors.red
                          : field.isValid
                              ? AppColors.white
                              : AppColors.black,
                      width: 1),
                ),
                child: child,
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Text(
                          field.errorText ?? '',
                          style: AppTheme.textTheme.labelSmall!.copyWith(
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        });
  }
}
