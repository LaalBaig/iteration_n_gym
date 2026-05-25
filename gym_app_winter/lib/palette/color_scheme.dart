import 'package:flutter/material.dart';

extension AppColorExtension on BuildContext {
  AppColors get colors => AppColors(this);
}

class AppColors {
  final BuildContext context;
  AppColors(this.context);

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // Brand Colors
  Color get brandPrimary => const Color.fromARGB(255, 0, 0, 0); // Black / Dark Gray primary accent
  Color get brandAccent => const Color(0xFF424242); // Dark Gray secondary accent
  
  // Professional Neutrals
  Color get parchment => const Color(0xFFFFFFFF); // Main Background (reverted to plain white)
  Color get ivory => const Color(0xFFF5F5F5);     // Card Background (light grey)
  Color get nearBlack => const Color(0xFF111111); // Main Text
  Color get oliveGray => const Color(0xFF616161); // Secondary Text (neutral grey)
  Color get stoneGray => const Color(0xFF9E9E9E); // Tertiary Text (lighter neutral grey)
  Color get borderCream => const Color.fromARGB(255, 232, 232, 232); // Standard Border (light grey)
  Color get warmSand => const Color(0xFFEEEEEE);   // Secondary Surfaces (light grey)

  // Mappings to existing names to minimize breakage
  Color get primaryBlue => brandPrimary;
  Color get backgroundGrey => isDarkMode ? const Color(0xFF111111) : parchment;
  Color get surfaceWhite => isDarkMode ? const Color(0xFF212121) : ivory;
  Color get textBlack => isDarkMode ? const Color(0xFFFFFFFF) : nearBlack;
  Color get textWhite => isDarkMode ? const Color(0xFF111111) : ivory;
  Color get emptyText => oliveGray;
}