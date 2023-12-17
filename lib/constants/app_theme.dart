import 'package:flutter/material.dart';
import 'package:ctrlfirl/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // primaryColor: AppColors.white,
    // colorScheme: const ColorScheme.dark(
    //   primary: AppColors.primary,
    //   brightness: Brightness.dark,
    // ),
    brightness: Brightness.dark,
    useMaterial3: true,
    // appBarTheme: AppBarTheme(
    //     backgroundColor: AppColors.black,
    //     foregroundColor: AppColors.black,
    //     elevation: 0,
    //     scrolledUnderElevation: 0,
    //     centerTitle: false,
    //     titleSpacing: 0,
    //     titleTextStyle: AppTheme.textTheme.headlineMedium?.copyWith(
    //       color: AppColors.white,
    //     )),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(AppColors.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.black.withOpacity(0.3),
      hintStyle: textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w400,
      ),
      focusColor: AppColors.transparentBlue,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.white, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: AppColors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.red, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    ),
    chipTheme: const ChipThemeData(
      selectedColor: AppColors.primary,
    ),
    textTheme: GoogleFonts.urbanistTextTheme(),
  );

  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: AppColors.white,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
  );
}

extension UIThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  AppBarTheme get appBarTheme => Theme.of(this).appBarTheme;
  RadioThemeData get radioTheme => Theme.of(this).radioTheme;
  InputDecorationTheme get inputDecorationTheme =>
      Theme.of(this).inputDecorationTheme;
  ChipThemeData get chipTheme => Theme.of(this).chipTheme;
}
