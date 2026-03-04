import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryCardThumbnailWidget extends StatelessWidget {
  const HistoryCardThumbnailWidget({super.key, required this.processingType});

  final ProcessingType processingType;

  @override
  Widget build(BuildContext context) {
    final isFace = processingType == ProcessingType.face;

    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFace
              ? [ColorConstant.primaryPink, ColorConstant.secondaryPink]
              : [ColorConstant.accentPurple, ColorConstant.primaryPink],
        ),
      ),
    );
  }
}
