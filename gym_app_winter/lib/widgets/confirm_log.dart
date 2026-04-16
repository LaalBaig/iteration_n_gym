import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class ConfirmLog extends StatelessWidget {
  const ConfirmLog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.textWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        "Confirm Log",
        style: TextStyle(
          color: context.colors.textBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Are you sure you want to log this exercise?",
        style: TextStyle(
          color: context.colors.emptyText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "Cancel",
            style: TextStyle(color: context.colors.emptyText),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primaryBlue,
            foregroundColor: context.colors.textWhite,
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