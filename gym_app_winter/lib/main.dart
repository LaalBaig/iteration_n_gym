import 'package:flutter/material.dart';
import 'package:gym_app_winter/navigation/app_router.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final _router = AppRouter();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: "Fitness App",
        routerConfig: _router.getRouter(),
    );
  }
}
