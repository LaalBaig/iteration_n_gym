import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/workout_button_top.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Workouts Tab Content
class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  //   final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double bottomInset = 72 + 16 + (bottomPadding > 0 ? bottomPadding * 0.6 : 8.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Track Workouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 32,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const WorkoutButtonTop(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Text(
              "Routines",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: BouncingButton(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.plus,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "New Routine",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BouncingButton(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Explore Routines",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              "My Routines",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset),
              children: [
                _buildRoutineTile(
                  context,
                  title: "Upper Body A",
                  subtitle: "Bench Press, Pull-Ups, Overhead Press, Barbell Row",
                  exerciseCount: 4,
                ),
                const SizedBox(height: 12),
                _buildRoutineTile(
                  context,
                  title: "Lower Body A",
                  subtitle: "Barbell Squat, Romanian Deadlift, Leg Press, Calf Raise",
                  exerciseCount: 4,
                ),
                const SizedBox(height: 12),
                _buildRoutineTile(
                  context,
                  title: "Core & Cardio",
                  subtitle: "Plank, Hanging Leg Raise, Ab Wheel, HIIT Run",
                  exerciseCount: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int exerciseCount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return BouncingButton(
      onTap: () {
        // Placeholder tap action
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.assignment_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Play Button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
