import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
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
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 6),
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
              onAddSet: () {},
              onFinish: () {},
            ),
          ],
        ),
      ),
    );
  }
}
