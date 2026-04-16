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
  AppDatabase() : super(_openConnection()); // It looks for the function here

  @override
  int get schemaVersion => 1;
}

// THIS FUNCTION MUST BE OUTSIDE THE CLASS
QueryExecutor _openConnection() {
  return SqfliteQueryExecutor.inDatabaseFolder(path: 'db.sqlite');
}