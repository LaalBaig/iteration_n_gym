import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class CustomExerciseScreen extends StatefulWidget {
  const CustomExerciseScreen({super.key});

  @override
  State<CustomExerciseScreen> createState() => _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends State<CustomExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedExerciseType = 'Weights'; 
  String _selectedTrackingType = 'Weight based'; 

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.colors.textBlack,
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String title, String groupValue, ValueChanged<String> onChanged) {
    final isSelected = title == groupValue;
    return Expanded(
      child: BouncingButton(
        onTap: () => onChanged(title),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primaryBlue : context.colors.textWhite,
            border: Border.all(
              color: isSelected ? context.colors.primaryBlue : context.colors.emptyText.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? context.colors.textWhite : context.colors.textBlack,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.textWhite,
      appBar: AppBar(
        backgroundColor: context.colors.textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textBlack),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/add');
            }
          },
        ),
        title: Text(
          "Create Custom Exercise",
          style: TextStyle(
            color: context.colors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/add');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                "Add custom exercise",
                style: TextStyle(
                  color: context.colors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Name of the new exercise"),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _nameController,
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: "E.g. Bulgarian Split Squat",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.emptyText,
                    ),
                  ),
                ),
              ),
              
              _buildSectionTitle("Exercise Type"),
              Row(
                children: [
                  _buildChoiceButton('Bodyweight', _selectedExerciseType, (val) => setState(() => _selectedExerciseType = val)),
                  _buildChoiceButton('Weights', _selectedExerciseType, (val) => setState(() => _selectedExerciseType = val)),
                ],
              ),
              
              _buildSectionTitle("Tracking Type"),
              Row(
                children: [
                  _buildChoiceButton('Time based', _selectedTrackingType, (val) => setState(() => _selectedTrackingType = val)),
                  _buildChoiceButton('Weight based', _selectedTrackingType, (val) => setState(() => _selectedTrackingType = val)),
                ],
              ),
              
              // Spacing so content doesn't get hidden behind the floating button when scrolling to the very bottom
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}