import 'package:flutter/material.dart';
import 'package:gym_app_winter/state/workout_manager.dart';
import 'package:gym_app_winter/navigation/app_router.dart';

class MinimizedWorkoutBar extends StatelessWidget {
  const MinimizedWorkoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double computedBottomPadding = bottomPadding > 0 ? bottomPadding * 0.6 : 8.0;
    final double bottomNavBarHeight = 72 + 4 + computedBottomPadding;

    return ListenableBuilder(
      listenable: WorkoutManager(),
      builder: (context, _) {
        final manager = WorkoutManager();
        if (!manager.isActive || !manager.isMinimized) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: bottomNavBarHeight + 8,
          ),
          child: GestureDetector(
            onTap: () {
              manager.maximize();
              AppRouter.routeManager.push('/active_workout');
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Maximize Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Workout Info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Workout ${manager.formattedDuration}",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            manager.currentExerciseName,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: colorScheme.error,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
