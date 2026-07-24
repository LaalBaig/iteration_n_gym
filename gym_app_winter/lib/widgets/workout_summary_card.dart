import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/utils/volume_utils.dart';
import 'package:gym_app_winter/constants/spacing.dart';
import 'package:gym_app_winter/widgets/app_card.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final List<LogWithWorkoutAndExercise> logs;
  final double? bodyweightKg;

  const WorkoutSummaryCard({super.key, required this.logs, this.bodyweightKg});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Filter logs for the current week
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    
    final weeklyLogs = logs.where((item) {
      final logDate = item.workout.startTime;
      return logDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
             logDate.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).toList();

    // 2. Calculate Stats
    final uniqueExercises = weeklyLogs.map((log) => log.exercise.name).toSet().length;
    final totalSets = weeklyLogs.length;
    final totalReps = weeklyLogs.fold<int>(0, (sum, item) => sum + item.log.reps);
    
    double totalVolume = 0;
    double heaviestWeight = 0;
    int totalWeightedSets = 0;
    double sumOfWeights = 0;

    for (var item in weeklyLogs) {
      final tType = item.exercise.trackingType?.toLowerCase() ?? '';
      final cat = item.exercise.category.toLowerCase();
      if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
        continue;
      }

      final weight = item.log.weight;
      final reps = item.log.reps;

      totalVolume += calcSetVolume(
        weight: weight,
        reps: reps,
        trackingType: item.exercise.trackingType,
        category: item.exercise.category,
        exerciseType: item.exercise.exerciseType,
        bodyweightKg: bodyweightKg,
      );

      if (weight > 0) {
        if (weight > heaviestWeight) heaviestWeight = weight;
        sumOfWeights += weight;
        totalWeightedSets++;
      }
    }

    final averageWeight = totalWeightedSets > 0 ? sumOfWeights / totalWeightedSets : 0.0;
    final numberFormat = NumberFormat('#,##0.#');

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Summary',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textBlack,
                ),
              ),
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
                color: colors.emptyText,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          // Stats Grid
          Row(
            children: [
              Expanded(child: _StatItem(label: 'Exercises', value: uniqueExercises.toString())),
              Expanded(child: _StatItem(label: 'Sets', value: totalSets.toString())),
              Expanded(child: _StatItem(label: 'Reps', value: totalReps.toString())),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _StatItem(label: 'Volume', value: '${numberFormat.format(totalVolume)} kg', isHighlight: true)),
              Expanded(child: _StatItem(label: 'Heaviest', value: '${numberFormat.format(heaviestWeight)} kg')),
              Expanded(child: _StatItem(label: 'Average', value: '${numberFormat.format(averageWeight)} kg')),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
        ),
        title: Text(
          'Weekly Summary',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HelpRow(term: 'Exercises', explanation: 'Number of distinct exercises logged this week.'),
            _HelpRow(term: 'Sets', explanation: 'Total completed sets logged this week.'),
            _HelpRow(term: 'Reps', explanation: 'Total reps across all sets this week.'),
            _HelpRow(
              term: 'Volume',
              explanation: 'Total weight moved this week (weight × reps per set, summed). '
                  'Bodyweight exercises use your bodyweight plus any added weight.',
            ),
            _HelpRow(term: 'Heaviest', explanation: 'The single heaviest weight logged this week.'),
            _HelpRow(term: 'Average', explanation: 'Average weight across all weighted sets this week.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Got it',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final String term;
  final String explanation;

  const _HelpRow({required this.term, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            explanation,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveHelper.sp(13),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _StatItem({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.emptyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: ResponsiveHelper.sp(16),
              color: isHighlight ? colorScheme.primary : colors.textBlack,
            ),
          ),
        ),
      ],
    );
  }
}
