
import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/main.dart' as import_main;

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 100, color: context.colors.emptyText),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(fontSize: 16, color: context.colors.emptyText),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Dark Mode", style: TextStyle(fontSize: 16, color: context.colors.textBlack, fontWeight: FontWeight.w600)),
              SizedBox(width: 12),
              Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  import_main.MyApp.of(context).toggleTheme(value);
                },
                activeThumbColor: context.colors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}