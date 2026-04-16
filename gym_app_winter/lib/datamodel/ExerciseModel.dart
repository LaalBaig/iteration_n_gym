import 'package:gym_app_winter/datamodel/enums.dart';

class ExerciseModel {
  final String name;
  final ExerciseCategory category;
  final ExerciseType type;
  final String notes;

  ExerciseModel({
    required this.name,
    required this.category,
    required this.type,
    this.notes = '',
  });
}