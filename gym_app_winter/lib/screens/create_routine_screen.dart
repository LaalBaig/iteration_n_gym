import 'dart:convert';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/models/catalog_exercise.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<Exercise> _exercises = [];
  final Map<String, List<Map<String, int>>> _routineSets = {};
  bool _showHelpBanner = true;
  bool _isSaving = false;
  bool _isReordering = false;
  String? _newlyAddedExerciseId;
  GlobalKey? _newlyAddedCardKey;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    setState(() {}); // Rebuild to update Save button state
  }

  void _navigateToAddExercise() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    final result = await context.push('/add_exercise?mode=routine');
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
        setState(() {
          _exercises.add(exercise!);
          _routineSets[exercise.id] = [
            {'weight': 0, 'reps': 0, 'isCompleted': 0}
          ];
          _newlyAddedExerciseId = exercise.id;
          _newlyAddedCardKey = GlobalKey();
        });
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

  void _removeExercise(int index) {
    final exercise = _exercises[index];
    setState(() {
      _exercises.removeAt(index);
      _routineSets.remove(exercise.id);
    });
  }

  void _saveRoutine() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _exercises.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final db = DatabaseService().db;
      final exercisesMap = _exercises.map((e) {
        final map = e.toMap();
        final setsList = _routineSets[e.id] ?? [];
        map['sets'] = jsonEncode(setsList);
        return map;
      }).toList();

      await db.insertRoutine(title, exercisesMap);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Routine created successfully!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save routine: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bool isSaveEnabled = _titleController.text.trim().isNotEmpty && _exercises.isNotEmpty && !_isSaving;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Action Button
            _isReordering
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: ResponsiveHelper.sp(18),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
            // Title
            Text(
              _isReordering ? "Reorder Exercises" : "Create Routine",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: ResponsiveHelper.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            // Right Action Button
            _isReordering
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isReordering = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16), vertical: ResponsiveHelper.h(8)),
                      minimumSize: const Size(64, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : ElevatedButton(
                    onPressed: isSaveEnabled ? _saveRoutine : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaveEnabled ? colorScheme.primary : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      foregroundColor: isSaveEnabled ? colorScheme.onPrimary : (isDark ? Colors.grey[500] : Colors.grey[600]),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16), vertical: ResponsiveHelper.h(8)),
                      minimumSize: const Size(64, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return isDark ? Colors.grey[800] : Colors.grey[300];
                        }
                        return colorScheme.primary;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return isDark ? Colors.grey[600] : Colors.grey[500];
                        }
                        return colorScheme.onPrimary;
                      }),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Save",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.sp(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice Banner
            if (_showHelpBanner && !_isReordering)
              Container(
                width: double.infinity,
                color: isDark ? const Color(0xFF452B00) : const Color(0xFFFFF3CD),
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16), vertical: ResponsiveHelper.h(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Creating a Routine"),
                              content: Text(
                                "Routines are workout templates you can run repeatedly. "
                                "Give your routine a name, add some exercises, define their target sets/reps, and tap Save. "
                                "You can start a workout from any of your routines at any time.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Got it"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          "You're creating a Routine. Tap for help...",
                          style: TextStyle(
                            color: isDark ? const Color(0xFFFFE0B2) : const Color(0xFF856404),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? const Color(0xFFFFE0B2) : const Color(0xFF856404),
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _showHelpBanner = false;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Title Input
            if (!_isReordering) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: TextField(
                  controller: _titleController,
                  autofocus: false,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(28),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Routine title",
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.sp(28),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24)),
                child: Divider(height: 1, thickness: 1),
              ),
            ],

            // Content List or Empty State
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyState()
                  : _buildExercisesList(colorScheme, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(48)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.dumbbell,
              size: ResponsiveHelper.w(50),
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            SizedBox(height: ResponsiveHelper.h(16)),
            Text(
              "Get started by adding an exercise to your routine.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(16),
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            SizedBox(height: ResponsiveHelper.h(24)),
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
                      style: TextStyle(fontSize: ResponsiveHelper.sp(16), fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesList(ColorScheme colorScheme, bool isDark) {
    if (_isReordering) {
      return ReorderableListView.builder(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        itemCount: _exercises.length,
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            final item = _exercises.removeAt(oldIndex);
            _exercises.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return Material(
            key: ValueKey(exercise.id),
            color: Colors.transparent,
            child: Card(
              margin: EdgeInsets.only(bottom: 12.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
              ),
              color: colorScheme.surface,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16.0), vertical: ResponsiveHelper.h(8.0)),
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
                  child: Icon(Icons.drag_handle, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        },
      );
    }

    final theme = Theme.of(context);
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(24.0)),
      itemCount: _exercises.length + 1,
      itemBuilder: (context, index) {
        if (index == _exercises.length) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24.0)),
            child: Column(
              children: [
                SizedBox(height: ResponsiveHelper.h(16)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToAddExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                        side: BorderSide(color: colorScheme.primary, width: 1.5),
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
                          style: TextStyle(fontSize: ResponsiveHelper.sp(16), fontWeight: FontWeight.w600, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.h(12)),
                // Extra bottom spacing to allow scrolling the last exercise card to the top
                SizedBox(height: MediaQuery.of(context).size.height * 0.8),
              ],
            ),
          );
        }

        final exercise = _exercises[index];
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
          padding: EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
          child: LogSetCard(
            key: ValueKey(exercise.id),
            exerciseName: exercise.name,
            variant: variant,
            showLogButton: false,
            showCheckmark: false, // Hides checkmark column for routine template definition
            headerTitle: exercise.name,
            isHighlighted: exercise.id == _newlyAddedExerciseId,
            initialSets: _routineSets[exercise.id],
            onChanged: (newSets) {
              _routineSets[exercise.id] = newSets;
            },
            onAddSet: () {},
            onFinish: (sets) {},
            onRemove: () => _removeExercise(index),
            onReplace: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(const Duration(milliseconds: 50));
              if (!context.mounted) return;
              final result = await context.push('/add_exercise?mode=routine');
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
                  setState(() {
                    _exercises[index] = newExercise!;
                    _routineSets[newExercise.id] = _routineSets.remove(exercise.id) ?? [
                      {'weight': 0, 'reps': 0, 'isCompleted': 0}
                    ];
                  });
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
}
