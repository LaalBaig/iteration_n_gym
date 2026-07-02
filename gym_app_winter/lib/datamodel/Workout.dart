import 'package:gym_app_winter/datamodel/ExerciseLog.dart';

class Workout {
  final String workoutID; // Unix timestamp
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseLog> exercises;

  Workout({
    required this.workoutID,
    required this.startTime,
    this.endTime,
    required this.exercises,
  });

  Duration? get duration => endTime?.difference(startTime);
}