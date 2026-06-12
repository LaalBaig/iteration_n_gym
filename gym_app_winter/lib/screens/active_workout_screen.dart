import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/models/catalog_exercise.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/state/workout_manager.dart';
import 'package:gym_app_winter/screens/main_screen.dart';
import 'package:gym_app_winter/widgets/rest_timer_button.dart';
import 'package:gym_app_winter/widgets/discard_workout_dialog.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  bool _isReordering = false;
  final ScrollController _scrollController = ScrollController();
  String? _newlyAddedExerciseId;
  GlobalKey? _newlyAddedCardKey;

  void _navigateToAddExercise() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await context.push('/add_exercise');
    if (result != null) {
      Exercise? exercise;
      if (result is Exercise) {
        exercise = result;
      } else if (result is CatalogExercise) {
        exercise = Exercise(
          id: result.id,
          name: result.name,
          category: result.category,
          lastLog: '',
          exerciseType: result.exerciseType,
          trackingType: result.trackingType,
        );
      }
      if (exercise != null) {
        final alreadyExists = WorkoutManager().activeExercises.any((e) => e.name == exercise!.name);
        if (alreadyExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${exercise.name} is already in the list"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() {
            _newlyAddedExerciseId = exercise!.id;
            _newlyAddedCardKey = GlobalKey();
          });
          WorkoutManager().addExercise(exercise);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_newlyAddedCardKey?.currentContext != null) {
              Scrollable.ensureVisible(
                _newlyAddedCardKey!.currentContext!,
                alignment: 0.16,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            _newlyAddedExerciseId = null;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Ensure workout is started in manager if it isn't, after build
    if (!WorkoutManager().isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WorkoutManager().startWorkout();
      });
    }
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          elevation: 0,
          titleSpacing: 16,
          title: _isReordering
              ? const Text(
                  "Reorder Exercises",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              : BouncingButton(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    WorkoutManager().minimize();
                    MainScreen.activeTabNotifier.value = 0; // lead to workouts tab
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        "Log Workout",
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
          actions: _isReordering
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isReordering = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text("Done", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                ]
              : [
                  const RestTimerButton(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final manager = WorkoutManager();
                        if (manager.completedSetsCount == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cannot finish an empty workout. Complete at least one set."),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (!mounted) return;
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.push('/save_workout');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text("Finish", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                ],
        ),
        body: ListenableBuilder(
          listenable: WorkoutManager(),
          builder: (context, _) {
            final manager = WorkoutManager();
            final workoutExercises = manager.activeExercises;

            if (_isReordering) {
              return SafeArea(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  itemCount: workoutExercises.length,
                  onReorderItem: (oldIndex, newIndex) {
                    manager.reorderExercises(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final exercise = workoutExercises[index];
                    return Material(
                      key: ValueKey(exercise.id),
                      color: Colors.transparent,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
                        ),
                        color: colorScheme.surface,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          title: Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            exercise.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: Icon(Icons.drag_handle, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
                  // Summary Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem("Duration", manager.formattedDuration, true),
                        _buildSummaryItem("Volume", "${manager.totalVolume.round()} kg", false),
                        _buildSummaryItem("Sets", manager.setsCount.toString(), false),
                      ],
                    ),
                  ),
                  Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
                  
                  Expanded(
                    child: workoutExercises.isEmpty
                        ? _buildEmptyState()
                        : _buildWorkoutList(workoutExercises),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Empty State Graphic
          FaIcon(FontAwesomeIcons.dumbbell, size: 60, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            "Get started",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            "Add an exercise to start your workout",
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          
          const Spacer(),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToAddExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    "Add Exercise",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final confirm = await showDiscardWorkoutDialog(context);
                    if (confirm == true && mounted) {
                      WorkoutManager().discardWorkout();
                      context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Discard Workout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(List<Exercise> workoutExercises) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      itemCount: workoutExercises.length + 1,
      itemBuilder: (itemContext, index) {
        if (index == workoutExercises.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Action Buttons below the list
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToAddExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.primary, width: 1.5),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Add Exercise",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Settings",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final confirm = await showDiscardWorkoutDialog(itemContext);
                          if (confirm == true && itemContext.mounted) {
                            WorkoutManager().discardWorkout();
                            itemContext.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Discard Workout",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Extra bottom spacing to allow scrolling the last exercise card to the top
                SizedBox(height: MediaQuery.of(itemContext).size.height * 0.8),
              ],
            ),
          );
        }

        final exercise = workoutExercises[index];
        LogSetCardVariant variant = LogSetCardVariant.weighted;
        final tType = exercise.trackingType?.toLowerCase();
        final eType = exercise.exerciseType?.toLowerCase();
        final cat = exercise.category.toLowerCase();

        if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
          variant = LogSetCardVariant.timed;
        } else if (eType == 'bodyweight' || cat == 'bodyweight') {
          variant = LogSetCardVariant.bodyweight;
        }

        return Padding(
          key: exercise.id == _newlyAddedExerciseId ? _newlyAddedCardKey : null,
          padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
          child: LogSetCard(
            key: ValueKey(exercise.id),
            exerciseName: exercise.name,
            variant: variant,
            showLogButton: false,
            headerTitle: exercise.name,
            isHighlighted: exercise.id == _newlyAddedExerciseId,
            onAddSet: () {},
            onFinish: (sets) {},
            onRemove: () {
              WorkoutManager().removeExercise(exercise.name);
            },
            onReplace: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              final result = await itemContext.push('/add_exercise');
              if (result != null) {
                Exercise? newExercise;
                if (result is Exercise) {
                  newExercise = result;
                } else if (result is CatalogExercise) {
                  newExercise = Exercise(
                    id: result.id,
                    name: result.name,
                    category: result.category,
                    lastLog: '',
                    exerciseType: result.exerciseType,
                    trackingType: result.trackingType,
                  );
                }
                if (newExercise != null) {
                  final alreadyExists = WorkoutManager().activeExercises.any((e) => e.name == newExercise!.name);
                  if (alreadyExists) {
                    ScaffoldMessenger.of(itemContext).showSnackBar(
                      SnackBar(
                        content: Text("${newExercise.name} is already in the list"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    WorkoutManager().replaceExercise(exercise.name, newExercise);
                  }
                }
              }
            },
            onReorder: () {
              setState(() {
                _isReordering = true;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, String value, bool isBlue) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isBlue ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
