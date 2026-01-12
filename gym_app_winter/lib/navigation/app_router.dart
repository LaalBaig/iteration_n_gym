import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/main_screen.dart';
import 'package:gym_app_winter/screens/exercise.dart';

class AppRouter {
  final GoRouter routeManager = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainScreen(),
      routes: [
        GoRoute(path: 'exercise', builder: (context, state) => const ExercisePage()),
      ]
      ),
    ],
  );

  GoRouter getRouter() {
    return routeManager;
  }
}
