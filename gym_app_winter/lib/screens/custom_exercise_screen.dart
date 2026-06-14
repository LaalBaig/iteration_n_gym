import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:gym_app_winter/models/catalog_exercise.dart';
import 'package:gym_app_winter/state/workout_manager.dart';

class CustomExerciseScreen extends StatefulWidget {
  const CustomExerciseScreen({super.key});

  @override
  State<CustomExerciseScreen> createState() => _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends State<CustomExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedExerciseType = 'Weights'; 
  String _selectedTrackingType = 'Weight based'; 
  
  final List<String> _commonMuscles = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio', 
    'Triceps', 'Biceps', 'Lats', 'Glutes', 'Hamstrings', 'Quads', 'Front Delt'
  ];
  final Set<String> _selectedMuscles = {};
  bool _showAdvancedOptions = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String title, String groupValue, ValueChanged<String> onChanged, {bool enabled = true}) {
    final isSelected = title == groupValue;
    final colorScheme = Theme.of(context).colorScheme;
    
    final Color backgroundColor = !enabled 
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : (isSelected ? colorScheme.primary : colorScheme.surface);
        
    final Color borderColor = !enabled
        ? colorScheme.outlineVariant.withValues(alpha: 0.5)
        : (isSelected ? colorScheme.primary : colorScheme.outlineVariant);
        
    final Color textColor = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.3)
        : (isSelected ? colorScheme.onPrimary : colorScheme.onSurface);

    final Widget buttonChild = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );

    return Expanded(
      child: enabled
          ? BouncingButton(
              onTap: () => onChanged(title),
              child: buttonChild,
            )
          : buttonChild,
    );
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
              context.go('/add');
            }
          },
        ),
        title: Text(
          "Create Custom Exercise",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter an exercise name"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_selectedMuscles.isEmpty) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select at least one muscle group"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                
                final localContext = context;
                
                setState(() {
                  _isSaving = true;
                });
                
                final db = DatabaseService().db;
                
                try {
                  // Check if exercise name already exists (case-insensitive)
                  final String jsonString = await rootBundle.loadString('assets/exercises.json');
                  final List<dynamic> jsonList = jsonDecode(jsonString);
                  final isDuplicateAsset = jsonList.any((json) =>
                      (json['name'] as String).trim().toLowerCase() == name.toLowerCase());

                  final dbExercises = await db.select(db.exercises).get();
                  final isDuplicateDb = dbExercises.any((ex) =>
                      !ex.isDeleted && ex.name.trim().toLowerCase() == name.toLowerCase());

                  if (isDuplicateAsset || isDuplicateDb) {
                    if (!localContext.mounted) return;
                    setState(() {
                      _isSaving = false;
                    });
                    ScaffoldMessenger.of(localContext).clearSnackBars();
                    ScaffoldMessenger.of(localContext).showSnackBar(
                      SnackBar(
                        content: Text("An exercise named '$name' already exists"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                  await db.addExerciseWithMuscles(
                    ExercisesCompanion(
                      id: Value(id),
                      name: Value(name),
                      category: Value(_selectedMuscles.isNotEmpty ? _selectedMuscles.first : 'Custom'),
                      lastLog: const Value(""),
                      exerciseType: Value(_selectedExerciseType),
                      trackingType: Value(_selectedTrackingType),
                    ),
                    _selectedMuscles.toList(),
                  );

                  if (WorkoutManager().isActive) {
                    WorkoutManager().trackNewlyCreatedExercise(id);
                  }

                  if (!localContext.mounted) return;
                  final newExercise = CatalogExercise(
                    id: id,
                    name: name,
                    category: _selectedMuscles.isNotEmpty ? _selectedMuscles.first : 'Custom',
                    muscles: _selectedMuscles.toList(),
                    exerciseType: _selectedExerciseType,
                    trackingType: _selectedTrackingType,
                  );
                  if (localContext.canPop()) {
                    localContext.pop(newExercise);
                  } else {
                    localContext.go('/');
                  }
                } catch (e) {
                  if (!localContext.mounted) return;
                  setState(() {
                    _isSaving = false;
                  });
                  ScaffoldMessenger.of(localContext).clearSnackBars();
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    SnackBar(content: Text("Failed to save exercise: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Add custom exercise",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Name of the new exercise"),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: "E.g. Bulgarian Split Squat",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              
              _buildSectionTitle("Exercise Type"),
              Row(
                children: [
                  _buildChoiceButton(
                    'Bodyweight', 
                    _selectedExerciseType, 
                    (val) => setState(() => _selectedExerciseType = val),
                    enabled: _selectedTrackingType != 'Time based',
                  ),
                  _buildChoiceButton(
                    'Weights', 
                    _selectedExerciseType, 
                    (val) => setState(() => _selectedExerciseType = val),
                    enabled: _selectedTrackingType != 'Time based',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              BouncingButton(
                onTap: () {
                  setState(() {
                    _showAdvancedOptions = !_showAdvancedOptions;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Advanced Options",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _showAdvancedOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showAdvancedOptions) ...[
                _buildSectionTitle("Time-based?"),
                Row(
                  children: [
                    _buildChoiceButton(
                      'Yes', 
                      _selectedTrackingType == 'Time based' ? 'Yes' : 'No', 
                      (val) => setState(() => _selectedTrackingType = 'Time based'),
                    ),
                    _buildChoiceButton(
                      'No', 
                      _selectedTrackingType == 'Time based' ? 'Yes' : 'No', 
                      (val) => setState(() => _selectedTrackingType = 'Weight based'),
                    ),
                  ],
                ),
              ],
              
              _buildSectionTitle("Target Muscles *"),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _commonMuscles.map((muscle) {
                  final isSelected = _selectedMuscles.contains(muscle);
                  return FilterChip(
                    label: Text(
                      muscle,
                      style: TextStyle(
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMuscles.add(muscle);
                        } else {
                          _selectedMuscles.remove(muscle);
                        }
                      });
                    },
                    selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.primary,
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              // Spacing so content doesn't get hidden behind the floating button when scrolling to the very bottom
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}