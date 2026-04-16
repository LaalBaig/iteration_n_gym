import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/state/workout_manager.dart';

class MinimizedWorkoutBar extends StatelessWidget {
  const MinimizedWorkoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WorkoutManager(),
      builder: (context, _) {
        final manager = WorkoutManager();
        if (!manager.isActive || !manager.isMinimized) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: GestureDetector(
            onTap: () {
              manager.maximize();
              context.push('/active_workout');
            },
            child: Container(
              height: 90,
              decoration: ShapeDecoration(
                color: context.colors.textWhite,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 45,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                   // Maximize Button
                  Container(
                    width: 74,
                    height: 74,
                    decoration: ShapeDecoration(
                      color: context.colors.backgroundGrey,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 37,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: context.colors.textBlack,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Workout Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Workout ${manager.formattedDuration}",
                              style: TextStyle(
                                color: context.colors.textBlack,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          manager.currentExerciseName,
                          style: TextStyle(
                            color: context.colors.emptyText,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Discard Button
                  GestureDetector(
                    onTap: () {
                      manager.discardWorkout();
                    },
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: ShapeDecoration(
                        color: context.colors.backgroundGrey,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 37,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
