import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class ConfirmLog extends StatelessWidget {
  const ConfirmLog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.textWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "Confirm Log",
        style: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        "Are you sure you want to log this exercise?",
        style: TextStyle(
          color: AppColors.emptyText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.emptyText),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Log Exercise"),
        ),
      ],
    );
  }
}