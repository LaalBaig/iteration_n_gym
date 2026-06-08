class CatalogExercise {
  final String id;
  final String name;
  final String category;
  final List<String> muscles;
  final String? exerciseType;
  final String? trackingType;

  CatalogExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscles,
    this.exerciseType,
    this.trackingType,
  });
}
