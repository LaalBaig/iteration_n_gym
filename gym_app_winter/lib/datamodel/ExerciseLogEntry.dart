class ExerciseLogEntry {
  final int setNumber;
  final double weight;
  final int reps;
  final int? time;

  ExerciseLogEntry({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.time,
  });
}