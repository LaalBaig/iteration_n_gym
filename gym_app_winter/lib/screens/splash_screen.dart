import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      await _controller.animateBack(0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInBack);
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gradient colours
    final gradientStart = isDark ? const Color(0xFF000000) : Colors.white;
    final gradientEnd = isDark
        ? const Color(0xFF100E22) // very dark purple-black
        : colorScheme.primaryContainer; // light lavender (0xFFEEEDFE)

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Icon + name block
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(scale: _scale.value, child: child),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/icon/app_icon_nobg_white.png'
                          : 'assets/icon/app_icon_nobg.png',
                      width: 160,
                      height: 160,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
