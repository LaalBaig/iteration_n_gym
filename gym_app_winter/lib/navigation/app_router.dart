import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/main_screen.dart';
import 'package:gym_app_winter/screens/temp.dart';

class AppRouter {
  final GoRouter routeManager = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainScreen(),
      routes: [
        GoRoute(path: 'temp', builder: (context, state) => const Poop()),
      ]
      ),
    ],
  );

  GoRouter getRouter() {
    return routeManager;
  }
}
