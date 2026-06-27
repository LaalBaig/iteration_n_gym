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
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1000), () {
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

    // Icon badge colours
    final iconBadgeBg = colorScheme.primaryContainer;
    final iconColor = colorScheme.primary;

    // Text colours
    final titleColor = colorScheme.onSurface;
    final taglineColor = colorScheme.onSurfaceVariant;
    final dotColor = colorScheme.primary;

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
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: iconBadgeBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Iteration N',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tagline — delayed fade
              AnimatedBuilder(
                animation: _taglineOpacity,
                builder: (context, _) => Opacity(
                  opacity: _taglineOpacity.value,
                  child: Text(
                    'Track your gains.',
                    style: TextStyle(
                      fontSize: 16,
                      color: taglineColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Bottom pulse dots
              AnimatedBuilder(
                animation: _taglineOpacity,
                builder: (context, _) => Opacity(
                  opacity: _taglineOpacity.value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: _PulseDots(color: dotColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDots extends StatefulWidget {
  const _PulseDots({required this.color});
  final Color color;

  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (((_ctrl.value - delay) % 1.0 + 1.0) % 1.0);
            final opacity =
                (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
