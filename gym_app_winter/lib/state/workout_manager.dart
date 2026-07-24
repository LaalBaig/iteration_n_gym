import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart' hide Exercise;
import 'package:drift/drift.dart' hide Column;
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/utils/volume_utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Map<String, List<Map<String, dynamic>>> _workoutLogs = {};

  // Per-exercise notes for the current workout
  final Map<String, String> _exerciseNotes = {};
  
  // Persisted list of exercises in the active workout
  final List<Exercise> _activeExercises = [];

  // Track IDs of exercises added to database during the current workout session
  final List<String> _newlyCreatedExerciseIds = [];
  final List<String> _restoredExerciseIds = [];

  double? _bodyweightKg;

  bool get isActive => _isActive;
  bool get isMinimized => _isMinimized;
  DateTime? get startTime => _startTime;
  int get elapsedSeconds => _elapsedSeconds;
  String get currentExerciseName => _currentExerciseName;
  int get setsCount => _setsCount;
  List<Exercise> get activeExercises => _activeExercises;
  List<String> get newlyCreatedExerciseIds => _newlyCreatedExerciseIds;
  List<String> get restoredExerciseIds => _restoredExerciseIds;

  void trackNewlyCreatedExercise(String id) {
    if (!_newlyCreatedExerciseIds.contains(id)) {
      _newlyCreatedExerciseIds.add(id);
    }
  }

  void trackRestoredExercise(String id) {
    if (!_restoredExerciseIds.contains(id)) {
      _restoredExerciseIds.add(id);
    }
  }

  bool _isSetLogged(String exerciseName, Map<String, dynamic> set) {
    final isCompleted = ((set['isCompleted'] as int?) ?? 0) == 1;
    if (isCompleted) return true;

    final weight = (set['weight'] as int?) ?? 0;
    final reps = (set['reps'] as int?) ?? 0;
    final time = (set['time'] as int?) ?? 0;

    final exercise = _activeExercises.firstWhere(
      (e) => e.name == exerciseName,
      orElse: () => Exercise(id: '', name: '', lastLog: '', category: ''),
    );

    if (exercise.id.isNotEmpty) {
      final tType = exercise.trackingType?.toLowerCase();
      final eType = exercise.exerciseType?.toLowerCase();
      final cat = exercise.category.toLowerCase();

      if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
        return time > 0 || weight > 0;
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
      final exercise = _activeExercises.firstWhere(
        (e) => e.name == exerciseName,
        orElse: () => Exercise(id: '', name: '', lastLog: '', category: ''),
      );
      for (var set in sets) {
        if (_isSetLogged(exerciseName, set)) {
          volume += calcSetVolume(
            weight: ((set['weight'] as int?) ?? 0).toDouble(),
            reps: (set['reps'] as int?) ?? 0,
            trackingType: exercise.trackingType,
            category: exercise.category,
            exerciseType: exercise.exerciseType,
            bodyweightKg: _bodyweightKg,
          );
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
    _exerciseNotes.clear();
    _activeExercises.clear();
    _newlyCreatedExerciseIds.clear();
    _restoredExerciseIds.clear();

    SharedPreferences.getInstance().then((prefs) {
      _bodyweightKg = prefs.getDouble('userBodyweightKg');
    });

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

  void addLogsForExercise(String exerciseName, List<Map<String, dynamic>> sets) {
    _workoutLogs[exerciseName] = sets;
    notifyListeners();
  }

  List<Map<String, dynamic>>? getLogsForExercise(String exerciseName) {
    return _workoutLogs[exerciseName];
  }

  void setNoteForExercise(String exerciseName, String note) {
    _exerciseNotes[exerciseName] = note;
  }

  String getNoteForExercise(String exerciseName) {
    return _exerciseNotes[exerciseName] ?? '';
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
    _exerciseNotes.remove(exerciseName);
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
    if (_exerciseNotes.containsKey(oldName)) {
      _exerciseNotes[newExercise.name] = _exerciseNotes.remove(oldName)!;
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

  Future<String> finishWorkout({
    List<String>? exerciseOrder,
    DateTime? customStartTime,
    DateTime? customEndTime,
    String? description,
  }) async {
    final workoutId = DateTime.now().millisecondsSinceEpoch.toString();
    final db = DatabaseService().db;
    
    final start = customStartTime ?? _startTime ?? DateTime.now();
    final end = customEndTime ?? DateTime.now();

    // Save workout session
    await db.insertWorkout(
      WorkoutsCompanion.insert(
        id: workoutId,
        startTime: start,
        endTime: Value(end),
        isStandalone: const Value(false),
        description: Value(description),
      ),
    );

    final formattedDate = DateFormat('d MMM h:mm a').format(end);

    // Save all logs
    final keys = exerciseOrder ?? _workoutLogs.keys.toList();
    for (var exerciseName in keys) {
      final sets = _workoutLogs[exerciseName];
      if (sets == null) continue;

      final completedSets = sets.where((s) => _isSetLogged(exerciseName, s)).toList();
      if (completedSets.isEmpty) continue;

      final exerciseNote = _exerciseNotes[exerciseName];
      // Save completed sets
      for (int i = 0; i < completedSets.length; i++) {
        await db.insertExerciseLog(
          ExerciseLogsCompanion.insert(
            workoutId: workoutId,
            exerciseName: exerciseName,
            setNumber: i + 1,
            weight: ((completedSets[i]['weight'] as int?) ?? 0).toDouble(),
            reps: (completedSets[i]['reps'] as int?) ?? 0,
            time: completedSets[i].containsKey('time') ? Value(completedSets[i]['time'] as int?) : const Value.absent(),
            notes: i == 0 ? Value(exerciseNote?.isNotEmpty == true ? exerciseNote : null) : const Value.absent(),
          ),
        );
      }

      // Add/update exercise in individual exercise database
      final existingList = await (db.select(db.exercises)..where((t) => t.name.equals(exerciseName))).get();
      final existing = existingList.isEmpty 
          ? null 
          : existingList.firstWhere((e) => !e.isDeleted, orElse: () => existingList.first);
      if (existing != null) {
        // Backfill exerciseType/trackingType from the active session's exercise
        // if the stored row predates that metadata (e.g. logged before the
        // bodyweight-volume feature existed and never updated since).
        final activeEx = _activeExercises.firstWhere(
          (e) => e.name == exerciseName,
          orElse: () => Exercise(id: '', name: '', lastLog: '', category: ''),
        );
        await db.addExercise(
          ExercisesCompanion(
            id: Value(existing.id),
            name: Value(existing.name),
            category: Value(existing.category),
            lastLog: Value(formattedDate),
            exerciseType: Value(existing.exerciseType ?? activeEx.exerciseType),
            trackingType: Value(existing.trackingType ?? activeEx.trackingType),
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

    // Cleanup unused newly created/restored exercises
    final completedNames = completedExerciseNames;
    for (final id in _newlyCreatedExerciseIds) {
      try {
        final exerciseList = await (db.select(db.exercises)..where((t) => t.id.equals(id))).get();
        if (exerciseList.isNotEmpty) {
          final exercise = exerciseList.first;
          if (!completedNames.contains(exercise.name)) {
            await db.deleteExercisePermanently(exercise.id, exercise.name);
          }
        }
      } catch (e) {
        debugPrint("Error cleaning up newly created exercise: $e");
      }
    }

    for (final id in _restoredExerciseIds) {
      try {
        final exerciseList = await (db.select(db.exercises)..where((t) => t.id.equals(id))).get();
        if (exerciseList.isNotEmpty) {
          final exercise = exerciseList.first;
          if (!completedNames.contains(exercise.name)) {
            await db.softDeleteExercise(exercise.id);
          }
        }
      } catch (e) {
        debugPrint("Error cleaning up restored exercise: $e");
      }
    }

    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _workoutLogs.clear();
    _exerciseNotes.clear();
    _activeExercises.clear();
    _newlyCreatedExerciseIds.clear();
    _restoredExerciseIds.clear();
    _timer?.cancel();
    notifyListeners();

    return workoutId;
  }

  Future<void> discardWorkout() async {
    final db = DatabaseService().db;

    // 1. Delete newly created exercises permanently
    for (final id in _newlyCreatedExerciseIds) {
      try {
        final exerciseList = await (db.select(db.exercises)..where((t) => t.id.equals(id))).get();
        if (exerciseList.isNotEmpty) {
          final exercise = exerciseList.first;
          await db.deleteExercisePermanently(exercise.id, exercise.name);
        }
      } catch (e) {
        debugPrint("Error deleting newly created exercise during discard: $e");
      }
    }

    // 2. Soft-delete restored exercises back to deleted state
    for (final id in _restoredExerciseIds) {
      try {
        await db.softDeleteExercise(id);
      } catch (e) {
        debugPrint("Error soft-deleting restored exercise during discard: $e");
      }
    }

    _isActive = false;
    _isMinimized = false;
    _setsCount = 0;
    _currentExerciseName = "No exercise";
    _workoutLogs.clear();
    _exerciseNotes.clear();
    _activeExercises.clear();
    _newlyCreatedExerciseIds.clear();
    _restoredExerciseIds.clear();
    _timer?.cancel();
    notifyListeners();
  }
}

