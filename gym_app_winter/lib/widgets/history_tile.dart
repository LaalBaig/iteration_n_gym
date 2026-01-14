import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.date, required this.sets, required this.reps, required this.weight});
  final String date;
  final String sets;
  final String reps;
  final String weight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color : AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(14)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,),),
                ],
              ),
              SizedBox(height: 10),
              Text("Sets", style: TextStyle(color: AppColors.emptyText),),
              Divider(),
              for (int i = 0; i < int.parse(sets); i++)
                Column(
                  children: [
                    Row(
                      children: [
                        Text("${i+1} ", style: TextStyle(color: AppColors.emptyText,),),
                        SizedBox(width: 12,),
                        Text("$reps  reps  x  ${weight} kg", style: TextStyle(fontWeight: FontWeight.w400,),),
                      ],
                    ),
                    SizedBox(height: 6,),
                  ],
                ),
      
            ],
          )),
    );
  }
}