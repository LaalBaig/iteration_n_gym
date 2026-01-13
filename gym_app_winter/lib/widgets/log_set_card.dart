import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class LogSetCard extends StatefulWidget {
  final String exerciseName;
  final VoidCallback onAddSet;
  final VoidCallback onFinish;

  const LogSetCard({
    super.key,
    required this.exerciseName,
    required this.onAddSet,
    required this.onFinish,
  });

  @override
  State<LogSetCard> createState() => _LogSetCardState();
}

class _SetData {
  int weight;
  int reps;
  final FixedExtentScrollController weightScrollController;
  final FixedExtentScrollController repsScrollController;
  final TextEditingController weightTextController;
  final TextEditingController repsTextController;
  final FocusNode weightFocusNode;
  final FocusNode repsFocusNode;

  _SetData({this.weight = 0, this.reps = 0})
    : weightScrollController = FixedExtentScrollController(),
      repsScrollController = FixedExtentScrollController(),
      weightTextController = TextEditingController(),
      repsTextController = TextEditingController(),
      weightFocusNode = FocusNode(),
      repsFocusNode = FocusNode();

  void dispose() {
    weightScrollController.dispose();
    repsScrollController.dispose();
    weightTextController.dispose();
    repsTextController.dispose();
    weightFocusNode.dispose();
    repsFocusNode.dispose();
  }
}

class _LogSetCardState extends State<LogSetCard> {
  final List<_SetData> _sets = [_SetData()];

  @override
  void initState() {
    super.initState();
    // Add listeners to trigger rebuilds when focus changes
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

  void _addSet() {
    setState(() {
      final newSet = _SetData();
      newSet.weightFocusNode.addListener(() => setState(() {}));
      newSet.repsFocusNode.addListener(() => setState(() {}));
      _sets.add(newSet);
    });
  }

  void _removeSet(int index) {
    if (_sets.length > 1) {
      setState(() {
        _sets[index].dispose();
        _sets.removeAt(index);
      });
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Log Set + Add Set Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Log Set",
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _addSet,
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                label: const Text(
                  "Add Set",
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // All Sets
          ...List.generate(_sets.length, (index) {
            final setData = _sets[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _sets.length - 1 ? 12 : 0,
              ),
              child: Row(
                children: [
                  _buildSetCircle("set ${index + 1}:"),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCrownPicker(
                      label: "kg",
                      value: setData.weight,
                      scrollController: setData.weightScrollController,
                      textController: setData.weightTextController,
                      focusNode: setData.weightFocusNode,
                      maxValue: 500,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          setData.weight = value;
                        });
                      },
                      onTextChanged: (value) {
                        setState(() {
                          setData.weight = value;
                          setData.weightScrollController.jumpToItem(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCrownPicker(
                      label: "reps",
                      value: setData.reps,
                      scrollController: setData.repsScrollController,
                      textController: setData.repsTextController,
                      focusNode: setData.repsFocusNode,
                      maxValue: 100,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          setData.reps = value;
                        });
                      },
                      onTextChanged: (value) {
                        setState(() {
                          setData.reps = value;
                          setData.repsScrollController.jumpToItem(value);
                        });
                      },
                    ),
                  ),
                  // Remove button (only show if more than 1 set)
                  if (_sets.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeSet(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Finish Workout Action
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        ],
      ),
    );
  }

  // Helper for the Set Number indicator
  Widget _buildSetCircle(String number) {
    return Text(
      number,
      style: const TextStyle(color: AppColors.emptyText, fontSize: 16),
    );
  }

  // Helper for Crown Picker (Apple Watch style)
  Widget _buildCrownPicker({
    required String label,
    required int value,
    required FixedExtentScrollController scrollController,
    required TextEditingController textController,
    required FocusNode focusNode,
    required int maxValue,
    required int step,
    required ValueChanged<int> onChanged,
    required ValueChanged<int> onTextChanged,
  }) {
    final itemCount = (maxValue / step).ceil() + 1;
    final isEditing = focusNode.hasFocus;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Display value on the left (tappable for keyboard input)
          Expanded(
            child: ClipRect(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    debugPrint(
                      'Tapped! Current value: $value, isEditing: $isEditing',
                    );
                    textController.text = value.toString();
                    focusNode.requestFocus();
                    // Select all text
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (focusNode.hasFocus &&
                          textController.text.isNotEmpty) {
                        textController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: textController.text.length,
                        );
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Display text (hidden when editing)
                        Offstage(
                          offstage: isEditing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: AppColors.textBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.emptyText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // TextField (always present, shown when editing)
                        Offstage(
                          offstage: !isEditing,
                          child: SizedBox(
                            width: 70,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) {
                                  // Save value when focus is lost
                                  final newValue =
                                      int.tryParse(textController.text) ?? 0;
                                  onTextChanged(newValue.clamp(0, maxValue));
                                }
                              },
                              child: TextField(
                                controller: textController,
                                focusNode: focusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 3,
                                style: const TextStyle(
                                  color: AppColors.textBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  counterText: '',
                                ),
                                onSubmitted: (text) {
                                  final newValue = int.tryParse(text) ?? 0;
                                  onTextChanged(newValue.clamp(0, maxValue));
                                  focusNode.unfocus();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Watch Crown dial on the right
          Container(
            width: 35,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey.withOpacity(0.3),
              border: Border(
                left: BorderSide(
                  color: AppColors.emptyText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: ListWheelScrollView.useDelegate(
              controller: scrollController,
              itemExtent: 5,
              perspective: 0.001,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                _triggerHapticFeedback();
                onChanged(index * step);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= itemCount) return null;
                  final itemValue = index * step;
                  final isSelected = itemValue == value;

                  // Draw tick marks like a watch crown
                  return Center(
                    child: Container(
                      height: 1.5,
                      width: isSelected ? 20 : 14,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.emptyText.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                },
                childCount: itemCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
