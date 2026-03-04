import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryCardInfoWidget extends StatelessWidget {
  const HistoryCardInfoWidget({
    super.key,
    required this.controller,
    required this.item,
  });

  final HomeViewModel controller;
  final HistoryItemModel item;

  @override
  Widget build(BuildContext context) {
    final title = item.processingType == ProcessingType.face
        ? StringConstant.faceProcessed
        : StringConstant.documentScan;

    final dateStr = controller.formatHistoryDate(item.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: ColorConstant.textWhite,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          dateStr,
          style: TextStyle(
            color: ColorConstant.textGrey,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
