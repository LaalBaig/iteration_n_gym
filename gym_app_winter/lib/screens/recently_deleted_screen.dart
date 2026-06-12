import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';

class RecentlyDeletedScreen extends StatelessWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          "Recently Deleted",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: DatabaseService().db.watchRecentlyDeletedExercises(),
        builder: (context, snapshot) {
          final deletedList = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting &&
              deletedList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deletedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_sweep_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Trash is Empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Exercises you delete will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: deletedList.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemBuilder: (context, index) {
              final exercise = deletedList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (exercise.category.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              exercise.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_backup_restore, color: Colors.green),
                      tooltip: "Restore exercise",
                      onPressed: () async {
                        await DatabaseService().db.restoreExercise(exercise.id);
                        if (context.mounted) {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                "Restored '${exercise.name}'",
                                style: const TextStyle(color: Colors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green[700],
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 2), () {
                            messenger.hideCurrentSnackBar();
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_forever, color: colorScheme.error),
                      tooltip: "Delete permanently",
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: colorScheme.surface,
                              title: Text("Delete Permanently", style: TextStyle(color: colorScheme.onSurface)),
                              content: Text(
                                "Are you sure you want to permanently delete '${exercise.name}'? This will remove it from your exercises, but your workout history will be kept.",
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                  child: Text(
                                    "Delete Permanently",
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await DatabaseService().db.deleteExercisePermanently(
                                exercise.id,
                                exercise.name,
                              );
                          if (context.mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.clearSnackBars();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Permanently deleted '${exercise.name}'. Workout history preserved.",
                                  style: TextStyle(color: colorScheme.onInverseSurface),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: colorScheme.inverseSurface,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Future.delayed(const Duration(seconds: 2), () {
                              messenger.hideCurrentSnackBar();
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
