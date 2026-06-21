import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

part 'database.g.dart'; // This will be generated

// 1. Tables (The "Blueprints")
@DataClassName('Exercise') // This tells Drift to name the class "Exercise"
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get category => text()();
  TextColumn get lastLog => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isTracked => boolean().withDefault(const Constant(true))();
  TextColumn get exerciseType => text().nullable()();
  TextColumn get trackingType => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MuscleGroup')
class MuscleGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExerciseMuscleGroup')
class ExerciseMuscleGroups extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get muscleGroupId => text().references(MuscleGroups, #id)();
  IntColumn get role => integer()(); // 1 = Primary, 2 = Secondary, 3 = Stabilizer

  @override
  Set<Column> get primaryKey => {exerciseId, muscleGroupId};
}

class Workouts extends Table {
  TextColumn get id => text()(); // Your Unix timestamp/ID
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isStandalone => boolean().withDefault(const Constant(false))();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExerciseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workoutId => text().references(Workouts, #id)();
  TextColumn get exerciseName => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  IntColumn get time => integer().nullable()();
}

@DataClassName('Routine')
class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoutineExercise')
class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId => text().references(Routines, #id)();
  TextColumn get exerciseName => text()();
  TextColumn get category => text()();
  TextColumn get exerciseType => text().nullable()();
  TextColumn get trackingType => text().nullable()();
  IntColumn get exerciseOrder => integer()();
  TextColumn get sets => text().nullable()();
}

class RoutineWithExercises {
  final Routine routine;
  final List<RoutineExercise> exercises;

  RoutineWithExercises({required this.routine, required this.exercises});
}

@DriftDatabase(tables: [
  Exercises,
  Workouts,
  ExerciseLogs,
  MuscleGroups,
  ExerciseMuscleGroups,
  Routines,
  RoutineExercises
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(exercises, exercises.isDeleted);
          }
          if (from < 3) {
            await m.createTable(muscleGroups);
            await m.createTable(exerciseMuscleGroups);
            
            // Migrate existing categories into MuscleGroups
            final allExercises = await select(exercises).get();
            final uniqueCategories = allExercises.map((e) => e.category).toSet();
            
            final categoryToId = <String, String>{};
            var counter = 0;
            for (final category in uniqueCategories) {
              final id = '${DateTime.now().millisecondsSinceEpoch}_${counter++}';
              await into(muscleGroups).insert(MuscleGroupsCompanion.insert(
                id: id,
                name: category,
              ));
              categoryToId[category] = id;
            }
            
            for (final exercise in allExercises) {
              final muscleId = categoryToId[exercise.category];
              if (muscleId != null) {
                await into(exerciseMuscleGroups).insert(ExerciseMuscleGroupsCompanion.insert(
                  exerciseId: exercise.id,
                  muscleGroupId: muscleId,
                  role: 1, // Set migrated categories as Primary (1)
                ));
              }
            }
          }
          if (from < 4) {
            await m.addColumn(exercises, exercises.exerciseType);
            await m.addColumn(exercises, exercises.trackingType);
          }
          if (from < 5) {
            await m.addColumn(workouts, workouts.isStandalone);
          }
          if (from < 6) {
            await m.addColumn(workouts, workouts.description);
          }
          if (from < 7) {
            await m.createTable(routines);
            await m.createTable(routineExercises);
          }
          if (from < 8) {
            try {
              await m.drop(routines);
            } catch (_) {}
            try {
              await m.drop(routineExercises);
            } catch (_) {}
            await m.createTable(routines);
            await m.createTable(routineExercises);
          }
          if (from < 9) {
            try {
              await m.drop(routines);
            } catch (_) {}
            try {
              await m.drop(routineExercises);
            } catch (_) {}
            await m.createTable(routines);
            await m.createTable(routineExercises);
          }
          if (from < 10) {
            await m.addColumn(exercises, exercises.isTracked);
          }
          if (from < 11) {
            await m.addColumn(exerciseLogs, exerciseLogs.time);
            
            // Migrate existing timed exercises to use time column instead of weight
            final timedExercises = await (select(exercises)..where((t) => 
              t.category.equals('Timed') | 
              t.category.equals('Cardio') | 
              t.trackingType.equals('Time Based') | 
              t.trackingType.equals('Timed')
            )).get();
            
            final timedExerciseNames = timedExercises.map((e) => e.name).toSet().toList();
            
            if (timedExerciseNames.isNotEmpty) {
               final inClause = timedExerciseNames.map((e) => "'${e.replaceAll("'", "''")}'").join(', ');
               await customStatement(
                 'UPDATE exercise_logs SET time = CAST(weight AS INTEGER), weight = 0.0 WHERE exercise_name IN ($inClause)'
               );
            }
          }
        },
        beforeOpen: (details) async {
          final defaultIds = ['default_upper_body_a', 'default_lower_body_a', 'default_core_cardio'];
          await (delete(routineExercises)..where((t) => t.routineId.isIn(defaultIds))).go();
          await (delete(routines)..where((t) => t.id.isIn(defaultIds))).go();
        },
      );

  Stream<List<Exercise>> watchAllExercises() {
    final query = select(exercises)..where((t) {
      return t.isDeleted.equals(false) & t.isTracked.equals(true);
    });
    return query.watch();
  }

  Future<List<Exercise>> getAllExercises() {
    final query = select(exercises)..where((t) {
      return t.isDeleted.equals(false) & t.isTracked.equals(true);
    });
    return query.get();
  }

  Stream<List<Exercise>> watchRecentlyDeletedExercises() {
    final query = select(exercises)..where((t) {
      return t.isDeleted.equals(true) & t.isTracked.equals(true);
    });
    return query.watch();
  }
  Future<Exercise?> getDeletedExerciseByName(String name) async {
    final list = await (select(exercises)..where((t) => t.name.equals(name) & t.isDeleted.equals(true))).get();
    return list.isEmpty ? null : list.first;
  }
  Future<int> addExercise(ExercisesCompanion entry) => into(exercises).insert(entry, mode: InsertMode.insertOrReplace);
  
  Future<void> addExerciseWithMuscles(ExercisesCompanion entry, List<String> muscleNames) async {
    await transaction(() async {
      await into(exercises).insert(entry, mode: InsertMode.insertOrReplace);
      
      for (int i = 0; i < muscleNames.length; i++) {
        final muscleName = muscleNames[i];
        
        final existingMuscle = await (select(muscleGroups)..where((t) => t.name.equals(muscleName))).getSingleOrNull();
        String muscleId;
        
        if (existingMuscle == null) {
           muscleId = '${DateTime.now().millisecondsSinceEpoch}_${muscleName.hashCode}';
           await into(muscleGroups).insert(MuscleGroupsCompanion.insert(
             id: muscleId,
             name: muscleName,
           ));
        } else {
           muscleId = existingMuscle.id;
         }
        
        final existingMapping = await (select(exerciseMuscleGroups)
           ..where((t) => t.exerciseId.equals(entry.id.value) & t.muscleGroupId.equals(muscleId))).getSingleOrNull();
           
        if (existingMapping == null) {
           await into(exerciseMuscleGroups).insert(ExerciseMuscleGroupsCompanion.insert(
             exerciseId: entry.id.value,
             muscleGroupId: muscleId,
             role: (i == 0) ? 1 : 2,
           ));
        }
      }
    });
  }
  Future<void> deleteExercise(String id) => (delete(exercises)..where((t) => t.id.equals(id))).go();
  Future<void> softDeleteExercise(String id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(isDeleted: Value(true)),
      );
  Future<void> restoreExercise(String id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(
          isDeleted: Value(false),
          isTracked: Value(true),
        ),
      );
  Future<void> untrackCustomExercise(String id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(
          isDeleted: Value(true),
          isTracked: Value(false),
        ),
      );
  Future<void> deleteCustomExerciseTemplate(String id) async {
    await transaction(() async {
      final exercise = await (select(exercises)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (exercise != null) {
        await (update(exerciseLogs)..where((t) => t.exerciseName.equals(exercise.name))).write(
          ExerciseLogsCompanion(
            exerciseName: Value('${exercise.name} (Deleted)'),
          ),
        );
      }
      await (delete(exerciseMuscleGroups)..where((t) => t.exerciseId.equals(id))).go();
      await (delete(exercises)..where((t) => t.id.equals(id))).go();
    });
  }
  Future<void> deleteExercisePermanently(String id, String name) async {
    await transaction(() async {
      await (delete(exerciseMuscleGroups)..where((t) => t.exerciseId.equals(id))).go();
      // Rename workout history logs to prevent ghost data on recreate
      await (update(exerciseLogs)..where((t) => t.exerciseName.equals(name))).write(
        ExerciseLogsCompanion(
          exerciseName: Value('$name (Deleted)'),
        ),
      );
      await (delete(exercises)..where((t) => t.id.equals(id))).go();
    });
  }

  // Muscle Group queries
  Future<List<MuscleTarget>> getMusclesForExercise(String exerciseId) {
    final query = select(exerciseMuscleGroups).join([
      innerJoin(muscleGroups, muscleGroups.id.equalsExp(exerciseMuscleGroups.muscleGroupId)),
    ])..where(exerciseMuscleGroups.exerciseId.equals(exerciseId))
      ..orderBy([OrderingTerm.asc(exerciseMuscleGroups.role)]);

    return query.map((row) {
      return MuscleTarget(
        muscle: row.readTable(muscleGroups),
        role: row.readTable(exerciseMuscleGroups).role,
      );
    }).get();
  }

  Future<List<Exercise>> getExercisesByMuscle(String muscleGroupId, {int? specificRole}) {
    final query = select(exercises).join([
      innerJoin(exerciseMuscleGroups, exerciseMuscleGroups.exerciseId.equalsExp(exercises.id)),
    ])..where(exerciseMuscleGroups.muscleGroupId.equals(muscleGroupId));
    
    if (specificRole != null) {
      query.where(exerciseMuscleGroups.role.equals(specificRole));
    }

    return query.map((row) => row.readTable(exercises)).get();
  }

  // Workout queries
  Stream<List<Workout>> watchAllWorkouts() =>
      (select(workouts)..where((t) => t.isStandalone.equals(false))..orderBy([(t) => OrderingTerm.desc(t.startTime)])).watch();
  Future<int> insertWorkout(WorkoutsCompanion entry) => into(workouts).insert(entry);
  Future<Workout?> getWorkoutById(String workoutId) =>
      (select(workouts)..where((t) => t.id.equals(workoutId))).getSingleOrNull();
  Future<void> deleteWorkout(String workoutId) async {
    await transaction(() async {
      await (delete(exerciseLogs)..where((t) => t.workoutId.equals(workoutId))).go();
      await (delete(workouts)..where((t) => t.id.equals(workoutId))).go();
    });
  }

  Future<void> clearAllHistory() async {
    await transaction(() async {
      await delete(exerciseLogs).go();
      await delete(workouts).go();
      await (update(exercises)).write(
        const ExercisesCompanion(lastLog: Value('')),
      );
    });
  }
  Future<void> restoreWorkout(Workout workout, List<ExerciseLog> logs) async {
    await transaction(() async {
      await into(workouts).insert(workout, mode: InsertMode.insertOrReplace);
      for (final log in logs) {
        await into(exerciseLogs).insert(log, mode: InsertMode.insertOrReplace);
      }
    });
  }
  
  // Log queries
  Future<int> insertExerciseLog(ExerciseLogsCompanion entry) => into(exerciseLogs).insert(entry);
  Future<List<ExerciseLog>> getLogsForWorkout(String workoutId) =>
      (select(exerciseLogs)..where((t) => t.workoutId.equals(workoutId))).get();
  Stream<List<ExerciseLog>> watchLogsForExercise(String name) {
    return (select(exerciseLogs)..where((t) => t.exerciseName.equals(name))).watch();
  }
  Stream<List<ExerciseLogWithWorkout>> watchLogsWithWorkoutForExercise(String name) {
    final query = select(exerciseLogs).join([
      innerJoin(workouts, workouts.id.equalsExp(exerciseLogs.workoutId)),
    ]);
    query.where(exerciseLogs.exerciseName.equals(name));
    query.orderBy([OrderingTerm.desc(workouts.startTime)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExerciseLogWithWorkout(
          log: row.readTable(exerciseLogs),
          workout: row.readTable(workouts),
        );
      }).toList();
    });
  }

  Stream<List<LogWithWorkoutAndExercise>> watchAllLogsWithWorkoutAndExercise() {
    final query = select(exerciseLogs).join([
      innerJoin(workouts, workouts.id.equalsExp(exerciseLogs.workoutId)),
      leftOuterJoin(exercises, exercises.name.equalsExp(exerciseLogs.exerciseName)),
    ]);

    return query.watch().map((rows) {
      final uniqueLogsMap = <int, LogWithWorkoutAndExercise>{};
      for (final row in rows) {
        final log = row.readTable(exerciseLogs);
        final workout = row.readTable(workouts);
        final exerciseRow = row.readTableOrNull(exercises);
        final exercise = exerciseRow ?? Exercise(
          id: '',
          name: log.exerciseName,
          category: 'Other',
          lastLog: '',
          isDeleted: true,
          isTracked: false,
        );

        final existing = uniqueLogsMap[log.id];
        // Prefer the active exercise template if duplicate templates exist
        if (existing == null || (existing.exercise.isDeleted && !exercise.isDeleted)) {
          uniqueLogsMap[log.id] = LogWithWorkoutAndExercise(
            log: log,
            workout: workout,
            exercise: exercise,
          );
        }
      }
      return uniqueLogsMap.values.toList();
    });
  }

  // Routine queries
  Stream<List<RoutineWithExercises>> watchAllRoutinesWithExercises() {
    final query = select(routines).join([
      leftOuterJoin(routineExercises, routineExercises.routineId.equalsExp(routines.id)),
    ]);

    return query.watch().map((rows) {
      final map = <Routine, List<RoutineExercise>>{};
      for (final row in rows) {
        final routine = row.readTable(routines);
        final exercise = row.readTableOrNull(routineExercises);

        final list = map.putIfAbsent(routine, () => []);
        if (exercise != null) {
          list.add(exercise);
        }
      }

      return map.entries.map((entry) {
        final exercisesList = entry.value..sort((a, b) => a.exerciseOrder.compareTo(b.exerciseOrder));
        return RoutineWithExercises(
          routine: entry.key,
          exercises: exercisesList,
        );
      }).toList();
    });
  }

  Future<void> insertRoutine(String title, List<Map<String, dynamic>> exercisesList) async {
    await transaction(() async {
      final routineId = DateTime.now().millisecondsSinceEpoch.toString();
      await into(routines).insert(RoutinesCompanion.insert(
        id: routineId,
        title: title,
      ));

      for (int i = 0; i < exercisesList.length; i++) {
        final exercise = exercisesList[i];
        await into(routineExercises).insert(RoutineExercisesCompanion.insert(
          routineId: routineId,
          exerciseName: exercise['name'] as String,
          category: exercise['category'] as String,
          exerciseType: Value(exercise['exerciseType'] as String?),
          trackingType: Value(exercise['trackingType'] as String?),
          exerciseOrder: i,
          sets: Value(exercise['sets'] as String?),
        ));
      }
    });
  }

  Future<void> deleteRoutine(String routineId) async {
    await transaction(() async {
      await (delete(routineExercises)..where((t) => t.routineId.equals(routineId))).go();
      await (delete(routines)..where((t) => t.id.equals(routineId))).go();
    });
  }
}

class ExerciseLogWithWorkout {
  final ExerciseLog log;
  final Workout workout;

  ExerciseLogWithWorkout({required this.log, required this.workout});
}

class MuscleTarget {
  final MuscleGroup muscle;
  final int role;

  MuscleTarget({required this.muscle, required this.role});
}

class LogWithWorkoutAndExercise {
  final ExerciseLog log;
  final Workout workout;
  final Exercise exercise;

  LogWithWorkoutAndExercise({
    required this.log,
    required this.workout,
    required this.exercise,
  });
}

// THIS FUNCTION MUST BE OUTSIDE THE CLASS
QueryExecutor _openConnection() {
  return SqfliteQueryExecutor.inDatabaseFolder(path: 'db.sqlite');
}