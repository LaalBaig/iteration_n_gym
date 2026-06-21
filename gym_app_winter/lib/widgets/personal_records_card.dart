import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/constants/spacing.dart';
import 'package:gym_app_winter/widgets/insight_card.dart';

/// Displays the top 5 heaviest single lifts across all exercises (all time).
/// The #1 entry is highlighted with a trophy icon and accent colouring.
class PersonalRecordsCard extends StatelessWidget {
  final List<LogWithWorkoutAndExercise> logs;

  const PersonalRecordsCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final brandPurple = Theme.of(context).colorScheme.primary;

    // Find the heaviest logged weight per exercise
    final Map<String, double> personalRecords = {};
    final Map<String, String> prCategory = {};

    for (var item in logs) {
      final name = item.exercise.name;
      final weight = item.log.weight;
      if (weight > 0 && weight > (personalRecords[name] ?? 0.0)) {
        personalRecords[name] = weight;
        prCategory[name] = item.exercise.category;
      }
    }

    final sorted = personalRecords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return InsightCard(
      title: 'Personal Records',
      icon: Icons.emoji_events_rounded,
      subtitle: 'Heaviest weight lifted per exercise',
      child: top5.isEmpty
          ? const StatsEmptyState(message: 'Log weighted exercises to see PRs')
          : Column(
              children: top5.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                return _PRRow(
                  rank: index + 1,
                  exerciseName: e.key,
                  category: prCategory[e.key] ?? '',
                  weight: e.value,
                  accentColor: brandPurple,
                );
              }).toList(),
            ),
    );
  }
}

// ── Internal PR row ───────────────────────────────────────────────────────────

class _PRRow extends StatelessWidget {
  final int rank;
  final String exerciseName;
  final String category;
  final double weight;
  final Color accentColor;

  const _PRRow({
    required this.rank,
    required this.exerciseName,
    required this.category,
    required this.weight,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTop = rank == 1;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isTop
              ? accentColor.withValues(alpha: 0.07)
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
          border: Border.all(
            color: isTop
                ? accentColor.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Trophy for #1, rank label otherwise
            if (isTop)
              Icon(
                Icons.emoji_events_rounded,
                color: accentColor,
                size: ResponsiveHelper.w(22),
              )
            else
              SizedBox(
                width: ResponsiveHelper.w(22),
                child: Text(
                  '#$rank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(12),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            SizedBox(width: AppSpacing.sm),
            // Exercise name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(13),
                      fontWeight: FontWeight.w600,
                      color: isTop ? accentColor : colorScheme.onSurface,
                    ),
                  ),
                  if (category.isNotEmpty)
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.sp(11),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // Weight chip
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isTop
                    ? accentColor.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(ResponsiveHelper.w(8)),
              ),
              child: Text(
                '${weight % 1 == 0 ? weight.toInt() : weight} kg',
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(13),
                  fontWeight: FontWeight.bold,
                  color: isTop ? accentColor : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
