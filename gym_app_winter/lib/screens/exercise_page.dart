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

  final List<HistoryTile> history = [];
  // final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          minimum: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Icon(Icons.arrow_back),
                    onTap: () {
                      context.pop();
                      FocusScope.of(context).unfocus();
                    },
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
              Expanded(
                child: ListView(
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
                    for (int i = 0; i < history.length; i++) history[i],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
