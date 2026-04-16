import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:figma_squircle/figma_squircle.dart';
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: context.colors.backgroundGrey,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 1,
          ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  "Progress",
                  style: TextStyle(
                    color: context.colors.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedMetric,
                dropdownColor: context.colors.surfaceWhite,
                iconEnabledColor: context.colors.primaryBlue,
                underline: const SizedBox(),
                style: TextStyle(color: context.colors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14),
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
          const SizedBox(height: 24),
          // Chart Area
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 24, 24, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1C1C1E) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.emptyText.withValues(alpha: 0.1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                LineChart(
                  LineChartData(
                    minX: hasData ? 1 : 0,
                    maxX: hasData ? null : 5,
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
                                color: context.colors.primaryBlue,
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
                            color: context.colors.primaryBlue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: context.colors.primaryBlue.withValues(alpha: 0.1),
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
