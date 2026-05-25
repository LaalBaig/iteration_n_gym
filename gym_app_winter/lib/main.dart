import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/navigation/app_router.dart';
import 'package:gym_app_winter/widgets/minimized_workout_bar.dart';


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
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
  
  final _appRouter = AppRouter();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Fitness App",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w500),
          headlineMedium: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w500),
          titleLarge: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.sourceSerif4(fontSize: 17, height: 1.6),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111), // Black
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w500, color: Colors.white),
          headlineMedium: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w500, color: Colors.white),
          titleLarge: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w500, color: Colors.white),
          bodyLarge: GoogleFonts.sourceSerif4(fontSize: 17, height: 1.6, color: Colors.white),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      routerConfig: _appRouter.getRouter(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Align(
              alignment: Alignment.bottomCenter,
              child: MinimizedWorkoutBar(),
            ),
          ],
        );
      },
    );
  }
}
