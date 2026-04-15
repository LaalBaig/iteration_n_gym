import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';

void main() {
  testWidgets('Test HistoryTile rendering', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HistoryTile(setData: [{'weight': 100, 'reps': 10}]),
      ),
    ));
    expect(find.byType(HistoryTile), findsOneWidget);
  });
}
