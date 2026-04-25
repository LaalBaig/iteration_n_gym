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
  int get schemaVersion => 1;

  // Exercise queries
  Stream<List<Exercise>> watchAllExercises() => select(exercises).watch();
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  Future<int> addExercise(ExercisesCompanion entry) => into(exercises).insert(entry, mode: InsertMode.insertOrReplace);
  Future<void> deleteExercise(String id) => (delete(exercises)..where((t) => t.id.equals(id))).go();

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
}

class ExerciseLogWithWorkout {
  final ExerciseLog log;
  final Workout workout;

  ExerciseLogWithWorkout({required this.log, required this.workout});
}

// THIS FUNCTION MUST BE OUTSIDE THE CLASS
QueryExecutor _openConnection() {
  return SqfliteQueryExecutor.inDatabaseFolder(path: 'db.sqlite');
}