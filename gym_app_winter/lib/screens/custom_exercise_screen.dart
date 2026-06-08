import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:gym_app_winter/models/catalog_exercise.dart';

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

  Widget _buildChoiceButton(String title, String groupValue, ValueChanged<String> onChanged) {
    final isSelected = title == groupValue;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: BouncingButton(
        onTap: () => onChanged(title),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
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
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                
                final db = DatabaseService().db;
                final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                
                await db.addExerciseWithMuscles(
                  ExercisesCompanion(
                    id: Value(id),
                    name: Value(name),
                    category: Value(_selectedMuscles.isNotEmpty ? _selectedMuscles.first : 'Custom'),
                    lastLog: const Value(""),
                  ),
                  _selectedMuscles.toList(),
                );

                if (context.mounted) {
                  final newExercise = CatalogExercise(
                    id: id,
                    name: name,
                    category: _selectedMuscles.isNotEmpty ? _selectedMuscles.first : 'Custom',
                    muscles: _selectedMuscles.toList(),
                  );
                  if (context.canPop()) {
                    context.pop(newExercise);
                  } else {
                    context.go('/');
                  }
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
              child: Text(
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
                  _buildChoiceButton('Bodyweight', _selectedExerciseType, (val) => setState(() => _selectedExerciseType = val)),
                  _buildChoiceButton('Weights', _selectedExerciseType, (val) => setState(() => _selectedExerciseType = val)),
                ],
              ),
              
              _buildSectionTitle("Tracking Type"),
              Row(
                children: [
                  _buildChoiceButton('Time based', _selectedTrackingType, (val) => setState(() => _selectedTrackingType = val)),
                  _buildChoiceButton('Weight based', _selectedTrackingType, (val) => setState(() => _selectedTrackingType = val)),
                ],
              ),
              
              _buildSectionTitle("Target Muscles"),
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