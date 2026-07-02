import 'package:flutter/material.dart';
import 'package:gym_app_winter/screens/exercises_tab_landing.dart';
import 'package:gym_app_winter/screens/stats_tab.dart';
import 'package:gym_app_winter/screens/workout_tab.dart';
import 'package:gym_app_winter/screens/profile_tab.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart';
import 'package:gym_app_winter/state/rest_timer_notifier.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    WorkoutsTab(),
    ExercisesTab(),
    StatsTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = MainScreen.activeTabNotifier.value;
    MainScreen.activeTabNotifier.addListener(_onActiveTabChanged);
  }

  @override
  void dispose() {
    MainScreen.activeTabNotifier.removeListener(_onActiveTabChanged);
    super.dispose();
  }

  void _onActiveTabChanged() {
    final newIndex = MainScreen.activeTabNotifier.value;
    if (newIndex != _selectedIndex) {
      _onTabSelected(newIndex);
    }
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == 1 && index != 1) {
      RestTimerNotifier().cancel();
    }
    setState(() => _selectedIndex = index);
    MainScreen.activeTabNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: context.colors.backgroundGrey,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: List.generate(_tabs.length, (i) {
            final isSelected = i == _selectedIndex;
            return IgnorePointer(
              ignoring: !isSelected,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeIn,
                child: _tabs[i],
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: isKeyboardOpen
          ? null
          : CustomBottomNavigationBar(
              currentIndex: _selectedIndex,
              onTabSelected: _onTabSelected,
            ),
    );
  }
}
