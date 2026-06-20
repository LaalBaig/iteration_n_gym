
import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/main.dart' as import_main;
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(24.0), vertical: ResponsiveHelper.h(32.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Profile Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.w(24)),
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 24,
                  cornerSmoothing: 1.0,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: ResponsiveHelper.w(36),
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Athlete Profile',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(22),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.h(4)),
                      Text(
                        'Track your fitness journey',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(14),
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.h(32)),
          
          // Section: General Settings
          Text(
            "GENERAL",
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(12),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: context.colors.emptyText,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(8)),
          
          Container(
            decoration: ShapeDecoration(
              color: context.colors.surfaceWhite,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 16,
                  cornerSmoothing: 1.0,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(16.0), vertical: ResponsiveHelper.h(8.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveHelper.w(8)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
                        ),
                        child: Icon(
                          Icons.dark_mode_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.w(12)),
                      Text(
                        "Dark Mode",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(16),
                          color: context.colors.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (bool value) {
                      import_main.MyApp.of(context).toggleTheme(value);
                    },
                    activeThumbColor: context.colors.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.h(32)),
          
          // Section: Testing & Developer Options
          Text(
            "TESTING TOOLS",
            style: TextStyle(
              fontSize: ResponsiveHelper.sp(12),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: context.colors.emptyText,
            ),
          ),
          SizedBox(height: ResponsiveHelper.h(8)),
          
          BouncingButton(
            onTap: () => _confirmAndClearHistory(context),
            child: Container(
              padding: EdgeInsets.all(ResponsiveHelper.w(16)),
              decoration: ShapeDecoration(
                color: context.colors.surfaceWhite,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 1.0,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.w(8)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
                    ),
                    child: Icon(
                      Icons.delete_sweep_outlined,
                      color: Theme.of(context).colorScheme.error,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Clear History",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(16),
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.h(2)),
                        Text(
                          "Delete all exercise and workout history",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.sp(12),
                            color: context.colors.emptyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.colors.emptyText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndClearHistory(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1.0,
            ),
          ),
          title: Text(
            "Clear History",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to permanently delete all exercise and workout history? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                "Clear All",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DatabaseService().db.clearAllHistory();
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All exercise and workout history has been cleared."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}