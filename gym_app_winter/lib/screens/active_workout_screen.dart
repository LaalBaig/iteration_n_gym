import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym_app_winter/datamodel/exercise.dart';
import 'package:gym_app_winter/widgets/log_set_card.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final List<Exercise> _workoutExercises = [];

  void _navigateToAddExercise() async {
    final result = await context.push('/add_exercise');
    if (result != null && result is Exercise) {
      setState(() {
        _workoutExercises.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.textWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.textWhite,
          scrolledUnderElevation: 0,
          elevation: 0,
          titleSpacing: 16,
          title: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Row(
              children: [
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textBlack),
                const SizedBox(width: 8),
                const Text(
                  "Log Workout",
                  style: TextStyle(color: AppColors.textBlack, fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.timer_outlined, color: AppColors.textBlack),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text("Finish", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Divider(color: Colors.grey[200], thickness: 1, height: 1),
              // Summary Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem("Duration", "5s", true),
                    _buildSummaryItem("Volume", "0 kg", false),
                    _buildSummaryItem("Sets", "0", false),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], thickness: 1, height: 1),
              
              Expanded(
                child: _workoutExercises.isEmpty
                    ? _buildEmptyState()
                    : _buildWorkoutList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Empty State Graphic
          const FaIcon(FontAwesomeIcons.dumbbell, size: 60, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            "Get started",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add an exercise to start your workout",
            style: TextStyle(fontSize: 16, color: AppColors.emptyText),
          ),
          
          const Spacer(),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToAddExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: AppColors.textWhite),
                  SizedBox(width: 8),
                  Text(
                    "Add Exercise",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textWhite),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundGrey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                      context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundGrey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Discard Workout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: _workoutExercises.length + 1,
      itemBuilder: (context, index) {
        if (index == _workoutExercises.length) {
          return Column(
            children: [
              const SizedBox(height: 16),
              // Action Buttons below the list
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToAddExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        "Add Exercise",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundGrey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Settings",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                          context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundGrey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Discard Workout",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        }

        final exercise = _workoutExercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              LogSetCard(
                exerciseName: exercise.name,
                showLogButton: false,
                onAddSet: () {},
                onFinish: (sets) {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, String value, bool isBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isBlue ? AppColors.primaryBlue : AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}
