import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym_app_winter/navigation/app_router.dart';
import 'package:gym_app_winter/widgets/minimized_workout_bar.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/theme/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme');
    if (isDark != null) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
  
  final _appRouter = AppRouter();
  
  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: "Fitness App",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4C3BC9),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFEEEDFE),
          onPrimaryContainer: Color(0xFF3C3489),
          surface: Colors.white,
          onSurface: Color(0xFF111111),
          surfaceContainerHighest: Color(0xFFEEEEEE),
          onSurfaceVariant: Color(0xFF616161),
          outlineVariant: Color(0xFFE8E8E8),
          error: Colors.red,
          onError: Colors.white,
        ),
        textTheme: AppTheme.getResponsiveTextTheme(ThemeData.light().textTheme),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        extensions: const <ThemeExtension<dynamic>>[
          RestTimerTheme(
            buttonActiveBg: Color(0xFF3C3489),
            buttonInactiveBg: Color(0xFF4C3BC9), // M3 Primary Light
            buttonActiveTextColor: Colors.white,
            buttonInactiveTextColor: Colors.white,
            popupBg: Colors.white,
            popupTextColor: Colors.black87,
            trackColor: Color(0xFFEEEDFE),
            arcColor: Color(0xFF5048D4),
            adjustBtnBg: Color(0xFFEEEDFE),
            adjustBtnTextColor: Color(0xFF3C3489),
          ),
        ],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // True Black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9F92EC),
          onPrimary: Color(0xFF000000),
          primaryContainer: Color(0xFF3C3489),
          onPrimaryContainer: Colors.white,
          surface: Color(0xFF1C1C1E), // Elevated dark gray for tiles/cards to stand out
          onSurface: Colors.white,
          surfaceContainerHighest: Color(0xFF2C2C2E), // Lighter gray for highlights
          onSurfaceVariant: Color(0xFF9E9E9E),
          outlineVariant: Color(0xFF38383A), // Visible outlines
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        textTheme: AppTheme.getResponsiveTextTheme(ThemeData.dark().textTheme),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        extensions: const <ThemeExtension<dynamic>>[
          RestTimerTheme(
            buttonActiveBg: Color(0xFF3C3489), // Dark Purple
            buttonInactiveBg: Color(0xFF9F92EC), // M3 Primary Dark
            buttonActiveTextColor: Colors.white,
            buttonInactiveTextColor: Color(0xFF000000),
            popupBg: Color(0xFF1C1C1E),
            popupTextColor: Colors.white70,
            trackColor: Color(0xFF2C2C2E),
            arcColor: Color(0xFF9F92EC),
            adjustBtnBg: Color(0xFF2C2C2E),
            adjustBtnTextColor: Color(0xFF9F92EC),
          ),
        ],
      ),
      routerConfig: _appRouter.getRouter(),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final clampedTextScaler = TextScaler.linear(
          mediaQueryData.textScaler.scale(1).clamp(0.85, 1.15)
        );
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: clampedTextScaler),
          child: Stack(
            children: [
              if (child != null) child,
              Align(
                alignment: Alignment.bottomCenter,
                child: MinimizedWorkoutBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}
