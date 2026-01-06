import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/main_screen.dart';

class AppRouter {
  final GoRouter routeManager = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),
    ],
  );

  GoRouter getRouter() {
    return routeManager;
  }
}
