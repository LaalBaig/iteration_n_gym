import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_winter/database/database_service.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.setData,
    this.variant = LogSetCardVariant.weighted,
    this.workoutId,
    this.date,
  });

  final List<Map<String, int>> setData;
  final LogSetCardVariant variant;
  final String? workoutId;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final String dateStr = date != null
        ? DateFormat('EEEE, MMMM d').format(date!)
        : "Wednesday, December 23";

    return Padding(
      padding: const EdgeInsets.all(0),
      child: BouncingButton(
        onTap: () {
          if (setData.length > 3) {
            _showFullHistoryDialog(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: context.colors.warmSand,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 14,
                cornerSmoothing: 1,
              ),
            ),
            shadows: [
              BoxShadow(
                color: context.colors.textBlack.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dateStr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          color: context.colors.textBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (workoutId != null && workoutId!.isNotEmpty)
                      GestureDetector(
                        onTap: () => _confirmAndDelete(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete_outline,
                            size: 24,
                            color: context.colors.emptyText,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Text("Sets", style: TextStyle(color: context.colors.emptyText)),
                Divider(),
                for (
                  int i = 0;
                  i < (setData.length > 3 ? 3 : setData.length);
                  i++
                )
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "${i + 1} ",
                            style: TextStyle(color: context.colors.emptyText),
                          ),
                          SizedBox(width: 12),
                          Text(
                            _formatSet(setData[i]),
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                if (setData.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "View more",
                      style: TextStyle(
                        color: context.colors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
          ),
        ),
      ),
    );
  }

  String _formatSet(Map<String, int> set) {
    if (variant == LogSetCardVariant.timed) {
      final seconds = set['weight'] ?? 0;
      final min = (seconds ~/ 60).toString().padLeft(2, '0');
      final sec = (seconds % 60).toString().padLeft(2, '0');
      return "$min:$sec";
    } else if (variant == LogSetCardVariant.bodyweight) {
      return "${set['reps']}  reps";
    } else {
      return "${set['reps']}  reps  x  ${set['weight']} kg";
    }
  }

  void _showFullHistoryDialog(BuildContext context) {
    final String dateStr = date != null
        ? DateFormat('EEEE, MMMM d').format(date!)
        : "Wednesday, December 23";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: context.colors.backgroundGrey,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 20,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textBlack,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      BouncingButton(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: context.colors.emptyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Sets", style: TextStyle(color: context.colors.emptyText, fontSize: 16)),
                  const Divider(),
                  for (int i = 0; i < setData.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${i + 1} ",
                              style: TextStyle(color: context.colors.emptyText, fontSize: 16),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _formatSet(setData[i]),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final db = DatabaseService().db;
    final id = workoutId;
    if (id == null || id.isEmpty) return;

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.colors.textWhite,
          surfaceTintColor: Colors.transparent,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1,
            ),
          ),
          title: Text(
            "Delete Workout",
            style: TextStyle(
              color: context.colors.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this workout session?",
            style: TextStyle(color: context.colors.textBlack),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: context.colors.emptyText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Fetch workout & logs before deleting
    final workout = await db.getWorkoutById(id);
    final logs = await db.getLogsForWorkout(id);

    if (workout == null) return;

    // Delete
    await db.deleteWorkout(id);

    if (!context.mounted) return;

    // Show floating SnackBar with Undo action
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          "Workout session deleted",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.brandAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white,
          onPressed: () async {
            await db.restoreWorkout(workout, logs);
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Safeguard: explicitly hide the SnackBar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      messenger.hideCurrentSnackBar();
    });
  }
}

