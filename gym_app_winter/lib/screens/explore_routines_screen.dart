import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/database/database_service.dart';

class ExploreRoutinesScreen extends StatelessWidget {
  const ExploreRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> exploreRoutines = [
      {
        'title': 'Full Body Beginner',
        'description': 'A great starting point for beginners to build foundational strength.',
        'exercises': [
          {'name': 'Squat', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Bench Press (Barbell)', 'category': 'Chest', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Bent Over Row (Barbell)', 'category': 'Back', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Overhead Press (Dumbbell)', 'category': 'Shoulders', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
        ]
      },
      {
        'title': 'Push Day (PPL)',
        'description': 'Focuses on chest, shoulders, and triceps.',
        'exercises': [
          {'name': 'Bench Press (Barbell)', 'category': 'Chest', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}])},
          {'name': 'Incline Bench Press (Dumbbell)', 'category': 'Chest', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Overhead Press (Dumbbell)', 'category': 'Shoulders', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Lateral Raise (Dumbbell)', 'category': 'Shoulders', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}])},
          {'name': 'Triceps Extension (Cable)', 'category': 'Arms', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
        ]
      },
      {
        'title': 'Pull Day (PPL)',
        'description': 'Focuses on back and biceps.',
        'exercises': [
          {'name': 'Deadlift (Barbell)', 'category': 'Back', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 5, 'isCompleted': 0}, {'weight': 0, 'reps': 5, 'isCompleted': 0}, {'weight': 0, 'reps': 5, 'isCompleted': 0}])},
          {'name': 'Lat Pulldown (Cable)', 'category': 'Back', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Seated Cable Row', 'category': 'Back', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Bicep Curl (Dumbbell)', 'category': 'Arms', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
          {'name': 'Hammer Curl (Dumbbell)', 'category': 'Arms', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
        ]
      },
      {
        'title': 'Leg Day (PPL)',
        'description': 'Focuses on quads, hamstrings, and calves.',
        'exercises': [
          {'name': 'Squat (Barbell)', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}])},
          {'name': 'Leg Press', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Romanian Deadlift (Dumbbell)', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Leg Extension (Machine)', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
          {'name': 'Calf Raise', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}])},
        ]
      },
      {
        'title': 'Upper Body Focus',
        'description': 'Comprehensive upper body workout hitting all major muscle groups.',
        'exercises': [
          {'name': 'Bench Press (Barbell)', 'category': 'Chest', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}])},
          {'name': 'Bent Over Row (Barbell)', 'category': 'Back', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}])},
          {'name': 'Overhead Press (Dumbbell)', 'category': 'Shoulders', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Lat Pulldown (Cable)', 'category': 'Back', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Bicep Curl (Dumbbell)', 'category': 'Arms', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
          {'name': 'Triceps Extension (Cable)', 'category': 'Arms', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
        ]
      },
      {
        'title': 'Lower Body Focus',
        'description': 'Comprehensive lower body workout for leg strength and development.',
        'exercises': [
          {'name': 'Squat (Barbell)', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}, {'weight': 0, 'reps': 8, 'isCompleted': 0}])},
          {'name': 'Romanian Deadlift (Dumbbell)', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}, {'weight': 0, 'reps': 10, 'isCompleted': 0}])},
          {'name': 'Walking Lunge', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
          {'name': 'Leg Curl (Machine)', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}, {'weight': 0, 'reps': 12, 'isCompleted': 0}])},
          {'name': 'Calf Raise', 'category': 'Legs', 'exerciseType': 'Weight', 'trackingType': 'Weight & Reps', 'sets': jsonEncode([{'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}, {'weight': 0, 'reps': 15, 'isCompleted': 0}])},
        ]
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Explore Routines",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: ResponsiveHelper.sp(20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24), vertical: ResponsiveHelper.h(16)),
        itemCount: exploreRoutines.length,
        itemBuilder: (context, index) {
          return _RoutineCard(routine: exploreRoutines[index]);
        },
      ),
    );
  }
}

class _RoutineCard extends StatefulWidget {
  final Map<String, dynamic> routine;

  const _RoutineCard({required this.routine});

  @override
  State<_RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<_RoutineCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exercisesList = widget.routine['exercises'] as List<Map<String, dynamic>>;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.h(16)),
        padding: EdgeInsets.all(ResponsiveHelper.w(20)),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.routine['title'] as String,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(18),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.h(8)),
            Text(
              widget.routine['description'] as String,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(14),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: ResponsiveHelper.h(16)),
            Text(
              "${exercisesList.length} Exercises:",
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(14),
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveHelper.h(8)),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(_isExpanded ? exercisesList : exercisesList.take(3)).map((ex) => Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: colorScheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ex['name'] as String,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.sp(14),
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (!_isExpanded && exercisesList.length > 3)
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "+ ${exercisesList.length - 3} more",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(12),
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.h(16)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await DatabaseService().db.insertRoutine(
                      widget.routine['title'] as String,
                      exercisesList,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${widget.routine['title']} saved to My Routines!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.pop(); // Go back to the routines tab
                    }
                  } catch (e) {
                     if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to save routine: $e"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(12)),
                ),
                child: Text(
                  "Save to My Routines",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.sp(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
