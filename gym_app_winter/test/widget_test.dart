import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app_winter/widgets/bottom_navigation_bar.dart';

void main() {
  testWidgets('Test CustomBottomNavigationBar rendering', (WidgetTester tester) async {
    int selectedIndex = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: selectedIndex,
          onTabSelected: (index) {
            selectedIndex = index;
          },
        ),
      ),
    ));

    expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
