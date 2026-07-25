import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';


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
        insetPadding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(32)),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.w(24)),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveHelper.w(28)),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: Offset(0, 8),
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
                  size: ResponsiveHelper.w(32),
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(20)),
              
              // Dialog Title
              Text(
                "Discard Workout?",
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(22),
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(12)),
              
              // Description text
              Text(
                "Are you sure you want to discard your current workout? All exercises and sets logged in this session will be permanently deleted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(15),
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: ResponsiveHelper.h(28)),
              
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
                          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(14)),
                      ),
                      child: Text(
                        "Keep",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: ResponsiveHelper.sp(15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.w(12)),
                  
                  // "Discard" / Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(14)),
                      ),
                      child: Text(
                        "Discard",
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: ResponsiveHelper.sp(15),
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
