/// Returns the volume contribution of a single logged set.
///
/// Bodyweight exercises use (bodyweightKg + additionalWeight) × reps.
/// Timed/cardio exercises return 0 — callers that need time-based volume
/// handle the [log.time] field directly.
double calcSetVolume({
  required double weight,
  required int reps,
  required String? trackingType,
  required String category,
  required String? exerciseType,
  double? bodyweightKg,
}) {
  final tType = trackingType?.toLowerCase() ?? '';
  final cat = category.toLowerCase();
  final eType = exerciseType?.toLowerCase() ?? '';

  if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
    return 0.0;
  }

  if (eType == 'bodyweight' || cat == 'bodyweight') {
    final bw = bodyweightKg ?? 0.0;
    return (bw + weight) * reps;
  }

  return weight * reps;
}
