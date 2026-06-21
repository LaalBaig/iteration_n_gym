import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/history_tile.dart';

class ProgressChart extends StatefulWidget {
  final List<HistoryTile> history;
  final String initialMetric;
  
  const ProgressChart({super.key, required this.history, this.initialMetric = 'Volume'});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  late String _selectedMetric;
  String _selectedTimeframe = 'All Time';

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.initialMetric;
  }

  @override
  void didUpdateWidget(ProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMetric != widget.initialMetric) {
      _selectedMetric = widget.initialMetric;
    }
  }

  List<HistoryTile> _getFilteredHistory() {
    if (_selectedTimeframe == 'All Time') {
      return widget.history;
    }
    
    final now = DateTime.now();
    final Duration duration;
    switch (_selectedTimeframe) {
      case 'Past Week':
        duration = const Duration(days: 7);
        break;
      case 'Past Month':
        duration = const Duration(days: 30);
        break;
      case 'Past Year':
        duration = const Duration(days: 365);
        break;
      default:
        return widget.history;
    }

    return widget.history.where((tile) {
      if (tile.date == null) return false;
      return now.difference(tile.date!) <= duration;
    }).toList();
  }

  List<FlSpot> _getSpots(List<HistoryTile> filteredHistory) {
    List<FlSpot> spots = [];
    // Reverse the history so that the oldest logs are processed first (left)
    // and the newest logs are processed last (right).
    final orderedHistory = filteredHistory.reversed.toList();

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
        } else if (_selectedMetric == 'Reps') {
           for (var s in sets) {
             yValue += (s['reps'] ?? 0).toDouble();
           }
        } else if (_selectedMetric == 'Time') {
           for (var s in sets) {
             final time = (s['time'] ?? 0).toDouble();
             if (time > yValue) yValue = time;
           }
        }
        spots.add(FlSpot((i + 1).toDouble(), yValue));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();
    final spots = _getSpots(filteredHistory);
    final hasData = spots.isNotEmpty;
    final isDark = context.colors.isDarkMode;
    final Color lineTheme = isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F0);
    final Color borderTheme = isDark ? const Color(0xFF333333) : const Color(0xFFD4D4D4);
    final Color brandPurple = isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16), vertical: ResponsiveHelper.h(16)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.w(24)),
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
                  fontSize: ResponsiveHelper.sp(20),
                  fontWeight: FontWeight.bold,
                  color: context.colors.textBlack,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedMetric,
                    dropdownColor: isDark ? const Color(0xFF222222) : Colors.white,
                    iconEnabledColor: context.colors.brandPrimary,
                    underline: SizedBox(),
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    items: ['Volume', 'Max Weight', 'Reps', 'Time']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: TextStyle(color: context.colors.textBlack, fontSize: ResponsiveHelper.sp(13))),
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
                  SizedBox(width: ResponsiveHelper.w(8)),
                  DropdownButton<String>(
                    value: _selectedTimeframe,
                    dropdownColor: isDark ? const Color(0xFF222222) : Colors.white,
                    iconEnabledColor: context.colors.brandPrimary,
                    underline: SizedBox(),
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    items: ['All Time', 'Past Week', 'Past Month', 'Past Year']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: TextStyle(color: context.colors.textBlack, fontSize: ResponsiveHelper.sp(13))),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedTimeframe = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.h(20)),
          // Chart Area
          Container(
            height: 240,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, 24, 24, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(ResponsiveHelper.w(16)),
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
                          style: TextStyle(color: context.colors.emptyText, fontSize: ResponsiveHelper.sp(12), fontWeight: FontWeight.bold),
                        ),
                        axisNameSize: 20,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(color: context.colors.emptyText, fontSize: ResponsiveHelper.sp(10)),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Session",
                            style: TextStyle(color: context.colors.emptyText, fontSize: ResponsiveHelper.sp(12), fontWeight: FontWeight.bold),
                          ),
                        ),
                        axisNameSize: 24,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value != value.toInt() || value == 0) return const SizedBox.shrink(); 
                            return Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(color: context.colors.emptyText, fontSize: ResponsiveHelper.sp(10)),
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
                                fontSize: ResponsiveHelper.sp(16),
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
                    padding: EdgeInsets.only(left: 60.0, bottom: 24.0),
                    child: Center(
                      child: Text(
                        widget.history.isEmpty
                            ? "Start logging to see progress"
                            : "No logs in the selected timeframe",
                        style: TextStyle(color: context.colors.emptyText, fontSize: ResponsiveHelper.sp(14), fontWeight: FontWeight.w500),
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
