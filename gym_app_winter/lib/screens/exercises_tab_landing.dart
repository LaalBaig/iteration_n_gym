import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final bool isKeyboardOpen = View.of(context).viewInsets.bottom > 0;
    final double bottomInset = isKeyboardOpen
        ? 12.0
        : 48 + (bottomPadding > 0 ? bottomPadding * 0.6 : 8.0) + 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Track Exercises',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StreamBuilder<List<Exercise>>(
                stream: DatabaseService().db.watchRecentlyDeletedExercises(),
                builder: (context, snapshot) {
                  final deletedCount = snapshot.data?.length ?? 0;
                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 28,
                        ),
                        if (deletedCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$deletedCount',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      context.push('/recently_deleted');
                    },
                  );
                },
              ),
            ],
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
                  : exerciseList
                        .where(
                          (exercise) => exercise.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();

              if (snapshot.connectionState == ConnectionState.waiting &&
                  exerciseList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredExerciseList.isEmpty) {
                final bool isSearchNotFound =
                    _searchQuery.isNotEmpty && exerciseList.isNotEmpty;
                return Center(
                  child: isSearchNotFound
                      ? NotFound(exercise: _searchQuery)
                      : const EmptyExerciseScreen(),
                );
              } else {
                return ListView.builder(
                  itemCount: filteredExerciseList.length,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                  itemBuilder: (context, index) {
                    final exercise = filteredExerciseList[index];
                    return FutureBuilder<List<MuscleTarget>>(
                      future: DatabaseService().db.getMusclesForExercise(exercise.id),
                      builder: (context, muscleSnapshot) {
                        final muscles = muscleSnapshot.data?.map((m) => m.muscle.name).toList() ?? [];
                        return ExerciseTile(
                          bottomMargin: 12,
                          key: ValueKey(exercise.id),
                          title: exercise.name,
                          subtitle: exercise.lastLog,
                          category: exercise.category,
                          muscleGroups: muscles,
                          confirmDelete: false,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            context.push(
                              '/exercise_page/${Uri.encodeComponent(exercise.name)}',
                            );
                          },
                          onDelete: () async {
                            final dbService = DatabaseService();
                            await dbService.db.softDeleteExercise(exercise.id);
                            if (context.mounted) {
                              final messenger = ScaffoldMessenger.of(context);
                              messenger.clearSnackBars();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Moved to recently deleted",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onInverseSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    80 ,
                                  ),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: "Undo",
                                    textColor: Theme.of(context).colorScheme.inversePrimary,
                                    onPressed: () {
                                      dbService.db.restoreExercise(exercise.id);
                                    },
                                  ),
                                ),
                              );

                              // Safeguard: explicitly hide the SnackBar after 3 seconds
                              Future.delayed(const Duration(seconds: 3), () {
                                messenger.hideCurrentSnackBar();
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
        // Anchored above bottom nav bar
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.push('/add_exercise');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    'Add Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
