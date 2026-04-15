import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.setData});

  final List<Map<String, int>> setData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Material(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (setData.length > 3) {
              _showFullHistoryDialog(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Wednesday, December 23",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.delete_outline,
                      size: 24,
                      color: AppColors.emptyText,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text("Sets", style: TextStyle(color: AppColors.emptyText)),
                Divider(),
                for (
                  int i = 0;
                  i < (setData.length > 3 ? 3 : setData.length);
                  i++
                )
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "${i + 1} ",
                            style: TextStyle(color: AppColors.emptyText),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "${setData[i]['reps']}  reps  x  ${setData[i]['weight']} kg",
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                if (setData.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () {
                        _showFullHistoryDialog(context);
                      },
                      child: Text(
                        "View more",
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Wednesday, December 23",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: AppColors.emptyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Sets", style: TextStyle(color: AppColors.emptyText, fontSize: 16)),
                  const Divider(),
                  for (int i = 0; i < setData.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${i + 1} ",
                              style: const TextStyle(color: AppColors.emptyText, fontSize: 16),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "${setData[i]['reps']}  reps  x  ${setData[i]['weight']} kg",
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

