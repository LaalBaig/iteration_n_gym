import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart' show CustomBottomNavigationBar;
import 'package:gym_app_winter/widgets/floating_button.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';

class Poop extends StatefulWidget {
  const Poop({super.key});

  @override
  State<Poop> createState() => _PoopState();
}

class _PoopState extends State<Poop> {
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
              hintText: "Slass dat ass",
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