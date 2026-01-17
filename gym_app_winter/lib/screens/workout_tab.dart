import 'package:flutter/material.dart';
import 'package:gym_app_winter/widgets/search_bar.dart';
// Workouts Tab Content
class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  final TextEditingController _controller = TextEditingController();

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
          CustomSearchBar(
            hintText: "Start A New Workout",
            controller: _controller,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
