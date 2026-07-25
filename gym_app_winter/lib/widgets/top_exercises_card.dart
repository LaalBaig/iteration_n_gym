import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/utils/volume_utils.dart';
import 'package:gym_app_winter/constants/spacing.dart';
import 'package:gym_app_winter/widgets/insight_card.dart';

/// Displays the top 5 most-trained exercises ranked by total all-time volume.
/// Accepts the full [logs] list and derives its own data internally.
class TopExercisesCard extends StatelessWidget {
  final List<LogWithWorkoutAndExercise> logs;
  final double? bodyweightKg;

  const TopExercisesCard({super.key, required this.logs, this.bodyweightKg});

  @override
  Widget build(BuildContext context) {
    final brandPurple = Theme.of(context).colorScheme.primary;

    // Aggregate volume and set count per exercise
    final Map<String, double> exerciseVolumes = {};
    final Map<String, int> exerciseSets = {};

    for (var item in logs) {
      final name = item.exercise.name;
      final tType = item.exercise.trackingType?.toLowerCase() ?? '';
      final cat = item.exercise.category.toLowerCase();
      final isTimed = tType == 'time based' ||
          tType == 'timed' ||
          cat == 'timed' ||
          cat == 'cardio';
      final vol = isTimed
          ? (item.log.time?.toDouble() ?? 0.0)
          : calcSetVolume(
              weight: item.log.weight,
              reps: item.log.reps,
              trackingType: item.exercise.trackingType,
              category: item.exercise.category,
              exerciseType: item.exercise.exerciseType,
              bodyweightKg: bodyweightKg,
            );

      exerciseVolumes[name] = (exerciseVolumes[name] ?? 0.0) + vol;
      exerciseSets[name] = (exerciseSets[name] ?? 0) + 1;
    }

    final sorted = exerciseVolumes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final maxVol = top5.isEmpty ? 1.0 : top5.first.value;

    return InsightCard(
      title: 'Top 5 Exercises',
      icon: Icons.bar_chart_rounded,
      subtitle: 'By total volume (all time)',
      child: logs.isEmpty
          ? const StatsEmptyState(message: 'No workout data yet')
          : Column(
              children: top5.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                final fraction = (e.value / maxVol).clamp(0.04, 1.0);
                final sets = exerciseSets[e.key] ?? 0;
                return _RankedBarRow(
                  rank: index + 1,
                  label: e.key,
                  sublabel: '$sets sets',
                  fraction: fraction,
                  value: e.value >= 1000
                      ? '${(e.value / 1000).toStringAsFixed(1)}k'
                      : e.value.toStringAsFixed(0),
                  accentColor: brandPurple,
                );
              }).toList(),
            ),
    );
  }
}

// ── Internal ranked bar row ───────────────────────────────────────────────────

class _RankedBarRow extends StatelessWidget {
  final int rank;
  final String label;
  final String sublabel;
  final double fraction;
  final String value;
  final Color accentColor;

  const _RankedBarRow({
    required this.rank,
    required this.label,
    required this.sublabel,
    required this.fraction,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTop = rank == 1;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: ResponsiveHelper.w(28),
            height: ResponsiveHelper.w(28),
            decoration: BoxDecoration(
              color: isTop
                  ? accentColor.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(12),
                  fontWeight: FontWeight.bold,
                  color: isTop ? accentColor : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          // Label + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(13),
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.sp(13),
                        fontWeight: FontWeight.bold,
                        color: isTop ? accentColor : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.w(4)),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      accentColor.withValues(alpha: isTop ? 0.9 : 0.55),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(11),
                    color: colorScheme.onSurfaceVariant,
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
