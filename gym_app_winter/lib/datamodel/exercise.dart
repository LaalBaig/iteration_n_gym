import 'package:flutter/foundation.dart';

class Exercise {
  final String id;
  final String name;
  final String lastLog; // should have date instead of weight and reps ?
  final String category;

  Exercise({
    required this.id,
    required this.name,
    required this.lastLog,
    required this.category,
  });
}

final ValueNotifier<List<Exercise>> globalMyExercises = ValueNotifier([
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
]);
