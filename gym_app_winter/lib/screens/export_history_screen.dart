import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_app_winter/utils/responsive_helper.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/database/database_service.dart';
import 'package:gym_app_winter/database/database.dart';
import 'package:gym_app_winter/services/export_service.dart';

enum _ExportScope { all, specific }

class ExportHistoryScreen extends StatefulWidget {
  const ExportHistoryScreen({super.key});

  @override
  State<ExportHistoryScreen> createState() => _ExportHistoryScreenState();
}

class _ExportHistoryScreenState extends State<ExportHistoryScreen> {
  _ExportScope _scope = _ExportScope.all;
  ExportFormat _format = ExportFormat.csv;
  String? _selectedExercise;
  bool _isExporting = false;

  Future<void> _pickExercise(List<Exercise> exercises) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        var query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = query.isEmpty
                ? exercises
                : exercises
                    .where((ex) => ex.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: ResponsiveHelper.h(560)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveHelper.w(20),
                        ResponsiveHelper.h(20),
                        ResponsiveHelper.w(20),
                        ResponsiveHelper.h(8),
                      ),
                      child: Text(
                        'Select Exercise',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.sp(18),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(20)),
                      child: TextField(
                        autofocus: true,
                        onChanged: (val) => setSheetState(() => query = val),
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search exercises...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.h(8)),
                    Flexible(
                      child: filtered.isEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(32)),
                              child: Center(
                                child: Text(
                                  'No exercises found',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final ex = filtered[index];
                                return ListTile(
                                  title: Text(
                                    ex.name,
                                    style: TextStyle(color: colorScheme.onSurface),
                                  ),
                                  subtitle: Text(ex.category),
                                  onTap: () => Navigator.pop(sheetContext, ex.name),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selectedExercise = result);
    }
  }

  Future<void> _runExport() async {
    if (_scope == _ExportScope.specific && _selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an exercise to export.')),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final logs = await DatabaseService().db.watchAllLogsWithWorkoutAndExercise().first;
      await ExportService.export(
        logs: logs,
        format: _format,
        exerciseName: _scope == _ExportScope.specific ? _selectedExercise : null,
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Export Workout History',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: ResponsiveHelper.sp(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: DatabaseService().db.watchAllExercises(),
        builder: (context, snapshot) {
          final exercises = <Exercise>[...?snapshot.data]
            ..sort((a, b) => a.name.compareTo(b.name));

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.w(24),
              vertical: ResponsiveHelper.h(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('SCOPE'),
                SizedBox(height: ResponsiveHelper.h(8)),
                _ChoiceCard(
                  children: [
                    _ChoiceRow(
                      label: 'All Workouts',
                      subtitle: 'Every logged set across your entire history',
                      selected: _scope == _ExportScope.all,
                      onTap: () => setState(() => _scope = _ExportScope.all),
                    ),
                    _ChoiceRow(
                      label: 'Specific Exercise',
                      subtitle: _scope == _ExportScope.specific
                          ? (_selectedExercise ?? 'Tap to choose an exercise')
                          : 'Filter export to one exercise',
                      selected: _scope == _ExportScope.specific,
                      onTap: () {
                        setState(() => _scope = _ExportScope.specific);
                        _pickExercise(exercises);
                      },
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.h(28)),

                _SectionLabel('FORMAT'),
                SizedBox(height: ResponsiveHelper.h(8)),
                _ChoiceCard(
                  children: [
                    _ChoiceRow(
                      label: 'CSV',
                      subtitle: 'Best for spreadsheets (Excel, Sheets)',
                      selected: _format == ExportFormat.csv,
                      onTap: () => setState(() => _format = ExportFormat.csv),
                    ),
                    _ChoiceRow(
                      label: 'JSON',
                      subtitle: 'Structured data for backup or scripts',
                      selected: _format == ExportFormat.json,
                      onTap: () => setState(() => _format = ExportFormat.json),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.h(36)),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isExporting ? null : _runExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.h(16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isExporting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.ios_share, size: 20),
                              SizedBox(width: ResponsiveHelper.w(8)),
                              Text(
                                'Export & Share',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.sp(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.children});
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
                      indent: ResponsiveHelper.w(16),
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ])
            .toList(),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.w(16),
          vertical: ResponsiveHelper.h(14),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colorScheme.primary : context.colors.emptyText,
              size: 22,
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
                      color: context.colors.textBlack,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.h(2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(12),
                      color: context.colors.emptyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
