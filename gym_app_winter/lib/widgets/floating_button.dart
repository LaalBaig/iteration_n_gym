import 'package:flutter/material.dart';
import 'package:gym_app_winter/Schemes/color_scheme.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    required this.onPressed,
    required this.label,
  });
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.fromLTRB(24,20,24,20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Match Figma rounding
        ),
      ),
      
      child: Text(label),
    );
  }
}
