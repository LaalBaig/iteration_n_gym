import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/confirm_log.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/state/workout_manager.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';

class LogSetCard extends StatefulWidget {
  final String exerciseName;
  final VoidCallback onAddSet;
  final void Function(List<Map<String, int>>) onFinish;
  final bool showLogButton;

  const LogSetCard({
    super.key,
    required this.exerciseName,
    required this.onAddSet,
    required this.onFinish,
    this.showLogButton = true,
  });

  @override
  State<LogSetCard> createState() => _LogSetCardState();
}

class _SetData {
  int weight;
  int reps;
  bool isCompleted;
  final TextEditingController weightTextController;
  final TextEditingController repsTextController;
  final FocusNode weightFocusNode;
  final FocusNode repsFocusNode;

  _SetData({this.weight = 0, this.reps = 0})
      : isCompleted = false, weightTextController = TextEditingController(text: weight > 0 ? weight.toString() : ''),
        repsTextController = TextEditingController(text: reps > 0 ? reps.toString() : ''),
        weightFocusNode = FocusNode(),
        repsFocusNode = FocusNode();

  void dispose() {
    weightTextController.dispose();
    repsTextController.dispose();
    weightFocusNode.dispose();
    repsFocusNode.dispose();
  }
}

class _LogSetCardState extends State<LogSetCard> {
  final List<_SetData> _sets = [];
  List<ExerciseLog> _previousLogs = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousLogs();
    
    // Add initial set
    _sets.add(_SetData());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutManager().incrementSet();
      _notifyChanges();
    });

    for (var set in _sets) {
      set.weightFocusNode.addListener(() => setState(() {}));
      set.repsFocusNode.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (var set in _sets) {
      set.dispose();
    }
    super.dispose();
  }

  void _loadPreviousLogs() async {
    final db = DatabaseService().db;
    try {
      final logs = await (db.select(db.exerciseLogs)..where((t) => t.exerciseName.equals(widget.exerciseName))).get();
      if (logs.isNotEmpty) {
        final Map<String, List<ExerciseLog>> grouped = {};
        for (var log in logs) {
          grouped.putIfAbsent(log.workoutId, () => []).add(log);
        }
        final sortedIds = grouped.keys.toList()
          ..sort((a, b) {
            final tA = int.tryParse(a) ?? 0;
            final tB = int.tryParse(b) ?? 0;
            return tB.compareTo(tA);
          });
        if (sortedIds.isNotEmpty) {
          final latestLogs = grouped[sortedIds.first]!;
          latestLogs.sort((a, b) => a.setNumber.compareTo(b.setNumber));
          if (mounted) {
            setState(() {
              _previousLogs = latestLogs;
            });
          }
        }
      }
    } catch (e) {
      // Handle or ignore gracefully
    }
  }

  void _addSet() {
    setState(() {
      int initialWeight = 0;
      int initialReps = 0;
      
      if (_sets.isNotEmpty) {
        initialWeight = _sets.last.weight;
        initialReps = _sets.last.reps;
      }
      
      final newSet = _SetData(weight: initialWeight, reps: initialReps);
      newSet.weightFocusNode.addListener(() => setState(() {}));
      newSet.repsFocusNode.addListener(() => setState(() {}));
      _sets.add(newSet);
      WorkoutManager().incrementSet();
      _notifyChanges();
    });
  }

  void _removeSet(int index) {
    if (_sets.length > 1) {
      setState(() {
        _sets[index].dispose();
        _sets.removeAt(index);
        WorkoutManager().decrementSet();
        _notifyChanges();
      });
    }
  }

  void _notifyChanges() {
    final setsData = _sets.map((s) => {'weight': s.weight, 'reps': s.reps}).toList();
    WorkoutManager().addLogsForExercise(widget.exerciseName, setsData);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDarkMode;
    final Color lineTheme = isDark ? const Color(0xFF222222) : const Color(0xFFF0F0F0);
    final Color borderTheme = isDark ? const Color(0xFF333333) : const Color(0xFFD4D4D4);
    final Color badgeBg = isDark ? const Color(0xFF2E2B4A) : const Color(0xFFEEECF9);
    final Color brandPurple = isDark ? const Color(0xFF9F92EC) : const Color(0xFF4C3BC9);
    final Color headerTextColor = isDark ? const Color(0xFF888888) : const Color(0xFF9E9E9E);

    return Container(
      width: double.infinity,
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
        children: [
          // Header Row: Title and Add Set Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Log sets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textBlack,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addSet,
                  icon: Icon(Icons.add, size: 16, color: brandPurple),
                  label: Text(
                    "Add set",
                    style: TextStyle(
                      color: brandPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: badgeBg,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Table Columns Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text(
                    "SET",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "PREVIOUS",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "KG",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "REPS",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 52), // Matches checkmark column
              ],
            ),
          ),

          // Divider below columns header
          Container(
            height: 1,
            color: lineTheme,
          ),

          // Set rows list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sets.length,
            itemBuilder: (context, index) {
              final setData = _sets[index];
              final isWeightActive = setData.weightFocusNode.hasFocus;
              final isRepsActive = setData.repsFocusNode.hasFocus;

              // Determine previous set text
              String previousText = "-";
              if (index < _previousLogs.length) {
                final log = _previousLogs[index];
                previousText = "${log.weight.toInt()} × ${log.reps}";
              }

              // Background row color highlighted if checked (greenish accent)
              final Color rowColor = setData.isCompleted
                  ? (isDark ? const Color(0xFF0E2A1E) : const Color(0xFFE8F8EE))
                  : Colors.transparent;

              return Dismissible(
                key: ValueKey(setData.hashCode),
                direction: _sets.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _removeSet(index);
                },
                child: Container(
                  color: rowColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Set number
                      SizedBox(
                        width: 45,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textBlack,
                          ),
                        ),
                      ),

                      // Previous set info
                      Expanded(
                        flex: 3,
                        child: Text(
                          previousText,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.stoneGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // KG Input Box
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isWeightActive
                                  ? brandPurple
                                  : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: setData.weightTextController,
                            focusNode: setData.weightFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textBlack,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (val) {
                              setState(() {
                                setData.weight = int.tryParse(val) ?? 0;
                                _notifyChanges();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // REPS Input Box
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isRepsActive
                                  ? brandPurple
                                  : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: setData.repsTextController,
                            focusNode: setData.repsFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textBlack,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (val) {
                              setState(() {
                                setData.reps = int.tryParse(val) ?? 0;
                                _notifyChanges();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Checkmark Status Button
                      SizedBox(
                        width: 44,
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              setData.isCompleted = !setData.isCompleted;
                              _notifyChanges();
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: setData.isCompleted
                                ? const Color(0xFF10B981) // Green accent on click
                                : (isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Icon(
                            Icons.check,
                            color: setData.isCompleted
                                ? Colors.white
                                : (isDark ? const Color(0xFF555555) : const Color(0xFF888888)),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom padding or Log Exercise button
          if (widget.showLogButton) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: BouncingButton(
                  onTap: () async {
                    // Save and unfocus
                    for (var set in _sets) {
                      set.weightFocusNode.unfocus();
                      set.repsFocusNode.unfocus();
                    }

                    final bool? shouldLog = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ConfirmLog(),
                    );
                    
                    if (shouldLog == true) {
                      final setData = _sets
                          .map((set) => {'weight': set.weight, 'reps': set.reps})
                          .toList();
                      widget.onFinish(setData);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: brandPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Log Exercise",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
