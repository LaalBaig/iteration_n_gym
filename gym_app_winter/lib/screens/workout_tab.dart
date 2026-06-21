import 'dart:convert';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/workout_button_top.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart' hide Exercise;
import 'package:gym_app_winter/datamodel/exercise.dart' as model;
import 'package:gym_app_winter/state/workout_manager.dart';

// Workouts Tab Content
class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  //   final TextEditingController _controller = TextEditingController();

  void _showRoutineOptions(BuildContext context, RoutineWithExercises routine) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(16.0)),
                child: Text(
                  routine.routine.title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.play_arrow, color: colorScheme.primary),
                title: Text("Start Workout", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _startWorkoutFromRoutine(context, routine);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text("Delete Routine", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: Theme.of(dialogContext).colorScheme.surface,
                      title: Text("Delete Routine?"),
                      content: Text("Are you sure you want to delete '${routine.routine.title}'? This cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DatabaseService().db.deleteRoutine(routine.routine.id);
                  }
                },
              ),
              SizedBox(height: ResponsiveHelper.h(8)),
            ],
          ),
        );
      },
    );
  }

  void _startWorkoutFromRoutine(BuildContext context, RoutineWithExercises routine) {
    if (WorkoutManager().isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A workout is already active. Complete or discard it first."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    WorkoutManager().startWorkout();
    int totalSetsCount = 0;
    for (final re in routine.exercises) {
      final ex = model.Exercise(
        id: '${DateTime.now().millisecondsSinceEpoch}_${re.exerciseName.hashCode}',
        name: re.exerciseName,
        category: re.category,
        lastLog: '',
        exerciseType: re.exerciseType,
        trackingType: re.trackingType,
      );
      WorkoutManager().addExercise(ex);

      if (re.sets != null && re.sets!.isNotEmpty) {
        try {
          final List<dynamic> parsedSets = jsonDecode(re.sets!);
          final List<Map<String, int>> mappedSets = parsedSets.map((s) {
            return {
              'weight': (s['weight'] as num).toInt(),
              'reps': (s['reps'] as num).toInt(),
              'isCompleted': 0,
            };
          }).toList();

          WorkoutManager().addLogsForExercise(re.exerciseName, mappedSets);
          totalSetsCount += mappedSets.length;
        } catch (e) {
          debugPrint("Error loading prefilled sets: $e");
        }
      }
    }
    if (totalSetsCount > 0) {
      WorkoutManager().updateSets(totalSetsCount);
    }
    context.push('/active_workout');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double bottomInset = 72 + 16 + (bottomPadding > 0 ? bottomPadding * 0.6 : 8.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Track Workouts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 32,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.history,
                    color: colorScheme.onSurface,
                    size: ResponsiveHelper.w(28),
                  ),
                  onPressed: () {
                    context.push('/workout_history');
                  },
                ),
              ],
            ),
          ),
          const WorkoutButtonTop(),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              "Routines",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: BouncingButton(
                      onTap: () {
                        context.push('/create_routine');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(24), horizontal: ResponsiveHelper.w(16)),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.clipboard,
                                  color: colorScheme.primary,
                                  size: ResponsiveHelper.w(20),
                                ),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.h(12)),
                            Text(
                              "New Routine",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.sp(16),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.w(16)),
                  Expanded(
                    child: BouncingButton(
                      onTap: () {
                        context.push('/explore_routines');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(24), horizontal: ResponsiveHelper.w(16)),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: colorScheme.primary,
                                  size: ResponsiveHelper.w(18),
                                ),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.h(12)),
                            Text(
                              "Explore Routines",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.sp(16),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              "My Routines",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RoutineWithExercises>>(
              stream: DatabaseService().db.watchAllRoutinesWithExercises(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final routines = snapshot.data ?? [];
                if (routines.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveHelper.w(24.0)),
                        child: Text(
                          "No routines yet. Create one above!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveHelper.sp(16),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final item = routines[index];
                    final exercisesString = item.exercises.map((e) => e.exerciseName).join(", ");
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Dismissible(
                        key: Key('routine_${item.routine.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.shade200,
                            borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: Theme.of(dialogContext).colorScheme.surface,
                              title: Text("Delete Routine?"),
                              content: Text("Are you sure you want to delete '${item.routine.title}'? This cannot be undone."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await DatabaseService().db.deleteRoutine(item.routine.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Routine '${item.routine.title}' deleted"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: _buildRoutineTile(
                          context,
                          routine: item,
                          title: item.routine.title,
                          subtitle: exercisesString.isNotEmpty ? exercisesString : "No exercises added",
                          exerciseCount: item.exercises.length,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineTile(
    BuildContext context, {
    required RoutineWithExercises routine,
    required String title,
    required String subtitle,
    required int exerciseCount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return BouncingButton(
      onTap: () {
        _showRoutineOptions(context, routine);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16), vertical: ResponsiveHelper.h(12)),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
              ),
              child: Center(
                child: Icon(
                  Icons.assignment_outlined,
                  color: colorScheme.primary,
                  size: ResponsiveHelper.w(20),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.w(12)),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(16),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.h(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(12),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: ResponsiveHelper.w(12)),
            // Play Button
            GestureDetector(
              onTap: () {
                _startWorkoutFromRoutine(context, routine);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: ResponsiveHelper.w(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
