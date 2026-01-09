import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class ExerciseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ExerciseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // REFINEMENT: Reduced top/bottom margin for a tighter list
        margin: const EdgeInsets.fromLTRB(0,0,0,12), 
        // REFINEMENT: Switched to symmetric padding to control vertical height specifically
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(14), // Slightly tighter radius
        ),
        child: Row(
          children: [
            // 1. Leaner Icon Container
            Container(
              padding: const EdgeInsets.all(8), // Reduced from 12
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.primaryBlue,
                size: 24, // Explicitly smaller icon
              ),
            ),
            const SizedBox(width: 12),

            // 2. The Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Takes up only needed space
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15, // Matches your lean requirement
                      fontWeight: FontWeight.w600, // Semi-bold looks cleaner than Bold
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 2), // Tighter gap
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12, // Slightly smaller
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Subtle Chevron
            const Icon(
              Icons.chevron_right, 
              color: Colors.grey, 
              size: 18, // Smaller arrow
            ),
          ],
        ),
      ),
    );
  }
}