import 'package:gym_app_winter/database/database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final AppDatabase db = AppDatabase();

  // Helper methods can be added here if needed to wrap complex logic
}
