import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';

class RecentlyDeletedScreen extends StatelessWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDarkMode;

    return Scaffold(
      backgroundColor: context.colors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textBlack),
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
            color: context.colors.textBlack,
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
                      color: isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_sweep_outlined,
                      color: context.colors.stoneGray,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Trash is Empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Exercises you delete will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.oliveGray,
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
                  color: isDark ? context.colors.surfaceWhite : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2D2D2D) : context.colors.borderCream,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2B4A) : const Color(0xFFEEECF9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: Color(0xFF4C3BC9),
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
                              color: context.colors.textBlack,
                            ),
                          ),
                          if (exercise.category.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              exercise.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.oliveGray,
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
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
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
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: "Delete permanently",
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: context.colors.textWhite,
                              title: const Text("Delete Permanently"),
                              content: Text(
                                "Are you sure you want to permanently delete '${exercise.name}'? This will erase all history and data associated with it.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Delete Permanently",
                                    style: TextStyle(color: Colors.red),
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
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Permanently deleted '${exercise.name}' and all associated data.",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: context.colors.nearBlack,
                                duration: const Duration(seconds: 2),
                              ),
                            );
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
