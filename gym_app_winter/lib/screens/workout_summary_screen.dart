import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/screens/main_screen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final String workoutId;
  final String duration;
  final int exerciseCount;
  final int setsCount;
  final List<String> exercises;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutId,
    required this.duration,
    required this.exerciseCount,
    required this.setsCount,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24.0), vertical: ResponsiveHelper.h(16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 1),
              
              // Celebratory Icon and Title
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: ResponsiveHelper.w(64),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(24)),
              Text(
                "Workout Complete!",
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(28),
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(8)),
              Text(
                "Awesome job finishing your workout today!",
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(15),
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              Spacer(flex: 1),

              // Stats Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: "Duration",
                      value: duration,
                      icon: Icons.timer_outlined,
                      iconColor: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.w(12)),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: "Exercises",
                      value: exerciseCount.toString(),
                      icon: Icons.fitness_center_outlined,
                      iconColor: Colors.amber[700]!,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.w(12)),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: "Sets Logged",
                      value: setsCount.toString(),
                      icon: Icons.layers_outlined,
                      iconColor: Colors.blue[600]!,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.h(32)),

              // Completed Exercises List Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Exercises Performed",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(18),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(12)),

              // Completed Exercises List
              Expanded(
                flex: 4,
                child: exercises.isEmpty
                    ? Center(
                        child: Text(
                          "No exercises logged.",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exerciseName = exercises[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            color: colorScheme.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.done,
                                  size: ResponsiveHelper.w(18),
                                  color: colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                exerciseName,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.sp(16),
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(height: ResponsiveHelper.h(24)),

              // Action button
              SizedBox(
                width: double.infinity,
                child: BouncingButton(
                  onTap: () {
                    MainScreen.activeTabNotifier.value = 0; // Workouts Tab
                    context.go('/');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(16)),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
                    ),
                    child: Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(16),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(16), horizontal: ResponsiveHelper.w(8)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: ResponsiveHelper.w(24)),
          SizedBox(height: ResponsiveHelper.h(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(18),
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.h(4)),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(11),
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
