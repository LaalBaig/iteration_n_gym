import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/constants/spacing.dart';
import 'package:gym_app_winter/widgets/insight_card.dart';

/// Displays a breakdown of the top 5 most-trained muscle categories,
/// showing each one's percentage share of total sets logged (all time).
class MuscleGroupFocusCard extends StatelessWidget {
  final List<LogWithWorkoutAndExercise> logs;

  const MuscleGroupFocusCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandPurple = colorScheme.primary;

    // Aggregate set count per category
    final Map<String, int> categoryCount = {};
    for (var item in logs) {
      final cat = item.exercise.category;
      if (cat.isNotEmpty) {
        categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
      }
    }

    final sorted = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final totalSets = top5.fold<int>(0, (s, e) => s + e.value);

    return InsightCard(
      title: 'Muscle Group Focus',
      icon: Icons.accessibility_new_rounded,
      subtitle: 'Sets per category (all time)',
      child: logs.isEmpty
          ? const StatsEmptyState(message: 'No workout data yet')
          : Column(
              children: [
                ...top5.map((e) {
                  final pct = totalSets > 0 ? e.value / totalSets : 0.0;
                  return _MuscleGroupRow(
                    muscle: e.key,
                    sets: e.value,
                    percentage: pct,
                    accentColor: brandPurple,
                  );
                }),
                if (sorted.length > 5) ...[
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '+ ${sorted.length - 5} more categories',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ── Internal muscle group row ─────────────────────────────────────────────────

class _MuscleGroupRow extends StatelessWidget {
  final String muscle;
  final int sets;
  final double percentage;
  final Color accentColor;

  const _MuscleGroupRow({
    required this.muscle,
    required this.sets,
    required this.percentage,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pctLabel = '${(percentage * 100).toStringAsFixed(0)}%';

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          // Icon pill
          Container(
            width: ResponsiveHelper.w(36),
            height: ResponsiveHelper.w(36),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: ResponsiveHelper.w(18),
              color: accentColor,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      muscle,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.sp(13),
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$sets sets',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(12),
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          pctLabel,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(12),
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.w(4)),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      accentColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
