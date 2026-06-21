import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: ResponsiveHelper.w(8),
            offset: Offset(0, ResponsiveHelper.h(2)),
          ),
        ],
      ),
      child: child,
    );
  }
}
