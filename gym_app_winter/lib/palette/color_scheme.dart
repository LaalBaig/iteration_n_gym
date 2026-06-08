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

class RestTimerTheme extends ThemeExtension<RestTimerTheme> {
  final Color? buttonActiveBg;
  final Color? buttonInactiveBg;
  final Color? buttonActiveTextColor;
  final Color? buttonInactiveTextColor;
  final Color? popupBg;
  final Color? popupTextColor;
  final Color? trackColor;
  final Color? arcColor;
  final Color? adjustBtnBg;
  final Color? adjustBtnTextColor;

  const RestTimerTheme({
    required this.buttonActiveBg,
    required this.buttonInactiveBg,
    required this.buttonActiveTextColor,
    required this.buttonInactiveTextColor,
    required this.popupBg,
    required this.popupTextColor,
    required this.trackColor,
    required this.arcColor,
    required this.adjustBtnBg,
    required this.adjustBtnTextColor,
  });

  @override
  RestTimerTheme copyWith({
    Color? buttonActiveBg,
    Color? buttonInactiveBg,
    Color? buttonActiveTextColor,
    Color? buttonInactiveTextColor,
    Color? popupBg,
    Color? popupTextColor,
    Color? trackColor,
    Color? arcColor,
    Color? adjustBtnBg,
    Color? adjustBtnTextColor,
  }) {
    return RestTimerTheme(
      buttonActiveBg: buttonActiveBg ?? this.buttonActiveBg,
      buttonInactiveBg: buttonInactiveBg ?? this.buttonInactiveBg,
      buttonActiveTextColor: buttonActiveTextColor ?? this.buttonActiveTextColor,
      buttonInactiveTextColor: buttonInactiveTextColor ?? this.buttonInactiveTextColor,
      popupBg: popupBg ?? this.popupBg,
      popupTextColor: popupTextColor ?? this.popupTextColor,
      trackColor: trackColor ?? this.trackColor,
      arcColor: arcColor ?? this.arcColor,
      adjustBtnBg: adjustBtnBg ?? this.adjustBtnBg,
      adjustBtnTextColor: adjustBtnTextColor ?? this.adjustBtnTextColor,
    );
  }

  @override
  RestTimerTheme lerp(ThemeExtension<RestTimerTheme>? other, double t) {
    if (other is! RestTimerTheme) {
      return this;
    }
    return RestTimerTheme(
      buttonActiveBg: Color.lerp(buttonActiveBg, other.buttonActiveBg, t),
      buttonInactiveBg: Color.lerp(buttonInactiveBg, other.buttonInactiveBg, t),
      buttonActiveTextColor: Color.lerp(buttonActiveTextColor, other.buttonActiveTextColor, t),
      buttonInactiveTextColor: Color.lerp(buttonInactiveTextColor, other.buttonInactiveTextColor, t),
      popupBg: Color.lerp(popupBg, other.popupBg, t),
      popupTextColor: Color.lerp(popupTextColor, other.popupTextColor, t),
      trackColor: Color.lerp(trackColor, other.trackColor, t),
      arcColor: Color.lerp(arcColor, other.arcColor, t),
      adjustBtnBg: Color.lerp(adjustBtnBg, other.adjustBtnBg, t),
      adjustBtnTextColor: Color.lerp(adjustBtnTextColor, other.adjustBtnTextColor, t),
    );
  }
}

extension RestTimerThemeContext on BuildContext {
  RestTimerTheme get timerTheme => Theme.of(this).extension<RestTimerTheme>()!;
}