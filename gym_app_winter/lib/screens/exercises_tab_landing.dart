import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/empty_exercise_screen.dart';
import 'package:gym_app_winter/widgets/exercise_tile.dart';
import 'package:gym_app_winter/widgets/not_found.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';

class ExercisesTab extends StatefulWidget {
  const ExercisesTab({super.key});

  @override
  State<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<ExercisesTab> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _searchQuery = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            'Track Exercises',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 32,
              color: context.colors.nearBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CustomSearchBar(
          hintText: "Search For Exercise",
          controller: _controller,
          onChanged: (val) {}, // State already updates via listener
        ),
        Expanded(
          child: StreamBuilder<List<Exercise>>(
            stream: DatabaseService().db.watchAllExercises(),
            builder: (context, snapshot) {
              final exerciseList = snapshot.data ?? [];
              final filteredExerciseList = _searchQuery.isEmpty 
                  ? exerciseList 
                  : exerciseList.where((exercise) => 
                      exercise.name.toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();
    
              if (snapshot.connectionState == ConnectionState.waiting && exerciseList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredExerciseList.isEmpty && _searchQuery.isNotEmpty && exerciseList.isNotEmpty) {
                return NotFound(exercise: _searchQuery);
              } else if (filteredExerciseList.isEmpty) {
                return const EmptyExerciseScreen();
              } else {
                return ListView.builder(
                  itemCount: filteredExerciseList.length,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                  itemBuilder: (context, index) {
                    return ExerciseTile(
                      key: ValueKey(filteredExerciseList[index].id),
                      title: filteredExerciseList[index].name,
                      subtitle: filteredExerciseList[index].lastLog,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        context.push(
                          '/exercise_page/${Uri.encodeComponent(filteredExerciseList[index].name)}',
                        );
                      },
                      onDelete: () {
                        DatabaseService().db.deleteExercise(filteredExerciseList[index].id);
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
        // Add the horizontal button here:
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Action to perform on press (e.g., Navigate to add exercise)
                context.push('/add_exercise');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Add Exercise',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
