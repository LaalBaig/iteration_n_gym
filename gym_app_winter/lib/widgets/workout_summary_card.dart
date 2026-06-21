import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/constants/spacing.dart';
import 'package:gym_app_winter/widgets/app_card.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final List<LogWithWorkoutAndExercise> logs;

  const WorkoutSummaryCard({super.key, required this.logs});

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
      final tType = item.exercise.trackingType?.toLowerCase();
      final cat = item.exercise.category.toLowerCase();
      if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
        continue;
      }

      final weight = item.log.weight;
      final reps = item.log.reps;
      
      final setVolume = weight > 0 ? weight * reps : reps.toDouble();
      totalVolume += setVolume;

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
                onPressed: () {
                  // TODO: Show help dialog explaining the stats
                },
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
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: isHighlight ? colorScheme.primary : colors.textBlack,
          ),
        ),
      ],
    );
  }
}
