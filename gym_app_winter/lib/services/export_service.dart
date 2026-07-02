import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gym_app_winter/database/database.dart';

enum ExportFormat { csv, json }

class ExportService {
  static const _csvHeader = [
    'Workout ID',
    'Date',
    'Start Time',
    'End Time',
    'Exercise',
    'Category',
    'Set Number',
    'Weight (kg)',
    'Reps',
    'Time (s)',
    'Notes',
  ];

  static List<LogWithWorkoutAndExercise> _filterAndSort(
    List<LogWithWorkoutAndExercise> logs,
    String? exerciseName,
  ) {
    final filtered = exerciseName == null
        ? logs
        : logs.where((l) => l.log.exerciseName == exerciseName).toList();
    filtered.sort((a, b) {
      final byDate = a.workout.startTime.compareTo(b.workout.startTime);
      if (byDate != 0) return byDate;
      return a.log.setNumber.compareTo(b.log.setNumber);
    });
    return filtered;
  }

  static String _buildCsv(List<LogWithWorkoutAndExercise> logs, String? exerciseName) {
    final rows = _filterAndSort(logs, exerciseName);
    final dateFmt = DateFormat('yyyy-MM-dd');
    final timeFmt = DateFormat('HH:mm');

    final data = <List<dynamic>>[_csvHeader];
    for (final row in rows) {
      data.add([
        row.workout.id,
        dateFmt.format(row.workout.startTime),
        timeFmt.format(row.workout.startTime),
        row.workout.endTime != null ? timeFmt.format(row.workout.endTime!) : '',
        row.log.exerciseName,
        row.exercise.category,
        row.log.setNumber,
        row.log.weight,
        row.log.reps,
        row.log.time ?? '',
        row.log.notes ?? '',
      ]);
    }
    return Csv().encode(data);
  }

  static String _buildJson(List<LogWithWorkoutAndExercise> logs, String? exerciseName) {
    final rows = _filterAndSort(logs, exerciseName);

    final workoutMap = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final w = workoutMap.putIfAbsent(row.workout.id, () => {
            'workoutId': row.workout.id,
            'startTime': row.workout.startTime.toIso8601String(),
            'endTime': row.workout.endTime?.toIso8601String(),
            'description': row.workout.description,
            'exercises': <Map<String, dynamic>>[],
          });

      final exercises = w['exercises'] as List<Map<String, dynamic>>;
      var exerciseEntry = exercises.cast<Map<String, dynamic>?>().firstWhere(
            (e) => e?['name'] == row.log.exerciseName,
            orElse: () => null,
          );
      if (exerciseEntry == null) {
        exerciseEntry = {
          'name': row.log.exerciseName,
          'category': row.exercise.category,
          'notes': row.log.notes,
          'sets': <Map<String, dynamic>>[],
        };
        exercises.add(exerciseEntry);
      }
      (exerciseEntry['sets'] as List<Map<String, dynamic>>).add({
        'setNumber': row.log.setNumber,
        'weight': row.log.weight,
        'reps': row.log.reps,
        'time': row.log.time,
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'scope': exerciseName ?? 'all',
      'workouts': workoutMap.values.toList(),
    });
  }

  /// Writes the export to a temp file and opens the native share sheet.
  static Future<void> export({
    required List<LogWithWorkoutAndExercise> logs,
    required ExportFormat format,
    String? exerciseName,
  }) async {
    final content = format == ExportFormat.csv
        ? _buildCsv(logs, exerciseName)
        : _buildJson(logs, exerciseName);

    final ext = format == ExportFormat.csv ? 'csv' : 'json';
    final scopeLabel = exerciseName == null
        ? 'all_workouts'
        : exerciseName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'workout_export_${scopeLabel}_$timestamp.$ext';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Workout history export',
      ),
    );
  }
}
