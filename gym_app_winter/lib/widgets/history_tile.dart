import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.setData});

  final List<Map<String, int>> setData;

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
                  Text("Wednesday, December 23", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,),),
                  Icon(Icons.delete_outline, size: 24, color: AppColors.emptyText,),
                ],
              ),
              SizedBox(height: 10),
              Text("Sets", style: TextStyle(color: AppColors.emptyText),),
              Divider(),
              for (int i = 0; i < setData.length; i++)
                Column(
                  children: [
                    Row(
                      children: [
                        Text("${i+1} ", style: TextStyle(color: AppColors.emptyText,),),
                        SizedBox(width: 12,),
                        Text("${setData[i]['reps']}  reps  x  ${setData[i]['weight']} kg", style: TextStyle(fontWeight: FontWeight.w400,),),
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