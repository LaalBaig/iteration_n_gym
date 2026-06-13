import 'package:flutter/material.dart';
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
  final bool isCustom;
  final bool showDeleteIcon;

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
    this.isCustom = false,
    this.showDeleteIcon = true,
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
    final colorScheme = Theme.of(context).colorScheme;

    // Define colors for the dumbbell badge and category pill
    final Color badgeBgColor = colorScheme.primaryContainer;
    final Color brandPurple = colorScheme.primary;

    return Dismissible(
      key: key ?? ValueKey(title),
      direction: onDelete == null ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete?.call();
      },
      confirmDismiss: (direction) async {
        if (!confirmDelete) return true;
        return await _showDeleteDialog(context, colorScheme);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: bottomMargin), 
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4), 
                    if (muscleGroups.isNotEmpty || (category != null && category!.isNotEmpty) || isCustom)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (isCustom)
                              _buildTag("Custom", colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            if (muscleGroups.isNotEmpty)
                              ...muscleGroups.map((m) => _buildTag(m, badgeBgColor, brandPurple)).toList()
                            else if (category != null && category!.isNotEmpty)
                              _buildTag(category!, badgeBgColor, brandPurple),
                          ],
                        ),
                      ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12, 
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. Delete Option or Chevron Right
              if (onDelete != null && showDeleteIcon)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if (!confirmDelete) {
                      onDelete!.call();
                      return;
                    }
                    final confirmed = await _showDeleteDialog(context, colorScheme);
                    if (confirmed) {
                      onDelete!.call();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                      size: 22,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right, 
                  color: colorScheme.onSurfaceVariant, 
                  size: 20, 
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, ColorScheme colorScheme) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text("Delete Exercise", style: TextStyle(color: colorScheme.onSurface)),
          content: Text("Are you sure you want to delete this exercise?", style: TextStyle(color: colorScheme.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete", style: TextStyle(color: colorScheme.error)),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}