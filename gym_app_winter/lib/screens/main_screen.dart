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
  late final PageController _pageController;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = MainScreen.activeTabNotifier.value;
    _pageController = PageController(initialPage: _selectedIndex);
    MainScreen.activeTabNotifier.addListener(_onActiveTabChanged);
  }

  @override
  void dispose() {
    MainScreen.activeTabNotifier.removeListener(_onActiveTabChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onActiveTabChanged() {
    final newIndex = MainScreen.activeTabNotifier.value;
    if (newIndex != _selectedIndex) {
      _onTabSelected(newIndex);
    }
  }

  final List<Widget> _tabs = const [
    ExercisesTab(),
    WorkoutsTab(),
    StatsTab(),
    ProfileTab(),
  ];

  void _onTabSelected(int index) {
    if (_selectedIndex == 0 && index != 0) {
      RestTimerNotifier().cancel();
    }
    setState(() {
      _selectedIndex = index;
      _isProgrammaticScroll = true;
    });
    MainScreen.activeTabNotifier.value = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      if (mounted) {
        _isProgrammaticScroll = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: context.colors.backgroundGrey,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (!_isProgrammaticScroll) {
              if (_selectedIndex == 0 && index != 0) {
                RestTimerNotifier().cancel();
              }
              setState(() {
                _selectedIndex = index;
              });
              MainScreen.activeTabNotifier.value = index;
            }
          },
          children: _tabs,
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
