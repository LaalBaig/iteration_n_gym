import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/widgets/muscle_volume_heatmap.dart';
import 'package:gym_app_winter/widgets/workout_summary_card.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandPurple = colorScheme.primary;
    
    return StreamBuilder<List<LogWithWorkoutAndExercise>>(
      stream: DatabaseService().db.watchAllLogsWithWorkoutAndExercise(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        
        // Weekly Volume Trend calculation
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
              
              // Dynamic Weekly Volume Trend Chart Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(ResponsiveHelper.w(20)),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.w(20)),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: Offset(0, 4),
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
                          'Weekly Volume Trend',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(18),
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Icon(Icons.trending_up, color: brandPurple),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.h(32)),
                    
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar(context, (weeklyVolumes[0] / peakVolume).clamp(0.05, 1.0), 'Mon', weeklyVolumes[0], brandPurple),
                          _buildChartBar(context, (weeklyVolumes[1] / peakVolume).clamp(0.05, 1.0), 'Tue', weeklyVolumes[1], brandPurple),
                          _buildChartBar(context, (weeklyVolumes[2] / peakVolume).clamp(0.05, 1.0), 'Wed', weeklyVolumes[2], brandPurple),
                          _buildChartBar(context, (weeklyVolumes[3] / peakVolume).clamp(0.05, 1.0), 'Thu', weeklyVolumes[3], brandPurple),
                          _buildChartBar(context, (weeklyVolumes[4] / peakVolume).clamp(0.05, 1.0), 'Fri', weeklyVolumes[4], brandPurple),
                          _buildChartBar(context, (weeklyVolumes[5] / peakVolume).clamp(0.05, 1.0), 'Sat', weeklyVolumes[5], brandPurple),
                          _buildChartBar(context, (weeklyVolumes[6] / peakVolume).clamp(0.05, 1.0), 'Sun', weeklyVolumes[6], brandPurple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(24)),
              // Weekly Summary Card
              WorkoutSummaryCard(logs: logs),
              SizedBox(height: ResponsiveHelper.h(24)),

              // Muscle Volume Heatmap Card
              MuscleVolumeHeatmap(logs: logs),

              // Scroll buffer
              SizedBox(height: ResponsiveHelper.h(120)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartBar(BuildContext context, double heightFactor, String label, double volume, Color brandPurple) {
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
                    color: brandPurple.withValues(alpha: 0.85),
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
