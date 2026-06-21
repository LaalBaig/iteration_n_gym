import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/widgets/insight_card.dart';
import 'package:gym_app_winter/widgets/muscle_volume_heatmap.dart';
import 'package:gym_app_winter/widgets/workout_summary_card.dart';
import 'package:gym_app_winter/widgets/top_exercises_card.dart';
import 'package:gym_app_winter/widgets/muscle_group_focus_card.dart';
import 'package:gym_app_winter/widgets/personal_records_card.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brandPurple = colorScheme.primary;

    return StreamBuilder<List<LogWithWorkoutAndExercise>>(
      stream: DatabaseService().db.watchAllLogsWithWorkoutAndExercise(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        // ── Weekly Volume Trend data ─────────────────────────────────────
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(monday.year, monday.month, monday.day);
        final weeklyVolumes = List.filled(7, 0.0);

        for (var item in logs) {
          final logDate = item.workout.startTime;
          if (logDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
              logDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
            final dayIndex = logDate.difference(startOfWeek).inDays.clamp(0, 6);
            final volume = item.log.weight > 0
                ? item.log.weight * item.log.reps
                : item.log.reps.toDouble();
            weeklyVolumes[dayIndex] += volume;
          }
        }

        double peakVolume = weeklyVolumes.reduce((a, b) => a > b ? a : b);
        if (peakVolume == 0) peakVolume = 1.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.w(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics & Stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 32,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(24)),

              WorkoutSummaryCard(logs: logs),
              SizedBox(height: ResponsiveHelper.h(24)),

              TopExercisesCard(logs: logs),
              SizedBox(height: ResponsiveHelper.h(24)),

              MuscleGroupFocusCard(logs: logs),
              SizedBox(height: ResponsiveHelper.h(24)),

              PersonalRecordsCard(logs: logs),
              SizedBox(height: ResponsiveHelper.h(24)),

              // Weekly Volume Trend
              InsightCard(
                title: 'Weekly Volume Trend',
                icon: Icons.trending_up,
                child: SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return _ChartBar(
                        heightFactor: (weeklyVolumes[i] / peakVolume).clamp(0.05, 1.0),
                        label: labels[i],
                        volume: weeklyVolumes[i],
                        color: brandPurple,
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(24)),

              MuscleVolumeHeatmap(logs: logs),

              SizedBox(height: ResponsiveHelper.h(120)),
            ],
          ),
        );
      },
    );
  }
}

// ── Chart bar (local to this screen only) ────────────────────────────────────

class _ChartBar extends StatelessWidget {
  final double heightFactor;
  final String label;
  final double volume;
  final Color color;

  const _ChartBar({
    required this.heightFactor,
    required this.label,
    required this.volume,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: 'Volume: ${volume.toInt()}',
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.w(4)),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.h(8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.sp(12),
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
