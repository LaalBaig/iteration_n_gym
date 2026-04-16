import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/workout_button_top.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Workouts Tab Content
class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  //   final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Track Workouts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          WorkoutButtonTop(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              "Routines",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: BouncingButton(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colors.backgroundGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.plus,
                              color: const Color.fromARGB(255, 195, 195, 195),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "New Routine",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: context.colors.textBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: BouncingButton(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colors.backgroundGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: const Color.fromARGB(255, 195, 195, 195),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Explore Routines",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
