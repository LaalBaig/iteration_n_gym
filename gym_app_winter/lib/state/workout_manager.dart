import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart' hide Exercise;
import 'package:drift/drift.dart' hide Column;
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:intl/intl.dart';

class WorkoutManager extends ChangeNotifier {
  static final WorkoutManager _instance = WorkoutManager._internal();
  factory WorkoutManager() => _instance;
  WorkoutManager._internal();

  bool _isActive = false;
  bool _isMinimized = false;
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  String _currentExerciseName = "No exercise";
  int _setsCount = 0;
  Timer? _timer;

  // Temporary storage for logs during an active workout
  final Map<String, List<Map<String, int>>> _workoutLogs = {};
  
  // Persisted list of exercises in the active workout
  final List<Exercise> _activeExercises = [];

  bool get isActive => _isActive;
  bool get isMinimized => _isMinimized;
  int get elapsedSeconds => _elapsedSeconds;
  String get currentExerciseName => _currentExerciseName;
  int get setsCount => _setsCount;
  List<Exercise> get activeExercises => _activeExercises;

  bool _isSetLogged(String exerciseName, Map<String, int> set) {
    final isCompleted = (set['isCompleted'] ?? 0) == 1;
    if (isCompleted) return true;

    final weight = set['weight'] ?? 0;
    final reps = set['reps'] ?? 0;

    final exercise = _activeExercises.firstWhere(
      (e) => e.name == exerciseName,
      orElse: () => Exercise(id: '', name: '', lastLog: '', category: ''),
    );

    if (exercise.id.isNotEmpty) {
      final tType = exercise.trackingType?.toLowerCase();
      final eType = exercise.exerciseType?.toLowerCase();
      final cat = exercise.category.toLowerCase();

      if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
        return weight > 0;
      } else if (eType == 'bodyweight' || cat == 'bodyweight') {
        return reps > 0;
      } else {
        return weight > 0 && reps > 0;
      }
    }

    return weight > 0 && reps > 0;
  }

  int get completedSetsCount {
    int count = 0;
    _workoutLogs.forEach((exerciseName, sets) {
      count += sets.where((set) => _isSetLogged(exerciseName, set)).length;
    });
    return count;
  }

  List<String> get completedExerciseNames {
    final list = <String>[];
    for (var entry in _workoutLogs.entries) {
      if (entry.value.any((set) => _isSetLogged(entry.key, set))) {
        list.add(entry.key);
      }
    }
    return list;
  }

  double get totalVolume {
    double volume = 0.0;
    _workoutLogs.forEach((exerciseName, sets) {
      for (var set in sets) {
        if (_isSetLogged(exerciseName, set)) {
          final w = (set['weight'] ?? 0).toDouble();
          final r = set['reps'] ?? 0;
          volume += w * r;
        }
      }
    });
    return volume;
  }

  String get formattedDuration {
    if (_elapsedSeconds < 60) return "${_elapsedSeconds}s";
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return "${minutes}m ${seconds}s";
  }

  void startWorkout() {
    if (_isActive) return;
    _isActive = true;
    _isMinimized = false;
    _startTime = DateTime.now();
    _elapsedSeconds = 0;
    _currentExerciseName = "No exercise";
    _setsCount = 0;
    _workoutLogs.clear();
    _activeExercises.clear();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void addExercise(Exercise exercise) {
    if (!_activeExercises.any((e) => e.name == exercise.name)) {
      _activeExercises.add(exercise);
      _currentExerciseName = exercise.name;
      notifyListeners();
    }
  }

  void addLogsForExercise(String exerciseName, List<Map<String, int>> sets) {
    _workoutLogs[exerciseName] = sets;
    notifyListeners();
  }

  List<Map<String, int>>? getLogsForExercise(String exerciseName) {
    return _workoutLogs[exerciseName];
  }

  void minimize() {
    _isMinimized = true;
    notifyListeners();
  }

  void maximize() {
    _isMinimized = false;
    notifyListeners();
  }

  void updateExercise(String name) {
    _currentExerciseName = name;
    notifyListeners();
  }

  void updateSets(int count) {
    _setsCount = count;
    notifyListeners();
  }

  void incrementSet() {
    _setsCount++;
    notifyListeners();
  }

  void decrementSet() {
    if (_setsCount > 0) _setsCount--;
    notifyListeners();
  }

  void removeExercise(String exerciseName) {
    _activeExercises.removeWhere((e) => e.name == exerciseName);
    if (_workoutLogs.containsKey(exerciseName)) {
      final sets = _workoutLogs[exerciseName] ?? [];
      _setsCount = (_setsCount - sets.length).clamp(0, double.infinity).toInt();
      _workoutLogs.remove(exerciseName);
    }
    if (_currentExerciseName == exerciseName) {
      _currentExerciseName = _activeExercises.isNotEmpty ? _activeExercises.last.name : "No exercise";
    }
    notifyListeners();
  }

  void replaceExercise(String oldName, Exercise newExercise) {
    final index = _activeExercises.indexWhere((e) => e.name == oldName);
    if (index != -1) {
      _activeExercises[index] = newExercise;
    }
    if (_workoutLogs.containsKey(oldName)) {
      _workoutLogs[newExercise.name] = _workoutLogs.remove(oldName)!;
    }
    if (_currentExerciseName == oldName) {
      _currentExerciseName = newExercise.name;
    }
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Exercise exercise = _activeExercises.removeAt(oldIndex);
    _activeExercises.insert(newIndex, exercise);
    notifyListeners();
  }

  Future<String> finishWorkout({List<String>? exerciseOrder}) async {
    final workoutId = DateTime.now().millisecondsSinceEpoch.toString();
    final db = DatabaseService().db;
    
    // Save workout session
    await db.insertWorkout(
      WorkoutsCompanion.insert(
        id: workoutId,
        startTime: _startTime ?? DateTime.now(),
        endTime: Value(DateTime.now()),
        isStandalone: const Value(false),
      ),
    );

    final formattedDate = DateFormat('d MMM h:mm a').format(DateTime.now());

    // Save all logs
    final keys = exerciseOrder ?? _workoutLogs.keys.toList();
    for (var exerciseName in keys) {
      final sets = _workoutLogs[exerciseName];
      if (sets == null) continue;

      final completedSets = sets.where((s) => _isSetLogged(exerciseName, s)).toList();
      if (completedSets.isEmpty) continue;

      // Save completed sets
      for (int i = 0; i < completedSets.length; i++) {
        await db.insertExerciseLog(
          ExerciseLogsCompanion.insert(
            workoutId: workoutId,
            exerciseName: exerciseName,
            setNumber: i + 1,
            weight: (completedSets[i]['weight'] ?? 0).toDouble(),
            reps: completedSets[i]['reps'] ?? 0,
          ),
        );
      }

      // Add/update exercise in individual exercise database
      final existing = await (db.select(db.exercises)..where((t) => t.name.equals(exerciseName))).getSingleOrNull();
      if (existing != null) {
        await db.addExercise(
          ExercisesCompanion(
            id: Value(existing.id),
            name: Value(existing.name),
            category: Value(existing.category),
            lastLog: Value(formattedDate),
            exerciseType: Value(existing.exerciseType),
            trackingType: Value(existing.trackingType),
            isDeleted: Value(existing.isDeleted),
          ),
        );
      } else {
        // Get active exercise metadata
        final activeEx = _activeExercises.firstWhere(
          (e) => e.name == exerciseName,
          orElse: () => Exercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${exerciseName.hashCode}',
            name: exerciseName,
            category: 'Other',
            lastLog: '',
          ),
        );
        await db.addExercise(
          ExercisesCompanion(
            id: Value(activeEx.id),
            name: Value(activeEx.name),
            category: Value(activeEx.category),
            lastLog: Value(formattedDate),
            exerciseType: Value(activeEx.exerciseType),
            trackingType: Value(activeEx.trackingType),
            isDeleted: const Value(false),
          ),
        );
      }
    }

    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _workoutLogs.clear();
    _activeExercises.clear();
    _timer?.cancel();
    notifyListeners();

    return workoutId;
  }

  void discardWorkout() {
    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _workoutLogs.clear();
    _activeExercises.clear();
    _timer?.cancel();
    notifyListeners();
  }
}

