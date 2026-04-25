import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/widgets/progress_chart.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  void onChanged(String e) {
    print("hello world");
  }

  // Removed local session array: final List<HistoryTile> history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundGrey,
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
                return HistoryTile(
                  setData: entry.value.map((e) => {
                    'weight': e.log.weight.toInt(),
                    'reps': e.log.reps,
                  }).toList(),
                  // We could pass date here if HistoryTile supported it, but it seems hardcoded for now
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
                            color: context.colors.nearBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  LogSetCard(
                    exerciseName: widget.exerciseName,
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
                              color: context.colors.nearBlack,
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
                                  color: context.colors.primaryBlue,
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
                          ? Center(child: Text("No history yet", style: TextStyle(color: context.colors.emptyText)))
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
