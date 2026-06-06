import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/database/database.dart';

class MuscleVolumeHeatmap extends StatefulWidget {
  final List<LogWithWorkoutAndExercise> logs;

  const MuscleVolumeHeatmap({super.key, required this.logs});

  @override
  State<MuscleVolumeHeatmap> createState() => _MuscleVolumeHeatmapState();
}

class _MuscleVolumeHeatmapState extends State<MuscleVolumeHeatmap> {
  String _selectedRange = 'This Week';

  Color getCellColor(double intensity, BuildContext context) {
    final isDark = context.colors.isDarkMode;
    if (intensity == 0.0) {
      return isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F2);
    }
    
    // 4 shades of brand purple representing volume intensity
    if (isDark) {
      if (intensity <= 0.25) return const Color(0xFF2E2452);
      if (intensity <= 0.50) return const Color(0xFF4C3BA5);
      if (intensity <= 0.75) return const Color(0xFF7562D5);
      return const Color(0xFF9F92EC);
    } else {
      if (intensity <= 0.25) return const Color(0xFFE8E5FA);
      if (intensity <= 0.50) return const Color(0xFFC6BFF4);
      if (intensity <= 0.75) return const Color(0xFF8B7CE6);
      return const Color(0xFF4C3BC9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.colors.isDarkMode;
    final brandPurple = isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9);
    final now = DateTime.now();
    DateTime rangeStart;
    DateTime rangeEnd;
    List<String> colLabels = [];
    int numCols = 0;
    
    // Mapper from log date to column index
    int Function(DateTime) getColIndex;

    if (_selectedRange == 'This Week') {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      rangeStart = DateTime(monday.year, monday.month, monday.day);
      rangeEnd = rangeStart.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
      colLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      numCols = 7;
      getColIndex = (date) => date.difference(rangeStart).inDays.clamp(0, 6);
    } else if (_selectedRange == 'This Month') {
      rangeStart = DateTime(now.year, now.month, 1);
      final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
      rangeEnd = nextMonth.subtract(const Duration(microseconds: 1));
      
      final daysInMonth = rangeEnd.day;
      numCols = (daysInMonth - 1) ~/ 7 + 1;
      colLabels = List.generate(numCols, (i) => 'W${i + 1}');
      getColIndex = (date) => ((date.day - 1) ~/ 7).clamp(0, numCols - 1);
    } else {
      // This Year
      rangeStart = DateTime(now.year, 1, 1);
      rangeEnd = DateTime(now.year + 1, 1, 1).subtract(const Duration(microseconds: 1));
      colLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      numCols = 12;
      getColIndex = (date) => (date.month - 1).clamp(0, 11);
    }

    // Default categories (rows)
    final categories = ['Chest', 'Back', 'Legs', 'Arms', 'Bodyweight', 'Timed', 'Cardio'];
    
    // Add any other user custom categories that are active in this range
    for (var item in widget.logs) {
      final logDate = item.workout.startTime;
      final inRange = (logDate.isAfter(rangeStart) || logDate.isAtSameMomentAs(rangeStart)) &&
                      (logDate.isBefore(rangeEnd) || logDate.isAtSameMomentAs(rangeEnd));
      if (inRange) {
        final cat = item.exercise.category;
        if (cat.isNotEmpty && !categories.contains(cat)) {
          categories.add(cat);
        }
      }
    }

    // Initialize grid data structures
    final Map<String, Map<int, double>> gridData = {};
    for (var cat in categories) {
      gridData[cat] = {};
      for (int col = 0; col < numCols; col++) {
        gridData[cat]![col] = 0.0;
      }
    }

    double maxVolume = 0;

    // Aggregate logs into muscle categories and time step columns
    for (var item in widget.logs) {
      final logDate = item.workout.startTime;
      final inRange = (logDate.isAfter(rangeStart) || logDate.isAtSameMomentAs(rangeStart)) &&
                      (logDate.isBefore(rangeEnd) || logDate.isAtSameMomentAs(rangeEnd));
      if (inRange) {
        final cat = item.exercise.category;
        if (categories.contains(cat)) {
          final col = getColIndex(logDate);
          final volume = item.log.weight > 0
              ? item.log.weight * item.log.reps
              : item.log.reps.toDouble();
          gridData[cat]![col] = (gridData[cat]![col] ?? 0.0) + volume;
        }
      }
    }

    // Determine highest cell volume to compute relative percentages
    for (var cat in categories) {
      for (int col = 0; col < numCols; col++) {
        final vol = gridData[cat]![col] ?? 0.0;
        if (vol > maxVolume) {
          maxVolume = vol;
        }
      }
    }

    const double cellSize = 28.0;
    const double cellPadding = 6.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.borderCream,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Range Selector Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_on_rounded, color: brandPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Muscle Heatmap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textBlack,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedRange,
                dropdownColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                iconEnabledColor: context.colors.brandPrimary,
                underline: const SizedBox(),
                style: TextStyle(
                  color: isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                items: ['This Week', 'This Month', 'This Year']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: TextStyle(color: context.colors.textBlack)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRange = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Heatmap Grid Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pinned Muscle Category Labels
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacing to align with the column headers
                  const SizedBox(height: 20),
                  ...categories.map((cat) => SizedBox(
                        height: cellSize + cellPadding,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colors.oliveGray,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(width: 8),
              
              // 2. Horizontally scrollable Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column Headers (Time Steps)
                      Row(
                        children: List.generate(
                          numCols,
                          (colIndex) => SizedBox(
                            width: cellSize + cellPadding,
                            child: Center(
                              child: Text(
                                colLabels[colIndex],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.stoneGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Matrix cells
                      ...categories.map((cat) {
                        return Row(
                          children: List.generate(numCols, (colIndex) {
                            final double volume = gridData[cat]![colIndex] ?? 0.0;
                            final double intensity = maxVolume > 0 ? volume / maxVolume : 0.0;
                            final suffix = (cat == 'Cardio' || cat == 'Timed' || cat == 'Bodyweight') ? 'reps' : 'kg';
                            
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: cellPadding / 2,
                                vertical: cellPadding / 2,
                              ),
                              child: Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                message: '$cat: ${volume.toInt()} $suffix',
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: getCellColor(intensity, context),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Heatmap Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.stoneGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              ...List.generate(5, (index) {
                final double intensity = index / 4.0;
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: getCellColor(intensity, context),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.stoneGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
