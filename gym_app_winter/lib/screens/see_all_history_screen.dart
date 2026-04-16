import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class SeeAllHistoryScreen extends StatelessWidget {
  final String exerciseName;
  final List<HistoryTile> history;

  const SeeAllHistoryScreen({
    super.key,
    required this.exerciseName,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      appBar: AppBar(
        title: Text(
          "$exerciseName History",
          style: TextStyle(
            color: context.colors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: context.colors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BouncingButton(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back, color: context.colors.textBlack),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                "No logs recorded yet.",
                style: TextStyle(color: context.colors.emptyText, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: history[index],
                );
              },
            ),
    );
  }
}
