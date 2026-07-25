import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

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
import 'package:shared_preferences/shared_preferences.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  Exercise? _exercise;
  double? _bodyweightKg;

  @override
  void initState() {
    super.initState();
    _loadExercise();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _bodyweightKg = prefs.getDouble('userBodyweightKg');
        });
      }
    });
  }

  void _loadExercise() async {
    final db = DatabaseService().db;
    final list = await (db.select(db.exercises)..where((t) => t.name.equals(widget.exerciseName))).get();
    if (list.isNotEmpty && mounted) {
      setState(() {
        _exercise = list.firstWhere((e) => !e.isDeleted, orElse: () => list.first);
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
      final tType = _exercise!.trackingType?.toLowerCase();
      final eType = _exercise!.exerciseType?.toLowerCase();
      final cat = _exercise!.category.toLowerCase();

      if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
        variant = LogSetCardVariant.timed;
      } else if (eType == 'bodyweight' || cat == 'bodyweight') {
        variant = LogSetCardVariant.bodyweight;
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
              
              // Compute all-time maxes for history PR badges
              Map<int, int> repMaxes = {};
              int maxBodyweightReps = 0;
              int maxTimeSeconds = 0;
              
              for (var log in logs) {
                if (variant == LogSetCardVariant.weighted) {
                  if (log.log.reps > 0 && log.log.weight > 0) {
                    int currentMax = repMaxes[log.log.reps] ?? 0;
                    if (log.log.weight.toInt() > currentMax) {
                      repMaxes[log.log.reps] = log.log.weight.toInt();
                    }
                  }
                } else if (variant == LogSetCardVariant.bodyweight) {
                  if (log.log.reps > maxBodyweightReps) {
                    maxBodyweightReps = log.log.reps;
                  }
                } else if (variant == LogSetCardVariant.timed) {
                  final logTime = log.log.time ?? log.log.weight.toInt();
                  if (logTime > maxTimeSeconds) {
                    maxTimeSeconds = logTime;
                  }
                }
              }

              // Group logs by workoutId
              final Map<String, List<ExerciseLogWithWorkout>> groupedLogs = {};
              for (var log in logs) {
                groupedLogs.putIfAbsent(log.log.workoutId, () => []).add(log);
              }

              // Create HistoryTiles from grouped logs
              final List<HistoryTile> history = groupedLogs.entries.map((entry) {
                final workout = entry.value.first.workout;
                final set1 = entry.value.firstWhere(
                  (e) => e.log.setNumber == 1,
                  orElse: () => entry.value.first,
                );
                return HistoryTile(
                  setData: entry.value.map((e) {
                    int isPR = 0;
                    if (variant == LogSetCardVariant.weighted) {
                      if (e.log.reps > 0 && e.log.weight.toInt() == repMaxes[e.log.reps]) {
                        isPR = 1;
                      }
                    } else if (variant == LogSetCardVariant.bodyweight) {
                      if (e.log.reps > 0 && e.log.reps == maxBodyweightReps) {
                        isPR = 1;
                      }
                    } else if (variant == LogSetCardVariant.timed) {
                      final logTime = e.log.time ?? e.log.weight.toInt();
                      if (logTime > 0 && logTime == maxTimeSeconds) {
                        isPR = 1;
                      }
                    }
                    return {
                      'weight': e.log.weight.toInt(),
                      'reps': e.log.reps,
                      'time': e.log.time ?? e.log.weight.toInt(),
                      'isPR': isPR,
                    };
                  }).toList(),
                  variant: variant,
                  workoutId: entry.key,
                  date: workout.startTime,
                  isWorkout: !workout.isStandalone,
                  note: set1.log.notes,
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
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(12, 6, 0, 6),
                          child: Builder(
                            builder: (context) {
                              final titleLen = widget.exerciseName.length;
                              final hasLongWord = widget.exerciseName.split(' ').any((word) => word.length > 13);
                              
                              double fontSize = 24;
                              if (titleLen > 24) {
                                fontSize = 16;
                              } else if (titleLen > 18 || hasLongWord) {
                                fontSize = 18;
                              } else if (titleLen > 12) {
                                fontSize = 22;
                              }

                              return Text(
                                widget.exerciseName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: fontSize,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ),
                      const RestTimerButton(),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.h(24)),
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
                          isStandalone: const Value(true),
                        ),
                      );

                      // Insert each set
                      for (int i = 0; i < setData.length; i++) {
                        await DatabaseService().db.insertExerciseLog(
                          ExerciseLogsCompanion.insert(
                            workoutId: workoutId,
                            exerciseName: widget.exerciseName,
                            setNumber: i + 1,
                            weight: ((setData[i]['weight'] as int?) ?? 0).toDouble(),
                            reps: (setData[i]['reps'] as int?) ?? 0,
                            time: setData[i].containsKey('time') ? Value(setData[i]['time'] as int?) : const Value.absent(),
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
                          exerciseType: Value(exercise.exerciseType),
                          trackingType: Value(exercise.trackingType),
                        ),
                      );
                    },
                    onAddSet: () {},
                  ),
                  SizedBox(height: ResponsiveHelper.h(24)),
                  ProgressChart(
                    history: history,
                    variant: variant,
                    bodyweightKg: _bodyweightKg,
                    initialMetric: variant == LogSetCardVariant.timed
                        ? 'Time'
                        : variant == LogSetCardVariant.bodyweight
                            ? 'Reps'
                            : 'Volume',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveHelper.h(24)),
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
                              padding: EdgeInsets.fromLTRB(12, 6, 0, 0),
                              child: Text(
                                "See All",
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.sp(16),
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.h(12)),
                      SizedBox(
                        height: history.any((t) => t.note != null && t.note!.isNotEmpty) ? 320 : 280,
                        child: history.isEmpty
                          ? Center(child: Text("No history yet", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 300,
                                  padding: EdgeInsets.only(right: 16),
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
