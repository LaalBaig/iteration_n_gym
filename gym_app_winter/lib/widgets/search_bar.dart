import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 12, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
              child: Icon(Icons.search),
            ),
            Expanded(
              child: TextField(
                onTap: () {
                  //if not focused then focus
                  if (!FocusScope.of(context).hasFocus) {
                    FocusScope.of(context).requestFocus();
                  }
                  //otherwise unfocus
                  else {
                    FocusScope.of(context).unfocus();
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: controller,
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear),
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
