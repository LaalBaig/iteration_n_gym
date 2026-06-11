import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';

void main() {
  testWidgets('Test HistoryTile rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HistoryTile(setData: [{'weight': 100, 'reps': 15}]),
      ),
    ));
    expect(find.byType(HistoryTile), findsOneWidget);
  });

  testWidgets('Test HistoryTile rendering with delete icon when workoutId is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HistoryTile(
          setData: [{'weight': 100, 'reps': 10}],
          workoutId: '12345',
        ),
      ),
    ));
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('Test HistoryTile rendering without delete icon when workoutId is absent', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HistoryTile(
          setData: [{'weight': 100, 'reps': 10}],
        ),
      ),
    ));
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('Test HistoryTile rendering with Workout badge when isWorkout is true', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HistoryTile(
          setData: [{'weight': 100, 'reps': 10}],
          isWorkout: true,
        ),
      ),
    ));
    expect(find.text('Workout'), findsOneWidget);
  });

  testWidgets('Test HistoryTile rendering without delete icon when isWorkout is true and workoutId is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HistoryTile(
          setData: [{'weight': 100, 'reps': 10}],
          workoutId: '12345',
          isWorkout: true,
        ),
      ),
    ));
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
