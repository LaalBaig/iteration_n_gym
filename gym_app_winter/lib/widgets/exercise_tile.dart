import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/constants/spacing.dart';

class ExerciseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? category;
  final List<String> muscleGroups;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final double bottomMargin;
  final bool confirmDelete;
  final bool isCustom;
  final bool showDeleteIcon;

  const ExerciseTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.category,
    this.muscleGroups = const [],
    required this.onTap,
    this.onDelete,
    this.bottomMargin = 8.0,
    this.confirmDelete = true,
    this.isCustom = false,
    this.showDeleteIcon = true,
  });

  Widget _buildTag(
    BuildContext context,
    String text,
    Color badgeBgColor,
    Color brandPurple,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.w(6),
        vertical: ResponsiveHelper.h(2),
      ),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.w(6)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: brandPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Define colors for the dumbbell badge and category pill
    final Color badgeBgColor = colorScheme.primaryContainer;
    final Color brandPurple = colorScheme.primary;

    return Dismissible(
      key: key ?? ValueKey(title),
      direction: onDelete == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete?.call();
      },
      confirmDismiss: (direction) async {
        if (!confirmDelete) return true;
        return await _showDeleteDialog(context, colorScheme);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.h(bottomMargin)),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: ResponsiveHelper.w(24),
        ),
      ),
      child: BouncingButton(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.h(bottomMargin)),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: ResponsiveHelper.h(12),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
          ),
          child: Row(
            children: [
              // 1. Dumbbell Icon Badge
              Container(
                width: ResponsiveHelper.w(40),
                height: ResponsiveHelper.w(40),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    color: brandPurple,
                    size: ResponsiveHelper.w(18),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),

              // 2. Title & Subtitle + Category Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    if (muscleGroups.isNotEmpty ||
                        (category != null && category!.isNotEmpty) ||
                        isCustom)
                      Padding(
                        padding: EdgeInsets.only(bottom: ResponsiveHelper.h(4)),
                        child: Wrap(
                          spacing: ResponsiveHelper.w(6),
                          runSpacing: ResponsiveHelper.h(4),
                          children: [
                            if (isCustom)
                              _buildTag(
                                context,
                                "Custom",
                                colorScheme.secondaryContainer,
                                colorScheme.onSecondaryContainer,
                              ),
                            if (muscleGroups.isNotEmpty)
                              ...muscleGroups.map(
                                (m) => _buildTag(
                                  context,
                                  m,
                                  badgeBgColor,
                                  brandPurple,
                                ),
                              )
                            else if (category != null && category!.isNotEmpty)
                              _buildTag(
                                context,
                                category!,
                                badgeBgColor,
                                brandPurple,
                              ),
                          ],
                        ),
                      ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),

              // 3. Delete Option or Chevron Right
              if (onDelete != null && showDeleteIcon)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if (!confirmDelete) {
                      onDelete!.call();
                      return;
                    }
                    final confirmed = await _showDeleteDialog(
                      context,
                      colorScheme,
                    );
                    if (confirmed) {
                      onDelete!.call();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                      size: ResponsiveHelper.w(22),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: ResponsiveHelper.w(20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(
    BuildContext context,
    ColorScheme colorScheme,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            "Delete Exercise",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
          ),
          content: Text(
            "Are you sure you want to delete this exercise?",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Delete",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
