import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class NotFound extends StatelessWidget {
  final String exercise;
  const NotFound({super.key, required this.exercise});

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
          Text(
              style: TextStyle(color: context.colors.emptyText),
              "No results for $exercise"),
        ],
      ),
    );
  }
}