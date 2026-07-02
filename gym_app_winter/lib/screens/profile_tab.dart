import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/main.dart' as import_main;
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:go_router/go_router.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _displayName = 'Athlete';
  double? _bodyweightKg;
  static const _nameKey = 'userName';
  static const _weightKey = 'userBodyweightKg';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_nameKey);
    final savedWeight = prefs.getDouble(_weightKey);
    if (mounted) {
      setState(() {
        if (savedName != null && savedName.isNotEmpty) _displayName = savedName;
        _bodyweightKg = savedWeight;
      });
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
        ),
        title: Text(
          'Edit Name',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Your name',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, result);
      if (mounted) setState(() => _displayName = result);
    }
  }

  Future<void> _editBodyweight() async {
    final controller = TextEditingController(
      text: _bodyweightKg != null ? _bodyweightKg!.toStringAsFixed(1) : '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
        ),
        title: Text(
          'Edit Bodyweight',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            hintText: '70.0',
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      if (result.isEmpty) {
        await prefs.remove(_weightKey);
        if (mounted) setState(() => _bodyweightKg = null);
      } else {
        final parsed = double.tryParse(result);
        if (parsed != null) {
          await prefs.setDouble(_weightKey, parsed);
          if (mounted) setState(() => _bodyweightKg = parsed);
        }
      }
    }
  }

  String _memberSince(List<LogWithWorkoutAndExercise> logs) {
    if (logs.isEmpty) return 'No workouts yet';
    final earliest = logs.map((l) => l.workout.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Member since ${months[earliest.month - 1]} ${earliest.year}';
  }

  int _thisWeekWorkouts(List<LogWithWorkoutAndExercise> logs) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    return logs
        .map((l) => l.workout.id)
        .toSet()
        .where((id) {
          final workout = logs.firstWhere((l) => l.workout.id == id).workout;
          return workout.startTime.isAfter(weekStart.subtract(const Duration(seconds: 1)));
        })
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'A';

    return StreamBuilder<List<LogWithWorkoutAndExercise>>(
      stream: DatabaseService().db.watchAllLogsWithWorkoutAndExercise(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final totalWorkouts = logs.map((l) => l.workout.id).toSet().length;
        final totalSets = logs.length;
        final thisWeek = _thisWeekWorkouts(logs);
        final memberSince = _memberSince(logs);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.w(24.0),
            vertical: ResponsiveHelper.h(32.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(ResponsiveHelper.w(24)),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      Color.alphaBlend(
                        (Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white)
                            .withValues(alpha: 0.28),
                        colorScheme.primary,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 24, cornerSmoothing: 1.0),
                  ),
                  shadows: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: _editName,
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.sp(28),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.w(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _displayName,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.sp(22),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: _editName,
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveHelper.h(4)),
                          Text(
                            memberSince,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.sp(13),
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.h(20)),

              // ── Stats row ────────────────────────────────────────────────
              Row(
                children: [
                  _StatChip(label: 'Workouts', value: '$totalWorkouts'),
                  SizedBox(width: ResponsiveHelper.w(12)),
                  _StatChip(label: 'Total Sets', value: '$totalSets'),
                  SizedBox(width: ResponsiveHelper.w(12)),
                  _StatChip(label: 'This Week', value: '$thisWeek'),
                ],
              ),

              SizedBox(height: ResponsiveHelper.h(32)),

              // ── General settings ─────────────────────────────────────────
              _SectionLabel('GENERAL'),
              SizedBox(height: ResponsiveHelper.h(8)),

              _SettingsCard(
                children: [
                  _SettingsRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (val) => import_main.MyApp.of(context).toggleTheme(val),
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.h(16)),

              _SectionLabel('BODY'),
              SizedBox(height: ResponsiveHelper.h(8)),

              BouncingButton(
                onTap: _editBodyweight,
                child: _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Bodyweight',
                      subtitle: _bodyweightKg != null
                          ? '${_bodyweightKg!.toStringAsFixed(1)} kg'
                          : 'Not set',
                      trailing: Icon(Icons.chevron_right, color: context.colors.emptyText),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.h(32)),

              // ── Data ─────────────────────────────────────────────────────
              _SectionLabel('DATA'),
              SizedBox(height: ResponsiveHelper.h(8)),

              BouncingButton(
                onTap: () => context.push('/export_history'),
                child: _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.ios_share_outlined,
                      label: 'Export Workout History',
                      subtitle: 'Save as CSV or JSON',
                      trailing: Icon(Icons.chevron_right, color: context.colors.emptyText),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.h(32)),

              // ── Danger zone ──────────────────────────────────────────────
              _DangerZoneSection(
                onClearHistory: () => _confirmAndClearHistory(context),
              ),

              SizedBox(height: ResponsiveHelper.h(40)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAndClearHistory(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
        ),
        title: Text(
          'Clear All History',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will permanently delete all workout sessions and exercise logs. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Clear All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService().db.clearAllHistory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All history has been cleared.'),
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

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveHelper.sp(12),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: context.colors.emptyText,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.h(16),
          horizontal: ResponsiveHelper.w(12),
        ),
        decoration: ShapeDecoration(
          color: context.colors.surfaceWhite,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(22),
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.h(4)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.sp(11),
                color: context.colors.emptyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colors.surfaceWhite,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1.0),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children
            .expand((child) => [
                  child,
                  if (child != children.last)
                    Divider(
                      height: 1,
                      indent: ResponsiveHelper.w(56),
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ])
            .toList(),
      ),
    );
  }
}

class _DangerZoneSection extends StatefulWidget {
  const _DangerZoneSection({required this.onClearHistory});
  final VoidCallback onClearHistory;

  @override
  State<_DangerZoneSection> createState() => _DangerZoneSectionState();
}

class _DangerZoneSectionState extends State<_DangerZoneSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: ResponsiveHelper.sp(12),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: _expanded
                      ? colorScheme.error
                      : context.colors.emptyText,
                ),
              ),
              SizedBox(width: ResponsiveHelper.w(6)),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: _expanded
                      ? colorScheme.error
                      : context.colors.emptyText,
                ),
              ),
            ],
          ),
        ),
        FadeTransition(
          opacity: _fadeAnim,
          child: SizeTransition(
            sizeFactor: _fadeAnim,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: ResponsiveHelper.h(8)),
              child: BouncingButton(
                onTap: widget.onClearHistory,
                child: _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.delete_sweep_outlined,
                      iconColor: colorScheme.error,
                      iconBg: colorScheme.errorContainer,
                      label: 'Clear All History',
                      labelColor: colorScheme.error,
                      subtitle: 'Permanently delete all workout logs',
                      trailing: Icon(Icons.chevron_right, color: context.colors.emptyText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.iconBg,
    this.labelColor,
    });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBg;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.w(16),
        vertical: ResponsiveHelper.h(subtitle != null ? 14 : 4),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg ?? colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(ResponsiveHelper.w(10)),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: ResponsiveHelper.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.sp(16),
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? context.colors.textBlack,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: ResponsiveHelper.h(2)),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(12),
                      color: context.colors.emptyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
