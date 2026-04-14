import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/exercise_tile.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Exercise> get exerciseList => _genEx();
  late List<Exercise> filteredExerciseList;

  @override
  void initState() {
    super.initState();
    filteredExerciseList = exerciseList;
  }

  List<Exercise> _genEx() {
    return [
      Exercise(id: "id1", name: "Bench Press", lastLog: "", category: "Chest"),
      Exercise(id: "id2", name: "Deadlift", lastLog: "", category: "Back"),
      Exercise(id: "id3", name: "Dumbbell Press", lastLog: "", category: "Chest"),
      Exercise(id: "id4", name: "Squat", lastLog: "", category: "Legs"),
      Exercise(id: "id5", name: "Push-Ups", lastLog: "", category: "Bodyweight"),
      Exercise(id: "id6", name: "Pull-Ups", lastLog: "", category: "Bodyweight"),
      Exercise(id: "id7", name: "Bicep Curls", lastLog: "", category: "Arms"),
      Exercise(id: "id8", name: "Tricep Extensions", lastLog: "", category: "Arms"),
    ];
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
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        backgroundColor: AppColors.textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          "Add Exercise",
          style: TextStyle(
            color: AppColors.textBlack,
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
                  onPressed: () {
                    // TODO: Implement create custom exercise navigation
                  },
                  icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                  label: const Text(
                    "Create a custom exercise",
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                itemCount: filteredExerciseList.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExerciseList[index];
                  return ExerciseTile(
                    title: exercise.name,
                    subtitle: exercise.category,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppColors.textWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "Confirm adding exercises",
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to add ${exercise.name}?",
                              style: const TextStyle(
                                color: AppColors.emptyText,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: AppColors.emptyText),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.textWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Add"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true && context.mounted) {
                        // Add the exercise to the global state
                        globalMyExercises.value = List.from(globalMyExercises.value)..add(exercise);
                        // Navigate back to the main screen
                        context.go('/');
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
