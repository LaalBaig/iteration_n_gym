import 'package:flutter/material.dart';
import 'package:gym_app_winter/schemes/color_scheme.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart';
import 'package:gym_app_winter/widgets/floating_button.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          surface: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onChanged(String e) {
    print("hello world");
  }

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
