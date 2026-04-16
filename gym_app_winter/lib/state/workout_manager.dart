import 'dart:async';
import 'package:flutter/material.dart';

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
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
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

  void finishWorkout() {
    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _timer?.cancel();
    notifyListeners();
  }

  void discardWorkout() {
    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _timer?.cancel();
    notifyListeners();
  }
}
