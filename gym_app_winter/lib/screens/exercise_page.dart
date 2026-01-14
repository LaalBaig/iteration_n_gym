import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';

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
  final List<HistoryTile> history = [
    HistoryTile(date: "Wednesday, December 23", sets: "3", reps: "10", weight: "100"),
    HistoryTile(date: "Wednesday, October 25", sets: "3", reps: "11", weight: "105"),
  ];
  // final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  child: Icon(Icons.arrow_back),
                  onTap: () => context.pop(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
                  child: Text(
                    widget.exerciseName,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            LogSetCard(
              exerciseName: widget.exerciseName,
              onFinish: () {},
              onAddSet: () {},
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Text(
                  "History",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                  child: Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return history[index];
                },
              ),
            ),
          ],
          
        ),
      ),
    );
  }
}
