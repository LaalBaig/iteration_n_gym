import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';

class ProgressChart extends StatefulWidget {
  final List<HistoryTile> history;
  
  const ProgressChart({super.key, required this.history});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  String _selectedMetric = 'Volume';

  List<FlSpot> _getSpots() {
    List<FlSpot> spots = [];
    // Assuming new entries are appended at the end of the list.
    // If we want chronological order from oldest (left) to newest (right), no reversal is needed if entries are chronological.
    // However, LogSetCard adds to `history.add(HistoryTile...)`, so oldest is at index 0.
    final orderedHistory = widget.history;

    for (int i = 0; i < orderedHistory.length; i++) {
        final sets = orderedHistory[i].setData;
        double yValue = 0;
        
        if (_selectedMetric == 'Volume') {
           for (var s in sets) {
             yValue += (s['reps'] ?? 0) * (s['weight'] ?? 0);
           }
        } else if (_selectedMetric == 'Max Weight') {
           for (var s in sets) {
             final weight = (s['weight'] ?? 0).toDouble();
             if (weight > yValue) yValue = weight;
           }
        }
        spots.add(FlSpot((i + 1).toDouble(), yValue));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getSpots();
    final hasData = spots.isNotEmpty;
    final isDark = context.colors.isDarkMode;
    final Color lineTheme = isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F0);
    final Color borderTheme = isDark ? const Color(0xFF333333) : const Color(0xFFD4D4D4);
    final Color brandPurple = isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderTheme,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textBlack,
                ),
              ),
              DropdownButton<String>(
                value: _selectedMetric,
                dropdownColor: isDark ? const Color(0xFF222222) : Colors.white,
                iconEnabledColor: context.colors.brandPrimary,
                underline: const SizedBox(),
                style: TextStyle(
                  color: isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                items: ['Volume', 'Max Weight']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: TextStyle(color: context.colors.textBlack)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMetric = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart Area
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 24, 24, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lineTheme),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                LineChart(
                  LineChartData(
                    minX: hasData ? 0.5 : 0,
                    maxX: hasData ? (spots.length > 1 ? spots.length.toDouble() + 0.5 : 1.5) : 5,
                    minY: 0,
                    maxY: hasData ? null : 100,
                    gridData: FlGridData(
                      show: hasData,
                      drawVerticalLine: true,
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: context.colors.emptyText.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: context.colors.emptyText.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(
                          _selectedMetric,
                          style: TextStyle(color: context.colors.emptyText, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        axisNameSize: 20,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(color: context.colors.emptyText, fontSize: 10),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Session",
                            style: TextStyle(color: context.colors.emptyText, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        axisNameSize: 24,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value != value.toInt() || value == 0) return const SizedBox.shrink(); 
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(color: context.colors.emptyText, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: context.colors.emptyText.withValues(alpha: 0.3), width: 1.5),
                        left: BorderSide(color: context.colors.emptyText.withValues(alpha: 0.3), width: 1.5),
                        right: BorderSide.none,
                        top: BorderSide.none,
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toInt()}',
                              TextStyle(
                                color: brandPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: hasData 
                      ? [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: brandPurple,
                            barWidth: 3.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: brandPurple,
                                  strokeWidth: 2,
                                  strokeColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: brandPurple.withValues(alpha: 0.1),
                            ),
                          ),
                        ]
                      : [],
                  ),
                ),
                if (!hasData)
                  Padding(
                    padding: const EdgeInsets.only(left: 60.0, bottom: 24.0),
                    child: Center(
                      child: Text(
                        "Start logging to see progress",
                        style: TextStyle(color: context.colors.emptyText, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
