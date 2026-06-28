import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();

  int _currentPage = 0;
  bool _isSaving = false;
  bool _nameHasError = false;

  late final AnimationController _entryController;
  late final Animation<double> _entryOpacity;
  late final Animation<Offset> _entrySlide;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );
    _entryController.forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _nameFocus.dispose();
    _weightFocus.dispose();
    _entryController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameHasError = true);
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      _nameFocus.requestFocus();
      return;
    }
    setState(() => _nameHasError = false);
    HapticFeedback.selectionClick();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _weightFocus.requestFocus();
    });
  }

  void _prevPage() {
    _weightFocus.unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  Future<void> _finish() async {
    final weight = double.tryParse(_weightController.text.trim());
    if (_weightController.text.trim().isNotEmpty && weight == null) return;

    _weightFocus.unfocus();
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await prefs.setString('userName', name);
    if (weight != null) await prefs.setDouble('userBodyweightKg', weight);
    await prefs.setBool('hasCompletedOnboarding', true);

    if (!mounted) return;
    setState(() => _isSaving = false);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientStart = isDark ? const Color(0xFF000000) : Colors.white;
    final gradientEnd = isDark ? const Color(0xFF100E22) : colorScheme.primaryContainer;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          child: FadeTransition(
            opacity: _entryOpacity,
            child: SlideTransition(
              position: _entrySlide,
              child: Column(
                children: [
                  SizedBox(height: ResponsiveHelper.h(48)),

                  // App icon — hidden on the welcome page
                  AnimatedOpacity(
                    opacity: _currentPage < 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Image.asset(
                      isDark
                          ? 'assets/icon/app_icon_nobg_white.png'
                          : 'assets/icon/app_icon_nobg.png',
                      width: 64,
                      height: 64,
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.h(40)),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: [
                        _NamePage(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          hasError: _nameHasError,
                          shakeAnimation: _shakeOffset,
                          shakeController: _shakeController,
                          onContinue: _nextPage,
                          onNameChanged: () {
                            if (_nameHasError) setState(() => _nameHasError = false);
                          },
                        ),
                        _WeightPage(
                          controller: _weightController,
                          focusNode: _weightFocus,
                          isSaving: _isSaving,
                          onBack: _prevPage,
                          onFinish: _finish,
                        ),
                        _WelcomePage(
                          name: _nameController.text.trim(),
                          onStart: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),

                  // Step dots — hidden on welcome page
                  AnimatedOpacity(
                    opacity: _currentPage < 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.h(32)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Bottom padding when on welcome page
                  if (_currentPage == 2) SizedBox(height: ResponsiveHelper.h(32)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pages ─────────────────────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  const _NamePage({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.shakeAnimation,
    required this.shakeController,
    required this.onContinue,
    required this.onNameChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final Animation<double> shakeAnimation;
  final AnimationController shakeController;
  final VoidCallback onContinue;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome.',
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(34),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(10)),
          Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(16),
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(36)),

          AnimatedBuilder(
            animation: shakeController,
            builder: (_, child) => Transform.translate(
              offset: Offset(shakeAnimation.value, 0),
              child: child,
            ),
            child: _OnboardingTextField(
              controller: controller,
              focusNode: focusNode,
              hintText: 'Your name',
              hasError: hasError,
              textCapitalization: TextCapitalization.words,
              maxLength: 30,
              keyboardType: TextInputType.name,
              onChanged: (_) => onNameChanged(),
              onSubmitted: (_) => onContinue(),
            ),
          ),

          if (hasError) ...[
            SizedBox(height: ResponsiveHelper.h(8)),
            Text(
              'Please enter your name to continue.',
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(13),
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const Spacer(),

          _OnboardingButton(
            label: 'Continue',
            onTap: onContinue,
          ),

          SizedBox(height: ResponsiveHelper.h(24)),
        ],
      ),
    );
  }
}

class _WeightPage extends StatelessWidget {
  const _WeightPage({
    required this.controller,
    required this.focusNode,
    required this.isSaving,
    required this.onBack,
    required this.onFinish,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(bottom: ResponsiveHelper.h(4)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: ResponsiveHelper.w(4)),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(15),
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.h(20)),

          Text(
            'Your bodyweight.',
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(34),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(10)),
          Text(
            'Used for bodyweight exercise tracking.\nYou can change this anytime.',
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(16),
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(36)),

          _OnboardingTextField(
            controller: controller,
            focusNode: focusNode,
            hintText: '70',
            suffix: Text(
              'kg',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveHelper.sp(16),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
            ],
            onSubmitted: (_) => onFinish(),
          ),

          const Spacer(),

          _OnboardingButton(
            label: isSaving ? 'Setting up…' : "Let's go",
            onTap: isSaving ? () {} : onFinish,
          ),

          SizedBox(height: ResponsiveHelper.h(24)),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatefulWidget {
  const _WelcomePage({required this.name, required this.onStart});

  final String name;
  final VoidCallback onStart;

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _glowScale;
  late final Animation<double> _line1Opacity;
  late final Animation<Offset> _line1Slide;
  late final Animation<double> _line2Opacity;
  late final Animation<Offset> _line2Slide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _glowScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.05, 0.45, curve: Curves.easeOutBack)),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.05, 0.3, curve: Curves.easeOut)),
    );
    _line1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.6, curve: Curves.easeOut)),
    );
    _line1Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.65, curve: Curves.easeOut)),
    );
    _line2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.48, 0.72, curve: Curves.easeOut)),
    );
    _line2Slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.48, 0.75, curve: Curves.easeOut)),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 0.82, curve: Curves.easeOut)),
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.75, 1.0, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.75, 1.0, curve: Curves.easeOut)),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _ctrl.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = widget.name.split(' ').first;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(28)),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Glowing icon
          AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, child) => Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Transform.scale(
                  scale: _glowScale.value,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (ctx2, child2) => Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                              colorScheme.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Inner filled circle
                Transform.scale(
                  scale: _glowScale.value,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    ),
                  ),
                ),
                // Icon
                Opacity(
                  opacity: _iconOpacity.value,
                  child: Transform.scale(
                    scale: _iconScale.value,
                    child: Image.asset(
                      isDark
                          ? 'assets/icon/app_icon_nobg_white.png'
                          : 'assets/icon/app_icon_nobg.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.h(44)),

          // "You're all set,"
          FadeTransition(
            opacity: _line1Opacity,
            child: SlideTransition(
              position: _line1Slide,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "You're all set,",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(34),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.h(4)),

          // "[Name]."
          FadeTransition(
            opacity: _line2Opacity,
            child: SlideTransition(
              position: _line2Slide,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$firstName.',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(34),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.h(16)),

          // Subtitle
          FadeTransition(
            opacity: _subtitleOpacity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your profile is ready. Time to train.",
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(16),
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const Spacer(flex: 3),

          // CTA button
          FadeTransition(
            opacity: _buttonOpacity,
            child: SlideTransition(
              position: _buttonSlide,
              child: _OnboardingButton(
                label: 'Start Training',
                onTap: widget.onStart,
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.h(24)),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _OnboardingTextField extends StatelessWidget {
  const _OnboardingTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.hasError = false,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool hasError;
  final Widget? suffix;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = hasError ? colorScheme.error : colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
          side: BorderSide(color: borderColor, width: hasError ? 1.5 : 1.0),
        ),
        shadows: [
          BoxShadow(
            color: hasError
                ? colorScheme.error.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: TextInputAction.done,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: ResponsiveHelper.sp(18),
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
          suffix: suffix,
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.w(20),
            vertical: ResponsiveHelper.h(18),
          ),
        ),
      ),
    );
  }
}

class _OnboardingButton extends StatefulWidget {
  const _OnboardingButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(18)),
          decoration: ShapeDecoration(
            color: colorScheme.primary,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
            ),
            shadows: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(17),
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
