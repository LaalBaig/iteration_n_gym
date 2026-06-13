import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/widgets/exercise_tile.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gym_app_winter/models/catalog_exercise.dart';
import 'package:gym_app_winter/state/workout_manager.dart';

class AddExerciseScreen extends StatefulWidget {
  final String mode;
  const AddExerciseScreen({super.key, this.mode = 'exercises'});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _controller = TextEditingController();
  List<CatalogExercise> exerciseList = [];
  List<CatalogExercise> filteredExerciseList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      final List<CatalogExercise> catalog = jsonList.map((json) {
        return CatalogExercise(
          id: json['id'],
          name: json['name'],
          category: json['category'],
          muscles: List<String>.from(json['muscles'] ?? []),
          exerciseType: json['exerciseType'],
          trackingType: json['trackingType'],
        );
      }).toList();

      final db = DatabaseService().db;
      // Get all exercises (both active and deleted) from database
      final dbExercises = await db.select(db.exercises).get();
      
      // Load all active custom exercises from database
      final List<CatalogExercise> customCatalog = [];
      for (final ex in dbExercises) {
        if (ex.id.startsWith('custom_')) {
          final muscles = await db.getMusclesForExercise(ex.id);
          customCatalog.add(CatalogExercise(
            id: ex.id,
            name: ex.name,
            category: ex.category,
            muscles: muscles.map((m) => m.muscle.name).toList(),
            exerciseType: ex.exerciseType,
            trackingType: ex.trackingType,
          ));
        }
      }

      final combined = [...catalog, ...customCatalog];
      
      if (mounted) {
        setState(() {
          exerciseList = combined;
          isLoading = false;
        });
        _filterExercises(_controller.text);
      }
    } catch (e) {
      debugPrint("Error loading exercises: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredExerciseList = exerciseList;
      } else {
        filteredExerciseList = exerciseList
            .where(
              (exercise) =>
                  exercise.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
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
          "Add Exercise",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBar(
              hintText: "Search Exercises",
              controller: _controller,
              onChanged: _filterExercises,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newExercise = await context.push<CatalogExercise?>('/custom');
                    if (newExercise != null && context.mounted) {
                      if (widget.mode == 'workout' || widget.mode == 'routine') {
                        context.pop(newExercise);
                      } else {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Custom exercise '${newExercise.name}' has been created"),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        context.pop(newExercise);
                      }
                    }
                  },
                  icon: Icon(Icons.add, color: colorScheme.primary),
                  label: Text(
                    "Create a custom exercise",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                itemCount: filteredExerciseList.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExerciseList[index];
                  final isCustom = exercise.id.startsWith('custom_');
                  return ExerciseTile(
                    title: exercise.name,
                    subtitle: "",
                    category: exercise.category,
                    muscleGroups: exercise.muscles,
                    isCustom: isCustom,
                    onDelete: isCustom
                        ? () async {
                            final db = DatabaseService().db;
                            await db.deleteCustomExerciseTemplate(exercise.id);
                            _loadExercises();
                          }
                        : null,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      
                      final db = DatabaseService().db;
                      final dbExercises = await db.select(db.exercises).get();
                      
                      if (widget.mode == 'exercises') {
                        // Check if an active template with the same name already exists in the database
                        final hasActiveWithName = dbExercises.any(
                          (ex) => !ex.isDeleted && ex.name.toLowerCase() == exercise.name.toLowerCase()
                        );
                        
                        if (hasActiveWithName) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${exercise.name} is already in your exercises list"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          return;
                        }
                        
                        // Check if there is a deleted exercise with this name
                        final deletedExercise = dbExercises.where(
                          (ex) => ex.isDeleted && ex.name.toLowerCase() == exercise.name.toLowerCase()
                        ).firstOrNull;
                        
                        try {
                          if (context.mounted && deletedExercise != null) {
                            final String? choice = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  title: Text(
                                    "Restore Exercise?",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  content: Text(
                                    "An exercise named '${exercise.name}' was recently deleted. "
                                    "Would you like to restore it with all its previous logs, or start completely anew?",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop("anew"),
                                      child: Text("Start New", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop("restore"),
                                      child: const Text("Restore History", style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (choice == "restore") {
                              await db.restoreExercise(deletedExercise.id);
                            } else if (choice == "anew") {
                              await db.deleteExercisePermanently(deletedExercise.id, deletedExercise.name);
                              await db.addExerciseWithMuscles(
                                ExercisesCompanion(
                                  id: Value(exercise.id),
                                  name: Value(exercise.name),
                                  category: Value(exercise.category),
                                  lastLog: const Value(""),
                                  exerciseType: Value(exercise.exerciseType),
                                  trackingType: Value(exercise.trackingType),
                                ),
                                exercise.muscles,
                              );
                            } else {
                              return; // Cancelled
                            }
                          } else {
                            // Add as normal
                            await db.addExerciseWithMuscles(
                              ExercisesCompanion(
                                id: Value(exercise.id),
                                name: Value(exercise.name),
                                category: Value(exercise.category),
                                lastLog: const Value(""),
                                exerciseType: Value(exercise.exerciseType),
                                trackingType: Value(exercise.trackingType),
                              ),
                              exercise.muscles,
                            );
                          }
                        } catch (e) {
                          debugPrint('ERROR ADDING EXERCISE: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add: $e')),
                            );
                          }
                          return;
                        }
                      } else {
                        // Workout / Routine mode
                        // If this exact exercise template is already active in the DB by ID
                        final activeExercise = dbExercises.where((ex) => !ex.isDeleted && ex.id == exercise.id).firstOrNull;
                        if (activeExercise != null) {
                          if (context.mounted) {
                            if (context.canPop()) {
                              context.pop(CatalogExercise(
                                id: activeExercise.id,
                                name: activeExercise.name,
                                category: activeExercise.category,
                                muscles: exercise.muscles,
                                exerciseType: activeExercise.exerciseType,
                                trackingType: activeExercise.trackingType,
                              ));
                            } else {
                              context.go('/');
                            }
                          }
                          return;
                        }
                        
                        // If it is deleted in the DB by ID, ask to restore it or start anew
                        final deletedExercise = dbExercises.where((ex) => ex.isDeleted && ex.id == exercise.id).firstOrNull;
                        try {
                          if (context.mounted && deletedExercise != null) {
                            final String? choice = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  title: Text(
                                    "Restore Exercise?",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  content: Text(
                                    "An exercise named '${exercise.name}' was recently deleted. "
                                    "Would you like to restore it with all its previous logs, or start completely anew?",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop("anew"),
                                      child: Text("Start New", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop("restore"),
                                      child: const Text("Restore History", style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (choice == "restore") {
                              await db.restoreExercise(deletedExercise.id);
                              if (WorkoutManager().isActive) {
                                WorkoutManager().trackRestoredExercise(deletedExercise.id);
                              }
                            } else if (choice == "anew") {
                              await db.deleteExercisePermanently(deletedExercise.id, deletedExercise.name);
                              await db.addExerciseWithMuscles(
                                ExercisesCompanion(
                                  id: Value(exercise.id),
                                  name: Value(exercise.name),
                                  category: Value(exercise.category),
                                  lastLog: const Value(""),
                                  exerciseType: Value(exercise.exerciseType),
                                  trackingType: Value(exercise.trackingType),
                                ),
                                exercise.muscles,
                              );
                              if (WorkoutManager().isActive) {
                                WorkoutManager().trackNewlyCreatedExercise(exercise.id);
                              }
                            } else {
                              return; // Cancelled
                            }
                          } else {
                            // Not in DB at all, add it as active first
                            await db.addExerciseWithMuscles(
                              ExercisesCompanion(
                                id: Value(exercise.id),
                                name: Value(exercise.name),
                                category: Value(exercise.category),
                                lastLog: const Value(""),
                                exerciseType: Value(exercise.exerciseType),
                                trackingType: Value(exercise.trackingType),
                              ),
                              exercise.muscles,
                            );
                            if (WorkoutManager().isActive) {
                              WorkoutManager().trackNewlyCreatedExercise(exercise.id);
                            }
                          }
                        } catch (e) {
                          debugPrint('ERROR ADDING EXERCISE: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add: $e')),
                            );
                          }
                          return;
                        }
                      }
                      
                      if (context.mounted) {
                        if (context.canPop()) {
                          context.pop(exercise);
                        } else {
                          context.go('/');
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
