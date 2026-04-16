import 'package:flutter/material.dart';

extension AppColorExtension on BuildContext {
  AppColors get colors => AppColors(this);
}

class AppColors {
  final BuildContext context;
  AppColors(this.context);

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  Color get primaryBlue => const Color(0xFF007AFF);
  Color get backgroundGrey => isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
  Color get surfaceWhite => isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color get textBlack => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1E);
  Color get textWhite => isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color get emptyText => const Color(0xFF8E8E93);
}