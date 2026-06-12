import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_winter/state/workout_manager.dart';
import 'package:gym_app_winter/widgets/discard_workout_dialog.dart';
import 'package:gym_app_winter/screens/main_screen.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedPhotoUrl;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showPhotoPicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext dialogContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Choose a photo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.fitness_center, color: colorScheme.primary),
                title: Text("Gym Dumbbells", style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  setState(() {
                    _selectedPhotoUrl = "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=300&auto=format&fit=crop&q=80";
                  });
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: colorScheme.primary),
                title: Text("Gym Studio", style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  setState(() {
                    _selectedPhotoUrl = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300&auto=format&fit=crop&q=80";
                  });
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: Icon(Icons.directions_run, color: colorScheme.primary),
                title: Text("Athlete Training", style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  setState(() {
                    _selectedPhotoUrl = "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=300&auto=format&fit=crop&q=80";
                  });
                  Navigator.pop(dialogContext);
                },
              ),
              if (_selectedPhotoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _selectedPhotoUrl = null;
                    });
                    Navigator.pop(dialogContext);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final manager = WorkoutManager();

    final isLight = theme.brightness == Brightness.light;
    final primaryBlue = isLight ? const Color(0xFF007AFF) : colorScheme.primary;

    // Formatting duration as Xmin
    final durationMinutes = manager.elapsedSeconds ~/ 60;
    final durationStr = "${durationMinutes}min";

    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(manager.startTime ?? DateTime.now());

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
                  
                  // Finish and save to database
                  await manager.finishWorkout(exerciseOrder: order);

                  if (!context.mounted) return;
                  
                  // Show success banner
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Workout saved successfully!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );

                  // Navigate back to main screen and select workouts tab
                  MainScreen.activeTabNotifier.value = 1;
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
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
                  _buildStatItem("Duration", durationStr, primaryBlue),
                  _buildStatItem("Volume", "${manager.totalVolume.round()} kg", colorScheme.onSurface),
                  _buildStatItem("Sets", manager.setsCount.toString(), colorScheme.onSurface),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
              const SizedBox(height: 24),

              // "When" section
              Text(
                "When",
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant, thickness: 1, height: 1),
              const SizedBox(height: 24),

              // "Add a photo / video" section
              InkWell(
                onTap: () => _showPhotoPicker(context),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomPaint(
                          painter: DashedBorderPainter(
                            color: colorScheme.outlineVariant,
                            borderRadius: 12.0,
                            strokeWidth: 1.5,
                            dashWidth: 6.0,
                            dashGap: 4.0,
                          ),
                          child: _selectedPhotoUrl != null
                              ? Image.network(
                                  _selectedPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedPhotoUrl != null ? "Change photo" : "Add a photo / video",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
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
