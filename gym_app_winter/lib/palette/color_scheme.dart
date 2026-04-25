import 'package:flutter/material.dart';

extension AppColorExtension on BuildContext {
  AppColors get colors => AppColors(this);
}

class AppColors {
  final BuildContext context;
  AppColors(this.context);

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // Brand Colors
  Color get brandPrimary => const Color(0xFF2D4A3E); // Deep Forest Green
  Color get brandAccent => const Color(0xFF4A6B5D); // Warm Moss
  
  // Claude Neutrals
  Color get parchment => const Color(0xFFF5F4ED); // Main Background
  Color get ivory => const Color(0xFFFAF9F5);     // Card Background
  Color get nearBlack => const Color(0xFF141413); // Main Text
  Color get oliveGray => const Color(0xFF5E5D59); // Secondary Text
  Color get stoneGray => const Color(0xFF87867F); // Tertiary Text
  Color get borderCream => const Color(0xFFF0EEE6); // Standard Border
  Color get warmSand => const Color(0xFFE8E6DC);   // Secondary Surfaces

  // Mappings to existing names to minimize breakage
  Color get primaryBlue => brandPrimary;
  Color get backgroundGrey => isDarkMode ? const Color(0xFF141413) : parchment;
  Color get surfaceWhite => isDarkMode ? const Color(0xFF30302E) : ivory;
  Color get textBlack => isDarkMode ? const Color(0xFFFAF9F5) : nearBlack;
  Color get textWhite => isDarkMode ? const Color(0xFF141413) : ivory;
  Color get emptyText => oliveGray;
}