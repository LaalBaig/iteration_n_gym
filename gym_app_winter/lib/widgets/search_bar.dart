import 'package:flutter/material.dart';
import 'package:gym_app_winter/Schemes/color_scheme.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
  super.key, 
  required this.hintText, 
  required this.controller,
  required this.onChanged
  }
  );
  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12, 24, 24),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: hintText,
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
            );
  }
}
