import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

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

  void _showComingSoon(BuildContext ctx) {
    final colorScheme = Theme.of(ctx).colorScheme;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.w(20)),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.w(24),
          vertical: ResponsiveHelper.h(36),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: ResponsiveHelper.w(48),
              color: colorScheme.primary,
            ),
            SizedBox(height: ResponsiveHelper.h(16)),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(22),
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveHelper.h(8)),
            Text(
              'Workout settings are on the way.',
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(15),
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.h(24)),
          ],
        ),
      ),
    );
  }

  void _navigateToAddExercise() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    final result = await context.push('/add_exercise?mode=workout');
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
        final alreadyExists = WorkoutManager().activeExercises.any(
          (e) => e.name == exercise!.name,
        );
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
                alignment: 0.4,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        FocusScope.of(context).unfocus();
        WorkoutManager().minimize();
        MainScreen.activeTabNotifier.value = 0; // lead to workouts tab
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: GestureDetector(
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
                ? Text(
                    "Reorder Exercises",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(20),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : BouncingButton(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      WorkoutManager().minimize();
                      MainScreen.activeTabNotifier.value =
                          0; // lead to workouts tab
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: colorScheme.onSurface,
                        ),
                        SizedBox(width: ResponsiveHelper.w(8)),
                        Text(
                          "Log Workout",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: ResponsiveHelper.sp(20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
            actions: _isReordering
                ? [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.w(16.0),
                        vertical: ResponsiveHelper.h(8.0),
                      ),
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
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.w(8),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.w(16),
                          ),
                        ),
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.sp(16),
                          ),
                        ),
                      ),
                    ),
                  ]
                : [
                    const RestTimerButton(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.w(16.0),
                        vertical: ResponsiveHelper.h(8.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final manager = WorkoutManager();
                          if (manager.completedSetsCount == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Cannot finish an empty workout. Complete at least one set.",
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (!mounted) return;
                          FocusScope.of(context).unfocus();
                          context.push('/save_workout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.w(8),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.w(16),
                          ),
                        ),
                        child: Text(
                          "Finish",
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.sp(16),
                          ),
                        ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.w(24.0),
                      vertical: ResponsiveHelper.h(16.0),
                    ),
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
                          margin: EdgeInsets.only(bottom: 12.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.w(12),
                            ),
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1.0,
                            ),
                          ),
                          color: colorScheme.surface,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.w(16.0),
                              vertical: ResponsiveHelper.h(8.0),
                            ),
                            title: Text(
                              exercise.name,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.sp(16),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              exercise.category,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.sp(12),
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle,
                                color: colorScheme.onSurfaceVariant,
                              ),
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
                    Divider(
                      color: colorScheme.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    // Summary Row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.w(24.0),
                        vertical: ResponsiveHelper.h(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            "Duration",
                            manager.formattedDuration,
                            true,
                          ),
                          _buildSummaryItem(
                            "Volume",
                            "${manager.totalVolume.round()} kg",
                            false,
                          ),
                          _buildSummaryItem(
                            "Sets",
                            manager.setsCount.toString(),
                            false,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: colorScheme.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),

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
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          // Empty State Graphic
          FaIcon(
            FontAwesomeIcons.dumbbell,
            size: ResponsiveHelper.w(60),
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: ResponsiveHelper.h(24)),
          Text(
            "Get started",
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(20),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(8)),
          Text(
            "Add an exercise to start your workout",
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(16),
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          Spacer(),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToAddExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: colorScheme.onPrimary),
                  SizedBox(width: ResponsiveHelper.w(8)),
                  Text(
                    "Add Exercise",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(16),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(12)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showComingSoon(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.h(16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.w(12),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(16),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.w(12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final confirm = await showDiscardWorkoutDialog(context);
                    if (confirm == true && mounted) {
                      await WorkoutManager().discardWorkout();
                      if (mounted) {
                        context.pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.h(16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.w(12),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Discard Workout",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(16),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.h(24)),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(List<Exercise> workoutExercises) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(24.0)),
      itemCount: workoutExercises.length + 1,
      itemBuilder: (itemContext, index) {
        if (index == workoutExercises.length) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24.0)),
            child: Column(
              children: [
                SizedBox(height: ResponsiveHelper.h(16)),
                // Action Buttons below the list
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToAddExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.h(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.w(12),
                        ),
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: colorScheme.primary),
                        SizedBox(width: ResponsiveHelper.w(8)),
                        Text(
                          "Add Exercise",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(16),
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.h(12)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showComingSoon(itemContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.h(16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.w(12),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(16),
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.w(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final confirm = await showDiscardWorkoutDialog(
                            itemContext,
                          );
                          if (confirm == true && itemContext.mounted) {
                            await WorkoutManager().discardWorkout();
                            if (itemContext.mounted) {
                              itemContext.pop();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.h(16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.w(12),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Discard Workout",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(16),
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.h(24)),
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

        if (tType == 'time based' ||
            tType == 'timed' ||
            cat == 'timed' ||
            cat == 'cardio') {
          variant = LogSetCardVariant.timed;
        } else if (eType == 'bodyweight' || cat == 'bodyweight') {
          variant = LogSetCardVariant.bodyweight;
        }

        return Padding(
          key: exercise.id == _newlyAddedExerciseId ? _newlyAddedCardKey : null,
          padding: EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
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
              await Future.delayed(const Duration(milliseconds: 50));
              if (!itemContext.mounted) return;
              final result = await itemContext.push(
                '/add_exercise?mode=workout',
              );
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
                  final alreadyExists = WorkoutManager().activeExercises.any(
                    (e) => e.name == newExercise!.name,
                  );
                  if (alreadyExists) {
                    ScaffoldMessenger.of(itemContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${newExercise.name} is already in the list",
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    WorkoutManager().replaceExercise(
                      exercise.name,
                      newExercise,
                    );
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
          style: TextStyle(
            fontSize: ResponsiveHelper.sp(12),
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveHelper.h(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.sp(18),
            fontWeight: FontWeight.w600,
            color: isBlue ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
