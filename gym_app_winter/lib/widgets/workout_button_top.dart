import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class WorkoutButtonTop extends StatelessWidget {
  const WorkoutButtonTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 12, 24, 16),
      child: Container(
        decoration: BoxDecoration(
          color:AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
              child: Icon(Icons.add, color: AppColors.textWhite,),
            ),
            Expanded(
              child: Container(padding: EdgeInsets.all(16), child: Text("Start Empty Workout",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),),),
            ),
            
          ],
        ),
      ),
    );
  }
}