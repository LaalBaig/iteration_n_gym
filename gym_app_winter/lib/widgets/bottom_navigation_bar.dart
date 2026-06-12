import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.colors.isDarkMode;

    // Apple liquid glass styling parameters with enhanced contrast
    final backgroundColor = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.92);

    final badgeBgColor = isDark
        ? const Color(0xFF2E2B4A)
        : const Color(0xFFEEECF9);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.12);

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double computedBottomPadding = bottomPadding > 0 ? bottomPadding * 0.6 : 8.0;
    final double totalHeight = 72 + 4 + computedBottomPadding;

    return SizedBox(
      height: totalHeight,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 4,
          bottom: computedBottomPadding,
        ),
        child: Center(
          child: Container(
            width: 380, // Compact, centered bottom bar width for four tabs
            height: 72, // Strict height constraints for parent
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 36,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double totalWidth = constraints.maxWidth;
                      final double tabWidth = totalWidth / 4;
                      final double highlightWidth = tabWidth - 8; // Centered pill with 4px margin on each side
                      final double highlightHeight = 64;
                      // Calculate exact pixel offset to center the active highlight over active tab mathematically
                      final double activeLeft = currentIndex * tabWidth + (tabWidth - highlightWidth) / 2;

                      // Dynamically calculate top coordinate inside layout constraints to resolve vertical offset
                      final double activeTop = (constraints.maxHeight - highlightHeight) / 2;

                      return Stack(
                        children: [
                          // Sliding active background indicator centered mathematically and vertically
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 320),
                            curve: const CustomBackOutCurve(0.6), // Custom subtle organic elastic bounce curve that stays within container bounds
                            left: activeLeft,
                            top: activeTop,
                            width: highlightWidth,
                            height: highlightHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(32), // Matches half of height (64) for a perfect pill shape
                              ),
                            ),
                          ),
                          // Interactive Tab items strictly stretched to fill Stack height
                          Positioned.fill(
                            child: Row(
                              children: [
                                _buildTabItem(
                                  context: context,
                                  index: 0,
                                  activeIcon: Icons.home,
                                  inactiveIcon: Icons.home_outlined,
                                  label: 'Workout',
                                  isSelected: currentIndex == 0,
                                ),
                                _buildTabItem(
                                  context: context,
                                  index: 1,
                                  activeIcon: Icons.fitness_center,
                                  inactiveIcon: Icons.fitness_center,
                                  label: 'Exercises',
                                  isSelected: currentIndex == 1,
                                ),
                                _buildTabItem(
                                  context: context,
                                  index: 2,
                                  activeIcon: Icons.bar_chart,
                                  inactiveIcon: Icons.bar_chart_outlined,
                                  label: 'Stats',
                                  isSelected: currentIndex == 2,
                                ),
                                _buildTabItem(
                                  context: context,
                                  index: 3,
                                  activeIcon: Icons.person,
                                  inactiveIcon: Icons.person_outline,
                                  label: 'Profile',
                                  isSelected: currentIndex == 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required bool isSelected,
  }) {
    final bool isDark = context.colors.isDarkMode;
    final activeColor = isDark
        ? const Color(0xFF9F92EC)
        : const Color(0xFF4C3BC9);
    final inactiveColor = context.colors.stoneGray;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.05 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected ? activeColor : inactiveColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBackOutCurve extends Curve {
  final double period;

  const CustomBackOutCurve([this.period = 1.70158]);

  @override
  double transformInternal(double t) {
    final double nt = t - 1.0;
    return nt * nt * ((period + 1.0) * nt + period) + 1.0;
  }
}
