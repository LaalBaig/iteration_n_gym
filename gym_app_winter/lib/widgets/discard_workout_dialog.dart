import 'package:flutter/material.dart';

/// Shows a custom, premium confirmation dialog before discarding a workout.
/// Returns `true` if the user confirmed, or `false`/`null` otherwise.
Future<bool?> showDiscardWorkoutDialog(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.error.withValues(alpha: 0.15),
                      colorScheme.error.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  color: colorScheme.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Dialog Title
              Text(
                "Discard Workout?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description text
              Text(
                "Are you sure you want to discard your current workout? All exercises and sets logged in this session will be permanently deleted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              
              // Action buttons
              Row(
                children: [
                  // "Keep" / Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Keep",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // "Discard" / Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Discard",
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
