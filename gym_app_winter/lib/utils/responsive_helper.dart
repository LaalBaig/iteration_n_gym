import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Reference device the layout values throughout the app were designed
  // against (iPhone 14 logical pixels).
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  // Default to the design size so widgets render at their intended
  // dimensions before init() runs — notably under `flutter test`, where a
  // widget is pumped directly without the app root that calls init().
  static double screenWidth = _designWidth;
  static double screenHeight = _designHeight;

  static void init(BuildContext context) {
    MediaQueryData mediaQuery;
    try {
      mediaQuery = MediaQuery.of(context);
    } catch (_) {
      mediaQuery = MediaQueryData.fromView(View.of(context));
    }
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
  }

  static double w(double width) => (width / _designWidth) * screenWidth;
  static double h(double height) => (height / _designHeight) * screenHeight;
  static double sp(double fontSize) => (fontSize / _designWidth) * screenWidth;
  static double clamp(double value, double min, double max) => value.clamp(min, max);

  static T adaptive<T>({required T small, required T medium, required T large}) {
    if (screenWidth < 360) return small;
    if (screenWidth < 600) return medium;
    return large;
  }

  static bool get isTablet => screenWidth >= 600;
  static bool get isSmallPhone => screenWidth < 360;
}
