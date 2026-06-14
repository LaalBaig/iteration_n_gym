import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
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
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
            // Title
            Text(
              _isReordering ? "Reorder Exercises" : "Create Routine",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(64, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : ElevatedButton(
                    onPressed: isSaveEnabled ? _saveRoutine : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaveEnabled ? colorScheme.primary : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      foregroundColor: isSaveEnabled ? colorScheme.onPrimary : (isDark ? Colors.grey[500] : Colors.grey[600]),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(
                              fontSize: 16,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Creating a Routine"),
                              content: const Text(
                                "Routines are workout templates you can run repeatedly. "
                                "Give your routine a name, add some exercises, define their target sets/reps, and tap Save. "
                                "You can start a workout from any of your routines at any time.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Got it"),
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
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Title Input
            if (!_isReordering) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: TextField(
                  controller: _titleController,
                  autofocus: false,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Routine title",
                    hintStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.dumbbell,
              size: 50,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Get started by adding an exercise to your routine.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddExercise,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Add exercise",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        itemCount: _exercises.length,
        onReorderItem: (oldIndex, newIndex) {
          setState(() {
            final item = _exercises.removeAt(oldIndex);
            _exercises.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return Card(
            key: ValueKey("reorder_${exercise.id}"),
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: isDark ? colorScheme.surface : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.assignment_outlined,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
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
                child: Icon(
                  Icons.drag_handle,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemCount: _exercises.length + 1,
      itemBuilder: (context, index) {
        if (index == _exercises.length) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _navigateToAddExercise,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "Add Exercise",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
          padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
          child: LogSetCard(
            key: ValueKey(exercise.id),
            exerciseName: exercise.name,
            variant: variant,
            showLogButton: false,
            showCheckmark: false, // Hides checkmark column for routine template definition
            headerTitle: exercise.name,
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
