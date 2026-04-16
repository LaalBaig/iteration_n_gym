import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/widgets/progress_chart.dart';

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

  final List<HistoryTile> history = [];
  // final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          minimum: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: ListView(
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
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              LogSetCard(
                exerciseName: widget.exerciseName,
                onFinish: (setData) {
                  setState(() {
                    print("setData: $setData");
                    history.add(HistoryTile(setData: setData));
                  });
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      BouncingButton(
                        onTap: () {
                          // Pass history natively in memory state since it's just a local session array
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
                    child: ListView.builder(
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
          ),
        ),
      ),
    );
  }
}
