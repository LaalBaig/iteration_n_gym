import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.borderCream,
          width: 1.0,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textBlack,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  // TODO: Show help dialog explaining the stats
                },
                color: colors.emptyText,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Placeholder for Anatomical Heatmap
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.warmSand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.accessibility_new_rounded, size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'Anatomical Heatmap Placeholder',
                    style: TextStyle(color: colors.emptyText),
                  ),
                  Text(
                    '(Requires SVG body assets)',
                    style: TextStyle(fontSize: 12, color: colors.emptyText.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Stats Grid
          Row(
            children: [
              Expanded(child: _StatItem(label: 'Exercises', value: uniqueExercises.toString())),
              Expanded(child: _StatItem(label: 'Sets', value: totalSets.toString())),
              Expanded(child: _StatItem(label: 'Reps', value: totalReps.toString())),
            ],
          ),
          const SizedBox(height: 24),
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
          style: TextStyle(
            fontSize: 13,
            color: colors.emptyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isHighlight ? colorScheme.primary : colors.textBlack,
          ),
        ),
      ],
    );
  }
}
