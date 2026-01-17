import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/main_screen.dart';
import 'package:gym_app_winter/screens/exercise_page.dart';
import 'package:gym_app_winter/screens/workout_page.dart';

class AppRouter {
  final GoRouter routeManager = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainScreen(),
      routes: [
        GoRoute(path: 'exercise_page/:exerciseName', builder: (context, state) => ExercisePage(exerciseName: state.pathParameters['exerciseName']!),
          
        ),
        GoRoute(path: 'workout_page', builder: (context, state) => const WorkoutPage()),
      ]
      ),
    ],
  );

  GoRouter getRouter() {
    return routeManager;
  }
}
