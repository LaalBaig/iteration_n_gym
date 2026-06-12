import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_winter/state/workout_manager.dart';
import 'package:gym_app_winter/widgets/discard_workout_dialog.dart';

class SaveWorkoutScreen extends StatefulWidget {
  const SaveWorkoutScreen({super.key});

  @override
  State<SaveWorkoutScreen> createState() => _SaveWorkoutScreenState();
}

class _SaveWorkoutScreenState extends State<SaveWorkoutScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _adjustedDate;
  int? _adjustedDurationSeconds;

  @override
  void initState() {
    super.initState();
    final manager = WorkoutManager();
    _adjustedDate = manager.startTime;
    _adjustedDurationSeconds = manager.elapsedSeconds;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final manager = WorkoutManager();
    final initialDate = _adjustedDate ?? manager.startTime ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _adjustedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showDurationPickerDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final manager = WorkoutManager();

    final currentTotalSeconds = _adjustedDurationSeconds ?? manager.elapsedSeconds;
    final currentHours = currentTotalSeconds ~/ 3600;
    final currentMinutes = (currentTotalSeconds % 3600) ~/ 60;
    final currentSeconds = currentTotalSeconds % 60;

    final hoursController = TextEditingController(text: currentHours.toString());
    final minutesController = TextEditingController(text: currentMinutes.toString());
    final secondsController = TextEditingController(text: currentSeconds.toString());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            "Adjust Duration",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours Field
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: "Hr",
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ":",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Minutes Field
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: "Min",
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ":",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Seconds Field
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: secondsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: "Sec",
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () {
                final hr = int.tryParse(hoursController.text) ?? 0;
                final min = int.tryParse(minutesController.text) ?? 0;
                final sec = int.tryParse(secondsController.text) ?? 0;
                setState(() {
                  _adjustedDurationSeconds = (hr * 3600) + (min * 60) + sec;
                });
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Save",
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final manager = WorkoutManager();

    // Formatting duration as Xmin or Xh Ymin
    final totalSeconds = _adjustedDurationSeconds ?? manager.elapsedSeconds;
    final durationHours = totalSeconds ~/ 3600;
    final durationMinutes = (totalSeconds % 3600) ~/ 60;
    final durationStr = durationHours > 0
        ? "${durationHours}h ${durationMinutes}min"
        : "${durationMinutes}min";

    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(_adjustedDate ?? manager.startTime ?? DateTime.now());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Save Workout",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () async {
                  final order = manager.activeExercises.map((e) => e.name).toList();

                  final start = _adjustedDate ?? manager.startTime ?? DateTime.now();
                  final end = start.add(Duration(seconds: totalSeconds));

                  // Format adjusted duration string for success page: Xh Ym Zs or Ym Zs or Zs
                  final finalHours = totalSeconds ~/ 3600;
                  final finalMinutes = (totalSeconds % 3600) ~/ 60;
                  final finalSeconds = totalSeconds % 60;
                  
                  String durationSummaryStr;
                  if (finalHours > 0) {
                    durationSummaryStr = "${finalHours}h ${finalMinutes}m ${finalSeconds}s";
                  } else if (finalMinutes > 0) {
                    durationSummaryStr = "${finalMinutes}m ${finalSeconds}s";
                  } else {
                    durationSummaryStr = "${finalSeconds}s";
                  }

                  final summaryData = {
                    'duration': durationSummaryStr,
                    'exerciseCount': manager.completedExerciseNames.length,
                    'setsCount': manager.completedSetsCount,
                    'exercises': manager.completedExerciseNames,
                  };

                  // Finish and save to database with custom adjusted date and time and description
                  final workoutId = await manager.finishWorkout(
                    exerciseOrder: order,
                    customStartTime: start,
                    customEndTime: end,
                    description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                  );
                  summaryData['workoutId'] = workoutId;

                  if (!context.mounted) return;

                  // Navigate to the success screen
                  context.pushReplacement('/workout_summary', extra: summaryData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _showDurationPickerDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildStatItem("Duration", durationStr, colorScheme.primary),
                    ),
                  ),
                  _buildStatItem("Volume", "${manager.totalVolume.round()} kg", colorScheme.onSurface),
                  _buildStatItem("Sets", manager.setsCount.toString(), colorScheme.onSurface),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
              const SizedBox(height: 24),

              // "When" section (tappable to edit)
              InkWell(
                onTap: () => _selectDateTime(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "When",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.edit_calendar_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
              const SizedBox(height: 24),



              // Description Section
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "How did your workout go? Leave some notes here...",
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
              const SizedBox(height: 48),

              // Discard Button
              Center(
                child: TextButton(
                  onPressed: () async {
                    final confirm = await showDiscardWorkoutDialog(context);
                    if (confirm == true) {
                      if (!context.mounted) return;
                      manager.discardWorkout();
                      context.go('/');
                    }
                  },
                  child: Text(
                    "Discard Workout",
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    path.addRRect(rrect);

    final dashPath = Path();
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final len = dashWidth;
        final isLast = distance + len >= pathMetric.length;
        dashPath.addPath(
          pathMetric.extractPath(distance, isLast ? pathMetric.length : distance + len),
          Offset.zero,
        );
        distance += len + dashGap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
