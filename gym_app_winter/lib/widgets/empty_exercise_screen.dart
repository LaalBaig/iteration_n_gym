import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class EmptyExerciseScreen extends StatelessWidget {
  const EmptyExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Vital to keep it centered
        children: [
          Icon(
            Icons.fitness_center,
            color: const Color.fromARGB(255, 127, 127, 127),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
              style: TextStyle(color: AppColors.emptyText),
              "No Exercises Added Yet"),
        ],
      ),
    );
  }
}
