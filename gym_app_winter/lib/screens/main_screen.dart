import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/screens/exercises_tab.dart';
import 'package:gym_app_winter/screens/profile_tab.dart';
import 'package:gym_app_winter/screens/workout_tab.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart';
import 'package:gym_app_winter/widgets/floating_button.dart';





class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    ExercisesTab(),
    WorkoutsTab(),
    ProfileTab(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _tabs[_selectedIndex]),
      floatingActionButton: Visibility(
        visible: _selectedIndex == 0,
        child: CustomFloatingButton(
          onPressed: () {
            GoRouter.of(context).push("/add_exercise");
          },
          label: "Add Exercise",
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
