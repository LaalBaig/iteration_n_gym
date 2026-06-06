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

  @override
  Set<Column> get primaryKey => {id};
}
class Workouts extends Table {
  TextColumn get id => text()(); // Your Unix timestamp/ID
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

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
}

@DriftDatabase(tables: [Exercises, Workouts, ExerciseLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(exercises, exercises.isDeleted);
          }
        },
      );

  // Exercise queries
  Stream<List<Exercise>> watchAllExercises() =>
      (select(exercises)..where((t) => t.isDeleted.equals(false))).watch();
  Future<List<Exercise>> getAllExercises() =>
      (select(exercises)..where((t) => t.isDeleted.equals(false))).get();
  Stream<List<Exercise>> watchRecentlyDeletedExercises() =>
      (select(exercises)..where((t) => t.isDeleted.equals(true))).watch();
  Future<Exercise?> getDeletedExerciseByName(String name) =>
      (select(exercises)..where((t) => t.name.equals(name) & t.isDeleted.equals(true))).getSingleOrNull();
  Future<int> addExercise(ExercisesCompanion entry) => into(exercises).insert(entry, mode: InsertMode.insertOrReplace);
  Future<void> deleteExercise(String id) => (delete(exercises)..where((t) => t.id.equals(id))).go();
  Future<void> softDeleteExercise(String id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(isDeleted: Value(true)),
      );
  Future<void> restoreExercise(String id) =>
      (update(exercises)..where((t) => t.id.equals(id))).write(
        const ExercisesCompanion(isDeleted: Value(false)),
      );
  Future<void> deleteExercisePermanently(String id, String name) async {
    await transaction(() async {
      await (delete(exerciseLogs)..where((t) => t.exerciseName.equals(name))).go();
      await (delete(exercises)..where((t) => t.id.equals(id))).go();
    });
  }

  // Workout queries
  Future<int> insertWorkout(WorkoutsCompanion entry) => into(workouts).insert(entry);
  
  // Log queries
  Future<int> insertExerciseLog(ExerciseLogsCompanion entry) => into(exerciseLogs).insert(entry);
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
      innerJoin(exercises, exercises.name.equalsExp(exerciseLogs.exerciseName)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return LogWithWorkoutAndExercise(
          log: row.readTable(exerciseLogs),
          workout: row.readTable(workouts),
          exercise: row.readTable(exercises),
        );
      }).toList();
    });
  }
}

class ExerciseLogWithWorkout {
  final ExerciseLog log;
  final Workout workout;

  ExerciseLogWithWorkout({required this.log, required this.workout});
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