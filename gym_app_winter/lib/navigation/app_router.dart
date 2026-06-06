import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/add_exercise_screen.dart';
import 'package:gym_app_winter/screens/custom_exercise_screen.dart';
import 'package:gym_app_winter/screens/main_screen.dart';
import 'package:gym_app_winter/screens/exercise_page.dart';
import 'package:gym_app_winter/screens/workout_page.dart';
import 'package:gym_app_winter/screens/active_workout_screen.dart';
import 'package:gym_app_winter/screens/see_all_history_screen.dart';
import 'package:gym_app_winter/screens/recently_deleted_screen.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';

class AppRouter {
  final GoRouter routeManager = GoRouter(
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
        builder: (context, state) => const ActiveWorkoutScreen(),
      ),
      GoRoute(
        path: '/custom',
        builder: (context, state) => const CustomExerciseScreen(),
      ),
      GoRoute(
        path: '/see_all_history/:exerciseName',
        builder: (context, state) {
          final historyList = state.extra as List<HistoryTile>? ?? [];
          return SeeAllHistoryScreen(
            exerciseName: state.pathParameters['exerciseName'] ?? '',
            history: historyList,
          );
        },
      ),
    ],
  );

  GoRouter getRouter() {
    return routeManager;
  }
}

