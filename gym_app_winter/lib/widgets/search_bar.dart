import 'package:flutter/material.dart';
import 'package:gym_app_winter/utils/responsive_helper.dart';


class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });
  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 12, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, 0, 0, 0),
              child: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: TextField(
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.w(12)),
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: ResponsiveHelper.sp(16),
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.w(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.w(12.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: controller,
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.clear,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                controller.clear();
                // FocusScope.of(context).unfocus();
                onChanged("");
              },
            ),
          ],
        ),
      ),
    );
  }
}
