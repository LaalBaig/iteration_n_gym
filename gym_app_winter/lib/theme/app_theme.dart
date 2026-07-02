import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

class AppTheme {
  static TextTheme getResponsiveTextTheme(TextTheme baseTextTheme) {
    final dmSansTextTheme = GoogleFonts.dmSansTextTheme(baseTextTheme);
    return dmSansTextTheme.copyWith(
      displayLarge: dmSansTextTheme.displayLarge?.copyWith(
        fontSize: ResponsiveHelper.sp(32),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: dmSansTextTheme.headlineMedium?.copyWith(
        fontSize: ResponsiveHelper.sp(22),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: dmSansTextTheme.bodyLarge?.copyWith(
        fontSize: ResponsiveHelper.sp(16),
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: dmSansTextTheme.bodyMedium?.copyWith(
        fontSize: ResponsiveHelper.sp(14),
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelSmall: dmSansTextTheme.labelSmall?.copyWith(
        fontSize: ResponsiveHelper.sp(11),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }
}
