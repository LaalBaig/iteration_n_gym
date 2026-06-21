import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

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
    this.isWorkout = false,
  });

  final List<Map<String, int>> setData;
  final LogSetCardVariant variant;
  final String? workoutId;
  final DateTime? date;
  final bool isWorkout;

  @override
  Widget build(BuildContext context) {
    final String dateStr = date != null
        ? DateFormat('EEEE, MMMM d').format(date!)
        : "Wednesday, December 23";

    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.w(0)),
      child: BouncingButton(
        onTap: () {
          if (setData.length > 3) {
            _showFullHistoryDialog(context);
          }
        },
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.w(16)),
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 14,
                cornerSmoothing: 1,
              ),
            ),
            shadows: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: Offset(0, 4),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              dateStr,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isWorkout) ...[
                            SizedBox(width: ResponsiveHelper.w(8)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(8), vertical: ResponsiveHelper.h(4)),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(ResponsiveHelper.w(8)),
                              ),
                              child: Text(
                                "Workout",
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.sp(10),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (workoutId != null && workoutId!.isNotEmpty && !isWorkout)
                      GestureDetector(
                        onTap: () => _confirmAndDelete(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveHelper.w(8.0)),
                          child: Icon(
                            Icons.delete_outline,
                            size: ResponsiveHelper.w(24),
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.h(10)),
                Text("Sets", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          SizedBox(width: ResponsiveHelper.w(12)),
                          Text(
                            _formatSet(setData[i]),
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                          if (setData[i]['isPR'] == 1)
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(4), vertical: ResponsiveHelper.h(2)),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(ResponsiveHelper.w(4)),
                              ),
                              child: Text(
                                "PR",
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.sp(10),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.h(6)),
                    ],
                  ),
                if (setData.length > 3)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "View more",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
      final seconds = set['time'] ?? set['weight'] ?? 0;
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
          insetPadding: EdgeInsets.all(ResponsiveHelper.w(24)),
          child: Container(
            padding: EdgeInsets.all(ResponsiveHelper.w(24)),
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                            fontSize: ResponsiveHelper.sp(18),
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      BouncingButton(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.h(16)),
                  Text("Sets", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
                  Divider(),
                  for (int i = 0; i < setData.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${i + 1} ",
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                            ),
                            SizedBox(width: ResponsiveHelper.w(16)),
                            Text(
                              _formatSet(setData[i]),
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: ResponsiveHelper.sp(16)),
                            ),
                            if (setData[i]['isPR'] == 1)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(4), vertical: ResponsiveHelper.h(2)),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.w(4)),
                                ),
                                child: Text(
                                  "PR",
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.sp(10),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: ResponsiveHelper.h(10)),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this workout session?",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                "Delete",
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
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
        content: Text(
          "Workout session deleted",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
        ),
        margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Theme.of(context).colorScheme.inversePrimary,
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

