import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/widgets/progress_chart.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:gym_app_winter/widgets/rest_timer_button.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  Exercise? _exercise;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  void _loadExercise() async {
    final db = DatabaseService().db;
    final list = await (db.select(db.exercises)..where((t) => t.name.equals(widget.exerciseName))).get();
    if (list.isNotEmpty && mounted) {
      setState(() {
        _exercise = list.first;
      });
    }
  }

  void onChanged(String e) {
    print("hello world");
  }

  // Removed local session array: final List<HistoryTile> history = [];

  @override
  Widget build(BuildContext context) {
    LogSetCardVariant variant = LogSetCardVariant.weighted;
    if (_exercise != null) {
      if (_exercise!.category.toLowerCase() == 'bodyweight') {
        variant = LogSetCardVariant.bodyweight;
      } else if (_exercise!.category.toLowerCase() == 'timed' || _exercise!.category.toLowerCase() == 'cardio') {
        variant = LogSetCardVariant.timed;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          minimum: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: StreamBuilder<List<ExerciseLogWithWorkout>>(
            stream: DatabaseService().db.watchLogsWithWorkoutForExercise(widget.exerciseName),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              
              // Group logs by workoutId
              final Map<String, List<ExerciseLogWithWorkout>> groupedLogs = {};
              for (var log in logs) {
                groupedLogs.putIfAbsent(log.log.workoutId, () => []).add(log);
              }

              // Create HistoryTiles from grouped logs
              final List<HistoryTile> history = groupedLogs.entries.map((entry) {
                final workout = entry.value.first.workout;
                return HistoryTile(
                  setData: entry.value.map((e) => {
                    'weight': e.log.weight.toInt(),
                    'reps': e.log.reps,
                  }).toList(),
                  variant: variant,
                  workoutId: entry.key,
                  date: workout.startTime,
                );
              }).toList();

              return ListView(
                children: [
                  Row(
                    children: [
                      BouncingButton(
                        onTap: () {
                          context.pop();
                          FocusScope.of(context).unfocus();
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
                        child: Text(
                          widget.exerciseName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const RestTimerButton(),
                    ],
                  ),
                  SizedBox(height: 24),
                  LogSetCard(
                    exerciseName: widget.exerciseName,
                    variant: variant,
                    onFinish: (setData) async {
                      // Create a new workout for this log (standalone log)
                      final workoutId = DateTime.now().millisecondsSinceEpoch.toString();
                      await DatabaseService().db.insertWorkout(
                        WorkoutsCompanion.insert(
                          id: workoutId,
                          startTime: DateTime.now(),
                          endTime: Value(DateTime.now()),
                        ),
                      );

                      // Insert each set
                      for (int i = 0; i < setData.length; i++) {
                        await DatabaseService().db.insertExerciseLog(
                          ExerciseLogsCompanion.insert(
                            workoutId: workoutId,
                            exerciseName: widget.exerciseName,
                            setNumber: i + 1,
                            weight: setData[i]['weight']!.toDouble(),
                            reps: setData[i]['reps']!,
                          ),
                        );
                      }
                      
                      // Update exercise's lastLog
                      final exercises = await DatabaseService().db.getAllExercises();
                      final exercise = exercises.firstWhere(
                        (e) => e.name == widget.exerciseName,
                        orElse: () => exercises.first,
                      );
                      await DatabaseService().db.addExercise(
                        ExercisesCompanion(
                          id: Value(exercise.id),
                          name: Value(exercise.name),
                          category: Value(exercise.category),
                          lastLog: Value(DateFormat('d MMM h:mm a').format(DateTime.now())),
                        ),
                      );
                    },
                    onAddSet: () {},
                  ),
                  SizedBox(height: 24),
                  ProgressChart(history: history),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            "History",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          BouncingButton(
                            onTap: () {
                              context.push(
                                '/see_all_history/${Uri.encodeComponent(widget.exerciseName)}', 
                                extra: history
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                              child: Text(
                                "See All",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: history.isEmpty 
                          ? Center(child: Text("No history yet", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 300,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: history[index],
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
