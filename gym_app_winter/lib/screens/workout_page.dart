import 'package:flutter/material.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart'
    show CustomBottomNavigationBar;
import 'package:gym_app_winter/widgets/search_bar.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => WorkoutPageState();
}

class WorkoutPageState extends State<WorkoutPage> {
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  'Track Workouts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              CustomSearchBar(
                hintText: "Start A New Workout",
                controller: _controller,
                onChanged: _filterExercises,
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1, onTabChanged: (int p1) {  },),
      ),
    );
  }
}
