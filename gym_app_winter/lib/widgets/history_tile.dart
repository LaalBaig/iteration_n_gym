import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:gym_app_winter/widgets/bouncing_button.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.setData});

  final List<Map<String, int>> setData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: BouncingButton(
        onTap: () {
          if (setData.length > 3) {
            _showFullHistoryDialog(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: context.colors.backgroundGrey,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 14,
                cornerSmoothing: 1,
              ),
            ),
            shadows: [
              BoxShadow(
                color: context.colors.textBlack.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                      color: context.colors.emptyText,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text("Sets", style: TextStyle(color: context.colors.emptyText)),
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
                            style: TextStyle(color: context.colors.emptyText),
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
                    child: Text(
                      "View more",
                      style: TextStyle(
                        color: context.colors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
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
            decoration: ShapeDecoration(
              color: context.colors.backgroundGrey,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 20,
                  cornerSmoothing: 1,
                ),
              ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textBlack,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      BouncingButton(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: context.colors.emptyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Sets", style: TextStyle(color: context.colors.emptyText, fontSize: 16)),
                  const Divider(),
                  for (int i = 0; i < setData.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${i + 1} ",
                              style: TextStyle(color: context.colors.emptyText, fontSize: 16),
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

