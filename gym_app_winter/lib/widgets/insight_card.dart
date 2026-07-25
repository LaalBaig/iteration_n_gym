import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/constants/spacing.dart';

/// A shared card shell used by all stats insight cards.
/// Renders a consistent surface / border / shadow container with
/// a branded icon + title header, and an optional subtitle.
class InsightCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;

  const InsightCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brandPurple = colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.w(20)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveHelper.w(20)),
        border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: brandPurple, size: ResponsiveHelper.w(20)),
              SizedBox(width: ResponsiveHelper.w(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.sp(18),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(12),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.h(20)),
          child,
        ],
      ),
    );
  }
}

/// A centered empty-state placeholder used when a card has no data to show.
class StatsEmptyState extends StatelessWidget {
  final String message;

  const StatsEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: ResponsiveHelper.sp(13),
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
