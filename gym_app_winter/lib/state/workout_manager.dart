import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;

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

  bool get isActive => _isActive;
  bool get isMinimized => _isMinimized;
  int get elapsedSeconds => _elapsedSeconds;
  String get currentExerciseName => _currentExerciseName;
  int get setsCount => _setsCount;

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
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void addLogsForExercise(String exerciseName, List<Map<String, int>> sets) {
    _workoutLogs[exerciseName] = sets;
    notifyListeners();
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
    if (_workoutLogs.containsKey(exerciseName)) {
      final sets = _workoutLogs[exerciseName] ?? [];
      _setsCount = (_setsCount - sets.length).clamp(0, double.infinity).toInt();
      _workoutLogs.remove(exerciseName);
    }
    notifyListeners();
  }

  void replaceExercise(String oldName, String newName) {
    if (_workoutLogs.containsKey(oldName)) {
      _workoutLogs[newName] = _workoutLogs.remove(oldName)!;
    }
    if (_currentExerciseName == oldName) {
      _currentExerciseName = newName;
    }
    notifyListeners();
  }

  Future<void> finishWorkout({List<String>? exerciseOrder}) async {
    final workoutId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Save workout session
    await DatabaseService().db.insertWorkout(
      WorkoutsCompanion.insert(
        id: workoutId,
        startTime: _startTime ?? DateTime.now(),
        endTime: Value(DateTime.now()),
      ),
    );

    // Save all logs
    final keys = exerciseOrder ?? _workoutLogs.keys.toList();
    for (var exerciseName in keys) {
      final sets = _workoutLogs[exerciseName];
      if (sets == null) continue;
      for (int i = 0; i < sets.length; i++) {
        await DatabaseService().db.insertExerciseLog(
          ExerciseLogsCompanion.insert(
            workoutId: workoutId,
            exerciseName: exerciseName,
            setNumber: i + 1,
            weight: (sets[i]['weight'] ?? 0).toDouble(),
            reps: sets[i]['reps'] ?? 0,
          ),
        );
      }
    }

    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _workoutLogs.clear();
    _timer?.cancel();
    notifyListeners();
  }

  void discardWorkout() {
    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _workoutLogs.clear();
    _timer?.cancel();
    notifyListeners();
  }
}
