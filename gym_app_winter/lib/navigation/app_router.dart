import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/add_exercise_screen.dart';
import 'package:gym_app_winter/screens/custom_exercise_screen.dart';
import 'package:gym_app_winter/screens/main_screen.dart';
import 'package:gym_app_winter/screens/exercise_page.dart';
import 'package:gym_app_winter/screens/workout_page.dart';
import 'package:gym_app_winter/screens/active_workout_screen.dart';
import 'package:gym_app_winter/screens/see_all_history_screen.dart';
import 'package:gym_app_winter/screens/recently_deleted_screen.dart';
import 'package:gym_app_winter/screens/workout_summary_screen.dart';
import 'package:gym_app_winter/screens/workout_history_screen.dart';
import 'package:gym_app_winter/screens/save_workout_screen.dart';
import 'package:gym_app_winter/screens/create_routine_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter routeManager = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/exercise_page/:exerciseName',
        builder: (context, state) => ExercisePage(
          exerciseName: state.pathParameters['exerciseName']!,
        ),
      ),
      GoRoute(
        path: '/add_exercise',
        builder: (context, state) => const AddExerciseScreen(),
      ),
      GoRoute(
        path: '/recently_deleted',
        builder: (context, state) => const RecentlyDeletedScreen(),
      ),
      GoRoute(
        path: '/workout_page',
        builder: (context, state) => const WorkoutPage(),
      ),
      GoRoute(
        path: '/active_workout',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ActiveWorkoutScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 350),
          );
        },
      ),
      GoRoute(
        path: '/custom',
        builder: (context, state) => const CustomExerciseScreen(),
      ),
      GoRoute(
        path: '/see_all_history/:exerciseName',
        builder: (context, state) {
          return SeeAllHistoryScreen(
            exerciseName: state.pathParameters['exerciseName'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/save_workout',
        builder: (context, state) => const SaveWorkoutScreen(),
      ),
      GoRoute(
        path: '/workout_summary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return WorkoutSummaryScreen(
            workoutId: extra['workoutId'] ?? '',
            duration: extra['duration'] ?? '',
            exerciseCount: extra['exerciseCount'] ?? 0,
            setsCount: extra['setsCount'] ?? 0,
            exercises: List<String>.from(extra['exercises'] ?? []),
          );
        },
      ),
      GoRoute(
        path: '/workout_history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: '/create_routine',
        builder: (context, state) => const CreateRoutineScreen(),
      ),
    ],
  );

  GoRouter getRouter() {
    return routeManager;
  }
}

