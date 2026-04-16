import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class WorkoutButtonTop extends StatelessWidget {
  const WorkoutButtonTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 12, 24, 16),
      child: BouncingButton(
        onTap: () {
          context.push('/active_workout');
        },
        child: Container(
          decoration: ShapeDecoration(
            color:context.colors.primaryBlue,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 12,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: Icon(Icons.add, color: Colors.white,),
              ),
              Expanded(
                child: Container(padding: EdgeInsets.all(16), child: Text("Start Empty Workout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}