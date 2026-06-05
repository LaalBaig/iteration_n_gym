import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/exercise_tile.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;

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
      Exercise(id: "id9", name: "Plank", lastLog: "", category: "Timed"),
      Exercise(id: "id10", name: "Running", lastLog: "", category: "Cardio"),
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
      backgroundColor: context.colors.textWhite,
      appBar: AppBar(
        backgroundColor: context.colors.textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textBlack),
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
            color: context.colors.textBlack,
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
                    context.push('/custom');
                  },
                  icon: Icon(Icons.add, color: context.colors.primaryBlue),
                  label: Text(
                    "Create a custom exercise",
                    style: TextStyle(
                      color: context.colors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.textWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.colors.primaryBlue, width: 1.5),
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
                    subtitle: "",
                    category: exercise.category,
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      
                      // Add the exercise to the database
                      await DatabaseService().db.addExercise(
                        ExercisesCompanion(
                          id: Value(exercise.id),
                          name: Value(exercise.name),
                          category: Value(exercise.category),
                          lastLog: Value(exercise.lastLog),
                        ),
                      );

                      if (context.canPop()) {
                        context.pop(exercise);
                      } else {
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
