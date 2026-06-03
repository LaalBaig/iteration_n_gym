import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class ExerciseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ExerciseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ?? ValueKey(title),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete?.call();
      },
      confirmDismiss: (direction) async {
        return await showDialog(
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
      },
      background: Container(
        margin: const EdgeInsets.fromLTRB(0,0,0,12), 
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: BouncingButton(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0,0,0,12), 
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
          decoration: BoxDecoration(
            color: context.colors.warmSand,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.colors.borderCream,
                spreadRadius: 1,
                blurRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only( left: 4, right: 16),
              child: Icon(
                Icons.fitness_center,
                color: context.colors.brandPrimary,
                size: 24, 
              ),
            ),
    

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w600, 
                      color: context.colors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 2), 
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12, 
                      color: context.colors.emptyText,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Subtle Chevron
            Icon(
              Icons.chevron_right, 
              color: context.colors.emptyText, 
              size: 18, // Smaller arrow
            ),
          ],
        ),
      ),
    ),
   );
  }
}