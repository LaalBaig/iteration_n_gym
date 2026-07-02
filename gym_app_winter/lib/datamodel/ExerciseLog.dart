import 'package:gym_app_winter/datamodel/ExerciseLogEntry.dart';

class ExerciseLog {
  final String exerciseName;
  final List<ExerciseLogEntry> sets;

  ExerciseLog({
    required this.exerciseName,
    required this.sets,
  });
}