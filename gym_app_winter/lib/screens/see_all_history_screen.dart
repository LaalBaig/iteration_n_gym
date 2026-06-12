import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';

class SeeAllHistoryScreen extends StatefulWidget {
  final String exerciseName;

  const SeeAllHistoryScreen({
    super.key,
    required this.exerciseName,
  });

  @override
  State<SeeAllHistoryScreen> createState() => _SeeAllHistoryScreenState();
}

class _SeeAllHistoryScreenState extends State<SeeAllHistoryScreen> {
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
        _exercise = list.firstWhere((e) => !e.isDeleted, orElse: () => list.first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return Scaffold(
        backgroundColor: context.colors.backgroundGrey,
        appBar: AppBar(
          title: Text(
            "${widget.exerciseName} History",
            style: TextStyle(
              color: context.colors.textBlack,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: context.colors.backgroundGrey,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: BouncingButton(
            onTap: () => context.pop(),
            child: Icon(Icons.arrow_back, color: context.colors.textBlack),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    LogSetCardVariant variant = LogSetCardVariant.weighted;
    final tType = _exercise!.trackingType?.toLowerCase();
    final eType = _exercise!.exerciseType?.toLowerCase();
    final cat = _exercise!.category.toLowerCase();

    if (tType == 'time based' || tType == 'timed' || cat == 'timed' || cat == 'cardio') {
      variant = LogSetCardVariant.timed;
    } else if (eType == 'bodyweight' || cat == 'bodyweight') {
      variant = LogSetCardVariant.bodyweight;
    }

    return Scaffold(
      backgroundColor: context.colors.backgroundGrey,
      appBar: AppBar(
        title: Text(
          "${widget.exerciseName} History",
          style: TextStyle(
            color: context.colors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: context.colors.backgroundGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BouncingButton(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back, color: context.colors.textBlack),
        ),
      ),
      body: StreamBuilder<List<ExerciseLogWithWorkout>>(
        stream: DatabaseService().db.watchLogsWithWorkoutForExercise(widget.exerciseName),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting && logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

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
              isWorkout: !workout.isStandalone,
            );
          }).toList();

          if (history.isEmpty) {
            return Center(
              child: Text(
                "No logs recorded yet.",
                style: TextStyle(color: context.colors.emptyText, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: history[index],
              );
            },
          );
        },
      ),
    );
  }
}
