import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart'
    show CustomBottomNavigationBar;
import 'package:gym_app_winter/widgets/empty_exercise_screen.dart';
import 'package:gym_app_winter/widgets/exercise_tile.dart';
import 'package:gym_app_winter/widgets/floating_button.dart';
import 'package:gym_app_winter/widgets/not_found.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Exercise> get exerciseList => genEx(5);
  late List<Exercise> filteredExerciseList;
  @override
  void initState() {
    super.initState();
    filteredExerciseList = exerciseList;
  }

  void onChanged(String e) {}
  List<Exercise> genEx(int n) {
    List<Exercise> temp = [];
    temp.add(
        Exercise(
          id: "id1",
          name: "Bench Press",
          lastLog: "25th December 9:50pm",
          category: "free weights",
        ),
      );
      temp.add(
        Exercise(
          id: "id2",
          name: "Deadlift",
          lastLog: "25th December 9:50pm",
          category: "free weights",
        ),
      );
      temp.add(
        Exercise(
          id: "id3",
          name: "Dumbbell Press",
          lastLog: "20th December 9:50pm",
          category: "free weights",
        ),
      );
      temp.add(
        Exercise(
          id: "id4",
          name: "Squat",
          lastLog: "20th December 9:50pm",
          category: "free weights",
        ),
      );
      temp.add(
        Exercise(
          id: "id5",
          name: "Push-Ups",
          lastLog: "18th September",
          category: "Bodyweight",
        ),
      );
    return temp;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text('Track Exercises', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            ),
            CustomSearchBar(
              hintText: "Search For Exercise",
              controller: _controller,
              onChanged: _filterExercises,
            ),
            if(filteredExerciseList.isEmpty && _controller.text.isNotEmpty && exerciseList.isNotEmpty)
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
                        context.go('/exercise_page/${filteredExerciseList[index].name}');
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: () {
          GoRouter.of(context).go("/temp");
        },
        label: "Add Exercise",
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
