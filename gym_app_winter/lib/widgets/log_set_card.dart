import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app_winter/widgets/confirm_log.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:gym_app_winter/state/workout_manager.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';

enum LogSetCardVariant {
  weighted,
  bodyweight,
  timed,
}

class LogSetCard extends StatefulWidget {
  final String exerciseName;
  final VoidCallback onAddSet;
  final FutureOr<void> Function(List<Map<String, int>>) onFinish;
  final bool showLogButton;
  final LogSetCardVariant variant;

  final String? headerTitle;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;
  final VoidCallback? onReorder;

  final List<Map<String, int>>? initialSets;
  final ValueChanged<List<Map<String, int>>>? onChanged;
  final bool showCheckmark;
  final bool isHighlighted;

  const LogSetCard({
    super.key,
    required this.exerciseName,
    required this.onAddSet,
    required this.onFinish,
    this.showLogButton = true,
    this.variant = LogSetCardVariant.weighted,
    this.headerTitle,
    this.onRemove,
    this.onReplace,
    this.onReorder,
    this.initialSets,
    this.onChanged,
    this.showCheckmark = true,
    this.isHighlighted = false,
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

  // Stopwatch state properties
  int durationMs; // Duration in milliseconds
  bool isRunning;
  Timer? stopwatchTimer;
  DateTime? timerStartTime;
  int timeBeforeStartMs;
  final VoidCallback? onTimerTick;

  _SetData({
    this.weight = 0,
    this.reps = 0,
    this.onTimerTick,
  })  : isCompleted = false,
        durationMs = 0,
        isRunning = false,
        timeBeforeStartMs = 0,
        weightTextController = TextEditingController(text: weight > 0 ? weight.toString() : ''),
        repsTextController = TextEditingController(text: reps > 0 ? reps.toString() : ''),
        weightFocusNode = FocusNode(),
        repsFocusNode = FocusNode();

  void startTimer(VoidCallback onTick) {
    if (isRunning) return;
    isRunning = true;
    timerStartTime = DateTime.now();
    stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(timerStartTime!).inMilliseconds;
      durationMs = timeBeforeStartMs + elapsed;
      onTick();
    });
  }

  void stopTimer() {
    if (!isRunning) return;
    isRunning = false;
    stopwatchTimer?.cancel();
    stopwatchTimer = null;
    timeBeforeStartMs = durationMs;
  }

  void resetTimer(VoidCallback onTick) {
    stopTimer();
    durationMs = 0;
    timeBeforeStartMs = 0;
    onTick();
  }

  String formatDuration() {
    if (durationMs <= 0) return '—';
    final minutes = (durationMs ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    final centiseconds = ((durationMs % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  void dispose() {
    weightTextController.dispose();
    repsTextController.dispose();
    weightFocusNode.dispose();
    repsFocusNode.dispose();
    stopwatchTimer?.cancel();
  }
}

class _LogSetCardState extends State<LogSetCard> {
  final List<_SetData> _sets = [];
  List<ExerciseLog> _previousLogs = [];

  Map<int, int> _repMaxes = {};
  int _maxBodyweightReps = 0;
  int _maxTimeSeconds = 0;

  bool _highlighted = false;

  _SetData _createSetData({int weight = 0, int reps = 0}) {
    return _SetData(
      weight: weight,
      reps: reps,
      onTimerTick: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _highlighted = widget.isHighlighted;
    if (_highlighted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _highlighted = false;
          });
        }
      });
    }
    _loadPreviousLogs();
    
    if (widget.initialSets != null && widget.initialSets!.isNotEmpty) {
      for (var setMap in widget.initialSets!) {
        int w = setMap['weight'] ?? 0;
        int r = setMap['reps'] ?? 0;
        bool completed = (setMap['isCompleted'] ?? 0) == 1;
        
        final setData = _createSetData(weight: w, reps: r);
        setData.isCompleted = completed;
        if (widget.variant == LogSetCardVariant.timed) {
          setData.durationMs = w * 1000;
          setData.timeBeforeStartMs = w * 1000;
        }
        _sets.add(setData);
      }
    } else {
      // Check if there are existing active workout sets for this exercise
      final activeSets = WorkoutManager().getLogsForExercise(widget.exerciseName);
      if (activeSets != null && activeSets.isNotEmpty) {
        for (var setMap in activeSets) {
          int w = setMap['weight'] ?? 0;
          int r = setMap['reps'] ?? 0;
          bool completed = setMap['isCompleted'] == 1;
          
          final setData = _createSetData(weight: w, reps: r);
          setData.isCompleted = completed;
          if (widget.variant == LogSetCardVariant.timed) {
            setData.durationMs = w * 1000;
            setData.timeBeforeStartMs = w * 1000;
          }
          _sets.add(setData);
        }
      } else {
        // Add initial set
        _sets.add(_createSetData());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.onChanged == null) {
            WorkoutManager().incrementSet();
          }
          _notifyChanges();
        });
      }
    }

    for (var set in _sets) {
      set.weightFocusNode.addListener(() => setState(() {}));
      set.repsFocusNode.addListener(() => setState(() {}));
    }

    if (widget.isHighlighted && _sets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.variant == LogSetCardVariant.timed) {
          // Timed variant has no input fields to focus
        } else if (widget.variant == LogSetCardVariant.bodyweight) {
          _sets.first.repsFocusNode.requestFocus();
        } else {
          _sets.first.weightFocusNode.requestFocus();
        }
      });
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
      if (mounted) {
        setState(() {
          _repMaxes.clear();
          _maxBodyweightReps = 0;
          _maxTimeSeconds = 0;
        });
      }
      if (logs.isNotEmpty) {
        // Compute historical PRs
        for (var log in logs) {
          if (widget.variant == LogSetCardVariant.weighted) {
            if (log.reps > 0 && log.weight > 0) {
              int currentMax = _repMaxes[log.reps] ?? 0;
              if (log.weight.toInt() > currentMax) {
                _repMaxes[log.reps] = log.weight.toInt();
              }
            }
          } else if (widget.variant == LogSetCardVariant.bodyweight) {
            if (log.reps > _maxBodyweightReps) {
              _maxBodyweightReps = log.reps;
            }
          } else if (widget.variant == LogSetCardVariant.timed) {
            if (log.weight.toInt() > _maxTimeSeconds) {
              _maxTimeSeconds = log.weight.toInt();
            }
          }
        }

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

  bool _isPR(_SetData setData) {
    if (widget.variant == LogSetCardVariant.weighted) {
      if (setData.reps > 0 && setData.weight > 0) {
        int previousMax = _repMaxes[setData.reps] ?? 0;
        if (previousMax == 0) return true; // First time doing these reps
        return setData.weight > previousMax;
      }
    } else if (widget.variant == LogSetCardVariant.bodyweight) {
      if (setData.reps > 0) {
        if (_maxBodyweightReps == 0) return true;
        return setData.reps > _maxBodyweightReps;
      }
    } else if (widget.variant == LogSetCardVariant.timed) {
      int durationSec = setData.durationMs ~/ 1000;
      if (durationSec > 0) {
        if (_maxTimeSeconds == 0) return true;
        return durationSec > _maxTimeSeconds;
      }
    }
    return false;
  }

  void _addSet() {
    setState(() {
      int initialWeight = 0;
      int initialReps = 0;
      
      if (_sets.isNotEmpty) {
        initialWeight = _sets.last.weight;
        initialReps = _sets.last.reps;
      }
      
      final newSet = _createSetData(weight: initialWeight, reps: initialReps);
      newSet.weightFocusNode.addListener(() => setState(() {}));
      newSet.repsFocusNode.addListener(() => setState(() {}));
      _sets.add(newSet);
      if (widget.onChanged == null) {
        WorkoutManager().incrementSet();
      }
      _notifyChanges();
    });

    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.9,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _removeSet(int index) {
    if (_sets.length > 1) {
      setState(() {
        _sets[index].dispose();
        _sets.removeAt(index);
        if (widget.onChanged == null) {
          WorkoutManager().decrementSet();
        }
        _notifyChanges();
      });
    }
  }

  void _toggleTimer(int index) {
    final setData = _sets[index];
    setState(() {
      if (setData.isRunning) {
        setData.stopTimer();
        setData.isCompleted = true;
      } else {
        // Stop any other running timer
        for (int i = 0; i < _sets.length; i++) {
          if (i != index && _sets[i].isRunning) {
            _sets[i].stopTimer();
            _sets[i].isCompleted = true;
          }
        }
        setData.startTimer(() {
          if (mounted) setState(() {});
        });
      }
      _notifyChanges();
    });
  }

  void _showTimeAdjustmentBottomSheet(BuildContext context, int index) async {
    final setData = _sets[index];
    final isRunningBefore = setData.isRunning;
    if (isRunningBefore) {
      setData.stopTimer();
    }

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        final Color headerTextColor = colorScheme.onSurfaceVariant;
        final Color brandPurple = colorScheme.primary;
        final Color borderTheme = colorScheme.outlineVariant;

        int tempMin = (setData.durationMs ~/ 60000).clamp(0, 99);
        int tempSec = ((setData.durationMs % 60000) ~/ 1000).clamp(0, 59);

        final minController = TextEditingController(text: tempMin.toString().padLeft(2, '0'));
        final secController = TextEditingController(text: tempSec.toString().padLeft(2, '0'));

        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "Adjust time — set ${index + 1}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Use the arrows or tap the number to edit",
                    style: TextStyle(
                      fontSize: 14,
                      color: headerTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // MIN Column
                      Column(
                        children: [
                          Text("MIN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor)),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () {
                              tempMin = (tempMin + 1).clamp(0, 99);
                              minController.text = tempMin.toString().padLeft(2, '0');
                              sheetSetState(() {});
                            },
                            icon: Icon(Icons.keyboard_arrow_up, color: colorScheme.onSurface),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: minController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 16)),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                              onChanged: (val) {
                                tempMin = (int.tryParse(val) ?? 0).clamp(0, 99);
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              tempMin = (tempMin - 1).clamp(0, 99);
                              minController.text = tempMin.toString().padLeft(2, '0');
                              sheetSetState(() {});
                            },
                            icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(":", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: headerTextColor)),
                      ),
                      const SizedBox(width: 16),
                      // SEC Column
                      Column(
                        children: [
                          Text("SEC", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor)),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () {
                              tempSec = (tempSec + 1).clamp(0, 59);
                              secController.text = tempSec.toString().padLeft(2, '0');
                              sheetSetState(() {});
                            },
                            icon: Icon(Icons.keyboard_arrow_up, color: colorScheme.onSurface),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: secController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 16)),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                              onChanged: (val) {
                                tempSec = (int.tryParse(val) ?? 0).clamp(0, 59);
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              tempSec = (tempSec - 1).clamp(0, 59);
                              secController.text = tempSec.toString().padLeft(2, '0');
                              sheetSetState(() {});
                            },
                            icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderTheme),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final totalMs = (tempMin * 60 + tempSec) * 1000;
                            Navigator.pop(context, totalMs);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        setData.durationMs = result;
        setData.timeBeforeStartMs = result;
        setData.isCompleted = true;
        _notifyChanges();
      });
    } else if (isRunningBefore) {
      setData.startTimer(() {
        if (mounted) setState(() {});
      });
    }
  }

  void _notifyChanges() {
    final setsData = _sets.map((s) {
      if (widget.variant == LogSetCardVariant.timed) {
        return {
          'weight': s.durationMs ~/ 1000,
          'reps': 0,
          'isCompleted': s.isCompleted ? 1 : 0,
        };
      } else if (widget.variant == LogSetCardVariant.bodyweight) {
        return {
          'weight': 0,
          'reps': s.reps,
          'isCompleted': s.isCompleted ? 1 : 0,
        };
      } else {
        return {
          'weight': s.weight,
          'reps': s.reps,
          'isCompleted': s.isCompleted ? 1 : 0,
        };
      }
    }).toList();
    if (widget.onChanged != null) {
      widget.onChanged!(setsData);
    } else {
      WorkoutManager().addLogsForExercise(widget.exerciseName, setsData);
    }
  }

  void _copyPreviousToCurrent(int index) {
    if (index < _previousLogs.length) {
      final log = _previousLogs[index];
      final setData = _sets[index];
      setState(() {
        if (widget.variant == LogSetCardVariant.timed) {
          final seconds = log.weight.toInt();
          setData.durationMs = seconds * 1000;
          setData.timeBeforeStartMs = seconds * 1000;
          setData.isCompleted = true;
        } else if (widget.variant == LogSetCardVariant.bodyweight) {
          setData.reps = log.reps;
          setData.repsTextController.text = log.reps > 0 ? log.reps.toString() : '';
        } else {
          setData.weight = log.weight.toInt();
          setData.reps = log.reps;
          setData.weightTextController.text = log.weight > 0 ? log.weight.toInt().toString() : '';
          setData.repsTextController.text = log.reps > 0 ? log.reps.toString() : '';
        }
        _notifyChanges();
      });
    }
  }

  void _showMoreOptionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle pill
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (widget.onReorder != null)
                  ListTile(
                    leading: Icon(Icons.swap_vert, color: colorScheme.onSurface),
                    title: Text(
                      "Reorder Exercises",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onReorder!();
                    },
                  ),
                if (widget.onReplace != null)
                  ListTile(
                    leading: Icon(Icons.sync, color: colorScheme.onSurface),
                    title: Text(
                      "Replace Exercise",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onReplace!();
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.add, color: colorScheme.onSurface),
                  title: Text(
                    "Add To Superset",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Supersets coming soon!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                if (widget.onRemove != null)
                  ListTile(
                    leading: Icon(Icons.close, color: colorScheme.error),
                    title: Text(
                      "Remove Exercise",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onRemove!();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final Color lineTheme = colorScheme.outlineVariant;
    final Color borderTheme = colorScheme.outlineVariant;
    final Color badgeBg = colorScheme.primaryContainer;
    final Color brandPurple = colorScheme.primary;
    final Color headerTextColor = colorScheme.onSurfaceVariant;

    final Color currentBorderColor = _highlighted ? brandPurple : borderTheme;
    final double currentBorderWidth = _highlighted ? 2.5 : 1.0;
    final Color currentBgColor = _highlighted 
        ? brandPurple.withOpacity(0.08) 
        : colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: currentBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: currentBorderColor,
          width: currentBorderWidth,
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
                Expanded(
                  child: Text(
                    widget.headerTitle ?? "Log sets",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addSet,
                  icon: Icon(Icons.add, size: 16, color: colorScheme.onPrimaryContainer),
                  label: Text(
                    "Add set",
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
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
                if (!widget.showLogButton &&
                    (widget.onRemove != null || widget.onReplace != null || widget.onReorder != null)) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _showMoreOptionsBottomSheet(context),
                    icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
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
                if (widget.variant == LogSetCardVariant.timed) ...[
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Text(
                        "TIME",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor),
                      ),
                    ),
                  ),
                ] else if (widget.variant == LogSetCardVariant.bodyweight) ...[
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Text(
                        "REPS",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerTextColor),
                      ),
                    ),
                  ),
                ] else ...[
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
                ],
                if (widget.showCheckmark)
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

              // Determine previous set text
              String previousText = "-";
              if (index < _previousLogs.length) {
                final log = _previousLogs[index];
                if (widget.variant == LogSetCardVariant.timed) {
                  final seconds = log.weight.toInt();
                  final min = (seconds ~/ 60).toString().padLeft(2, '0');
                  final sec = (seconds % 60).toString().padLeft(2, '0');
                  previousText = "$min:$sec";
                } else if (widget.variant == LogSetCardVariant.bodyweight) {
                  previousText = "${log.reps}";
                } else {
                  previousText = "${log.weight.toInt()} × ${log.reps}";
                }
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: _buildRowContent(context, index, setData, previousText, brandPurple, borderTheme, lineTheme, isDark),
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

                    // Validation check
                    for (int i = 0; i < _sets.length; i++) {
                      final set = _sets[i];
                      if (widget.variant == LogSetCardVariant.weighted) {
                        if (set.weightTextController.text.trim().isEmpty ||
                            set.repsTextController.text.trim().isEmpty) {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text("Please fill in weight and reps for set ${i + 1}"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                      } else if (widget.variant == LogSetCardVariant.bodyweight) {
                        if (set.repsTextController.text.trim().isEmpty) {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text("Please fill in reps for set ${i + 1}"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                      }
                    }

                    final bool? shouldLog = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ConfirmLog(),
                    );
                    
                    if (shouldLog == true) {
                      final setData = _sets
                          .map((set) {
                            if (widget.variant == LogSetCardVariant.timed) {
                              return {'weight': set.durationMs ~/ 1000, 'reps': 0};
                            } else if (widget.variant == LogSetCardVariant.bodyweight) {
                              return {'weight': 0, 'reps': set.reps};
                            } else {
                              return {'weight': set.weight, 'reps': set.reps};
                            }
                          })
                          .toList();
                      await widget.onFinish(setData);

                      WorkoutManager().removeExercise(widget.exerciseName);

                      setState(() {
                        for (var set in _sets) {
                          set.dispose();
                        }
                        _sets.clear();

                        final defaultSet = _createSetData();
                        defaultSet.weightFocusNode.addListener(() => setState(() {}));
                        defaultSet.repsFocusNode.addListener(() => setState(() {}));
                        _sets.add(defaultSet);

                        _loadPreviousLogs();
                      });

                      WorkoutManager().incrementSet();
                      _notifyChanges();
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: brandPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Log Exercise",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
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

  Widget _buildRowContent(
    BuildContext context,
    int index,
    _SetData setData,
    String previousText,
    Color brandPurple,
    Color borderTheme,
    Color lineTheme,
    bool isDark,
  ) {
    if (widget.variant == LogSetCardVariant.timed) {
      return _buildTimedRow(context, index, setData, previousText, brandPurple, borderTheme, lineTheme, isDark);
    } else if (widget.variant == LogSetCardVariant.bodyweight) {
      return _buildBodyweightRow(context, index, setData, previousText, brandPurple, borderTheme, lineTheme, isDark);
    } else {
      return _buildWeightedRow(context, index, setData, previousText, brandPurple, borderTheme, lineTheme, isDark);
    }
  }

  Widget _buildWeightedRow(
    BuildContext context,
    int index,
    _SetData setData,
    String previousText,
    Color brandPurple,
    Color borderTheme,
    Color lineTheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_isPR(setData))
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "PR",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: index < _previousLogs.length ? () => _copyPreviousToCurrent(index) : null,
            child: Text(
              previousText,
              style: TextStyle(
                fontSize: 14,
                color: index < _previousLogs.length ? brandPurple : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: setData.weightTextController,
            focusNode: setData.weightFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: brandPurple,
                  width: 1.5,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              setState(() {
                setData.weight = int.tryParse(val) ?? 0;
                if (val.trim().isEmpty) {
                  setData.isCompleted = false;
                }
                _notifyChanges();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            controller: setData.repsTextController,
            focusNode: setData.repsFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: brandPurple,
                  width: 1.5,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              setState(() {
                setData.reps = int.tryParse(val) ?? 0;
                if (val.trim().isEmpty) {
                  setData.isCompleted = false;
                }
                _notifyChanges();
              });
            },
          ),
        ),
        if (widget.showCheckmark) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 40,
            child: TextButton(
              onPressed: () {
                if (!setData.isCompleted) {
                  if (setData.weightTextController.text.trim().isEmpty ||
                      setData.repsTextController.text.trim().isEmpty) {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Weight and reps cannot be empty"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                }
                setState(() {
                  setData.isCompleted = !setData.isCompleted;
                  _notifyChanges();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: setData.isCompleted
                    ? const Color(0xFF10B981)
                    : colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Icon(
                Icons.check,
                color: setData.isCompleted
                    ? Colors.white
                    : colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBodyweightRow(
    BuildContext context,
    int index,
    _SetData setData,
    String previousText,
    Color brandPurple,
    Color borderTheme,
    Color lineTheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_isPR(setData))
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "PR",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: index < _previousLogs.length ? () => _copyPreviousToCurrent(index) : null,
            child: Text(
              previousText,
              style: TextStyle(
                fontSize: 14,
                color: index < _previousLogs.length ? brandPurple : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: TextField(
            controller: setData.repsTextController,
            focusNode: setData.repsFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: brandPurple,
                  width: 1.5,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              setState(() {
                setData.reps = int.tryParse(val) ?? 0;
                if (val.trim().isEmpty) {
                  setData.isCompleted = false;
                }
                _notifyChanges();
              });
            },
          ),
        ),
        if (widget.showCheckmark) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 40,
            child: TextButton(
              onPressed: () {
                if (!setData.isCompleted) {
                  if (setData.repsTextController.text.trim().isEmpty) {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Reps cannot be empty"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                }
                setState(() {
                  setData.isCompleted = !setData.isCompleted;
                  _notifyChanges();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: setData.isCompleted
                    ? const Color(0xFF10B981)
                    : colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Icon(
                Icons.check,
                color: setData.isCompleted
                    ? Colors.white
                    : colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimedRow(
    BuildContext context,
    int index,
    _SetData setData,
    String previousText,
    Color brandPurple,
    Color borderTheme,
    Color lineTheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeStr = setData.formatDuration();
    final isRunning = setData.isRunning;
    final isCompleted = setData.isCompleted;

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_isPR(setData))
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "PR",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: index < _previousLogs.length ? () => _copyPreviousToCurrent(index) : null,
            child: Text(
              previousText,
              style: TextStyle(
                fontSize: 14,
                color: index < _previousLogs.length ? brandPurple : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: GestureDetector(
            onTap: () => _showTimeAdjustmentBottomSheet(context, index),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isRunning
                      ? brandPurple
                      : colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isRunning
                      ? brandPurple
                      : (timeStr == '—' ? colorScheme.onSurfaceVariant : colorScheme.onSurface),
                ),
              ),
            ),
          ),
        ),
        if (widget.showCheckmark) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 40,
            child: isCompleted && !isRunning
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        setData.isCompleted = false;
                        _notifyChanges();
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                : TextButton(
                    onPressed: () => _toggleTimer(index),
                    style: TextButton.styleFrom(
                      backgroundColor: isRunning
                          ? (isDark ? const Color(0xFF2A1616) : const Color(0xFFFEE2E2))
                          : colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: isRunning
                            ? Colors.red
                            : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(
                      isRunning ? Icons.stop : Icons.play_arrow,
                      color: isRunning
                          ? Colors.red
                          : colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}
