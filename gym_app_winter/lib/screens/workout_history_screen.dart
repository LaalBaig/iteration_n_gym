import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  String _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return "0s";
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  String _formatSetLog(ExerciseLog log) {
    final weight = log.weight;
    final reps = log.reps;

    if (weight > 0 && reps == 0) {
      // Timed
      final seconds = weight.toInt();
      final min = (seconds ~/ 60).toString().padLeft(2, '0');
      final sec = (seconds % 60).toString().padLeft(2, '0');
      return "$min:$sec";
    } else if (weight == 0 && reps > 0) {
      // Bodyweight
      return "$reps reps";
    } else {
      // Weighted
      final formattedWeight = weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
      return "${formattedWeight}kg x $reps";
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, Workout workout) async {
    final db = DatabaseService().db;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1,
            ),
          ),
          title: Text(
            "Delete Workout",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this workout session?",
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                "Delete",
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Fetch logs before deleting (for potential undo restoration)
    final logs = await db.getLogsForWorkout(workout.id);

    // Perform deletion
    await db.deleteWorkout(workout.id);

    if (!context.mounted) return;

    // Show floating SnackBar with Undo action
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          "Workout session deleted",
          style: TextStyle(
            color: colorScheme.onInverseSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
        ),
        margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: colorScheme.inversePrimary,
          onPressed: () async {
            await db.restoreWorkout(workout, logs);
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Safeguard: explicitly hide the SnackBar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      messenger.hideCurrentSnackBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          "Workout History",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: ResponsiveHelper.sp(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Workout>>(
        stream: DatabaseService().db.watchAllWorkouts(),
        builder: (context, snapshot) {
          final workouts = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting && workouts.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history,
                      color: colorScheme.onSurfaceVariant,
                      size: ResponsiveHelper.w(40),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.h(16)),
                  Text(
                    "No Workouts Completed",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(18),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.h(8)),
                  Text(
                    "Workouts you finish will be listed here",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(14),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: workouts.length,
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24), vertical: ResponsiveHelper.h(8)),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _WorkoutHistoryCard(
                workout: workout,
                formatDuration: _formatDuration,
                formatSetLog: _formatSetLog,
                onDelete: () => _confirmAndDelete(context, workout),
              );
            },
          );
        },
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatefulWidget {
  const _WorkoutHistoryCard({
    required this.workout,
    required this.formatDuration,
    required this.formatSetLog,
    required this.onDelete,
  });

  final Workout workout;
  final String Function(DateTime start, DateTime? end) formatDuration;
  final String Function(ExerciseLog log) formatSetLog;
  final VoidCallback onDelete;

  @override
  State<_WorkoutHistoryCard> createState() => _WorkoutHistoryCardState();
}

class _WorkoutHistoryCardState extends State<_WorkoutHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workout = widget.workout;

    final dateStr = DateFormat('EEEE, MMM d').format(workout.startTime);
    final timeStr = DateFormat('h:mm a').format(workout.startTime);
    final durationStr = widget.formatDuration(workout.startTime, workout.endTime);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(ResponsiveHelper.w(16)),
      decoration: ShapeDecoration(
        color: context.colors.surfaceWhite,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 1,
          ),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Date, Duration, Expand toggle, and Delete
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(17),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.h(4)),
                      Text(
                        "$timeStr • $durationStr",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(13),
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: ResponsiveHelper.w(24),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveHelper.w(4.0)),
                    child: Icon(
                      Icons.delete_outline,
                      size: ResponsiveHelper.w(22),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (workout.description != null && workout.description!.isNotEmpty) ...[
            SizedBox(height: ResponsiveHelper.h(10)),
            Text(
              workout.description!,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(14),
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveHelper.h(12)),
                      Divider(height: 1),
                      SizedBox(height: ResponsiveHelper.h(12)),
                      // Exercises and sets list
                      FutureBuilder<List<ExerciseLog>>(
                        future: DatabaseService().db.getLogsForWorkout(workout.id),
                        builder: (context, logSnapshot) {
                          final logs = logSnapshot.data ?? [];

                          if (logSnapshot.connectionState == ConnectionState.waiting && logs.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(8.0)),
                              child: SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          if (logs.isEmpty) {
                            return Text(
                              "No logs recorded for this workout.",
                              style: TextStyle(
                                fontSize: ResponsiveHelper.sp(13),
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            );
                          }

                          // Group logs by exerciseName
                          final Map<String, List<ExerciseLog>> groupedLogs = {};
                          for (final log in logs) {
                            groupedLogs.putIfAbsent(log.exerciseName, () => []).add(log);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groupedLogs.entries.map((entry) {
                              final exerciseName = entry.key;
                              final exerciseSets = entry.value;
                              final setListText = exerciseSets.map(widget.formatSetLog).join(" • ");
                              final setCountText = exerciseSets.length == 1 ? "1 set" : "${exerciseSets.length} sets";
                              final note = exerciseSets
                                  .firstWhere(
                                    (s) => s.setNumber == 1,
                                    orElse: () => exerciseSets.first,
                                  )
                                  .notes;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exerciseName,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.sp(14),
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveHelper.h(3)),
                                    Text(
                                      "$setCountText: $setListText",
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.sp(13),
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (note != null && note.isNotEmpty) ...[
                                      SizedBox(height: ResponsiveHelper.h(3)),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.notes_rounded,
                                            size: ResponsiveHelper.w(12),
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          SizedBox(width: ResponsiveHelper.w(4)),
                                          Expanded(
                                            child: Text(
                                              note,
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.sp(12),
                                                color: colorScheme.onSurfaceVariant,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
