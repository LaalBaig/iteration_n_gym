import 'package:flutter/material.dart';
import 'package:gym_app_winter/screens/exercises_tab_landing.dart';
import 'package:gym_app_winter/screens/stats_tab.dart';
import 'package:gym_app_winter/screens/profile_tab.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart';





class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _tabs = const [
    ExercisesTab(),
    StatsTab(),
    ProfileTab(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _isProgrammaticScroll = true;
    });
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
    return Scaffold(
      backgroundColor: context.colors.backgroundGrey,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (!_isProgrammaticScroll) {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          children: _tabs,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
