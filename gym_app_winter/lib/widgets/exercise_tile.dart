import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class ExerciseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? category;
  final List<String> muscleGroups;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final double bottomMargin;
  final bool confirmDelete;

  const ExerciseTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.category,
    this.muscleGroups = const [],
    required this.onTap,
    this.onDelete,
    this.bottomMargin = 8.0,
    this.confirmDelete = true,
  });

  Widget _buildTag(String text, Color badgeBgColor, Color brandPurple) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: brandPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDarkMode;

    // Define colors for the dumbbell badge and category pill
    final Color badgeBgColor = isDark 
        ? const Color(0xFF2E2B4A) 
        : const Color(0xFFEEECF9);
    final Color brandPurple = isDark 
        ? const Color(0xFF9F92EC) 
        : const Color(0xFF4C3BC9);

    return Dismissible(
      key: key ?? ValueKey(title),
      direction: onDelete == null ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete?.call();
      },
      confirmDismiss: (direction) async {
        if (!confirmDelete) return true;
        final result = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: context.colors.textWhite,
              title: const Text("Delete Exercise"),
              content: const Text("Are you sure you want to delete this exercise?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
        return result ?? false;
      },
      background: Container(
        margin: EdgeInsets.only(bottom: bottomMargin), 
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: BouncingButton(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: bottomMargin), 
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
              // 1. Dumbbell Icon Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    color: brandPurple,
                    size: 18, 
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Title & Subtitle + Category Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: context.colors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4), 
                    if (muscleGroups.isNotEmpty || (category != null && category!.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: muscleGroups.isNotEmpty 
                            ? muscleGroups.map((m) => _buildTag(m, badgeBgColor, brandPurple)).toList()
                            : [_buildTag(category!, badgeBgColor, brandPurple)],
                        ),
                      ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12, 
                          color: context.colors.emptyText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. Chevron Right
              Icon(
                Icons.chevron_right, 
                color: context.colors.stoneGray, 
                size: 20, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}