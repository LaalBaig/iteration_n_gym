import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart' show CustomBottomNavigationBar;
import 'package:gym_app_winter/widgets/floating_button.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    void onChanged(String e) {
    print("hello world");
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Track Exercises',
                style: TextStyle(fontSize: 24)
              ),
            ),
            CustomSearchBar(
              hintText: "Search For Exercise",
              controller: _controller,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: () {},
        label: "Add Exercise",
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );

  }
}