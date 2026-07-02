import 'package:flutter/material.dart';

class ResponsiveHelper {
  static late MediaQueryData _mediaQuery;
  static late double screenWidth;
  static late double screenHeight;
  static late double _designWidth;
  static late double _designHeight;

  static void init(BuildContext context) {
    try {
      _mediaQuery = MediaQuery.of(context);
    } catch (_) {
      _mediaQuery = MediaQueryData.fromView(View.of(context));
    }
    screenWidth = _mediaQuery.size.width;
    screenHeight = _mediaQuery.size.height;
    _designWidth = 390.0;
    _designHeight = 844.0;
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
