import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:go_router/go_router.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/state/workout_manager.dart';

class WorkoutButtonTop extends StatelessWidget {
  const WorkoutButtonTop({super.key});

  void _showActiveWorkoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.w(28)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.w(24),
              vertical: ResponsiveHelper.h(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You have a workout in progress",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(20),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.h(12)),
                Text(
                  "If you start a new workout, your old workout will be permanently deleted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(15),
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.h(24)),

                // Resume Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      WorkoutManager().maximize();
                      context.push('/active_workout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.w(12),
                        ),
                      ),
                    ),
                    child: Text(
                      "Resume workout in progress",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.sp(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.h(12)),

                // Start New Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await WorkoutManager().discardWorkout();
                      WorkoutManager().startWorkout();
                      if (context.mounted) {
                        context.push('/active_workout');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.w(12),
                        ),
                      ),
                    ),
                    child: Text(
                      "Start new workout",
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.sp(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.h(12)),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.w(12),
                        ),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.sp(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 12, 24, 16),
      child: BouncingButton(
        onTap: () {
          if (WorkoutManager().isActive) {
            _showActiveWorkoutDialog(context);
          } else {
            WorkoutManager().startWorkout();
            context.push('/active_workout');
          }
        },
        child: Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 12,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.w(16)),
                  child: Text(
                    "Start New Workout",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(18),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
