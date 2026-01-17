import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/widgets/empty_exercise_screen.dart';
import 'package:gym_app_winter/widgets/exercise_tile.dart';
import 'package:gym_app_winter/widgets/not_found.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';

class ExercisesTab extends StatefulWidget {
  const ExercisesTab({super.key});

  @override
  State<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<ExercisesTab> {
  final TextEditingController _controller = TextEditingController();
  List<Exercise> get exerciseList => _genEx(5);
  late List<Exercise> filteredExerciseList;

  @override
  void initState() {
    super.initState();
    filteredExerciseList = exerciseList;
  }

  List<Exercise> _genEx(int n) {
    return [
      Exercise(
        id: "id1",
        name: "Bench Press",
        lastLog: "25th December 9:50pm",
        category: "free weights",
      ),
      Exercise(
        id: "id2",
        name: "Deadlift",
        lastLog: "25th December 9:50pm",
        category: "free weights",
      ),
      Exercise(
        id: "id3",
        name: "Dumbbell Press",
        lastLog: "20th December 9:50pm",
        category: "free weights",
      ),
      Exercise(
        id: "id4",
        name: "Squat",
        lastLog: "20th December 9:50pm",
        category: "free weights",
      ),
      Exercise(
        id: "id5",
        name: "Push-Ups",
        lastLog: "18th September",
        category: "Bodyweight",
      ),
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Track Exercises',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          CustomSearchBar(
            hintText: "Search For Exercise",
            controller: _controller,
            onChanged: _filterExercises,
          ),
          if (filteredExerciseList.isEmpty &&
              _controller.text.isNotEmpty &&
              exerciseList.isNotEmpty)
            NotFound(exercise: _controller.text)
          else if (filteredExerciseList.isEmpty)
            const EmptyExerciseScreen()
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredExerciseList.length,
                padding: EdgeInsets.fromLTRB(24, 0, 24, 6),
                itemBuilder: (context, index) {
                  return ExerciseTile(
                    title: filteredExerciseList[index].name,
                    subtitle: filteredExerciseList[index].lastLog,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      context.go(
                        '/exercise_page/${filteredExerciseList[index].name}',
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
}
