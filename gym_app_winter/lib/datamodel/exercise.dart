
class Exercise {
  final String id;
  final String name;
  final String lastLog;
  final String category;
  final String? exerciseType;
  final String? trackingType;

  Exercise({
    required this.id,
    required this.name,
    required this.lastLog,
    required this.category,
    this.exerciseType,
    this.trackingType,
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastLog': lastLog,
      'category': category,
      'exerciseType': exerciseType,
      'trackingType': trackingType,
    };
  }
}
