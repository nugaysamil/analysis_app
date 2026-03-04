import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryCardDismissBackgroundWidget extends StatelessWidget {
  const HistoryCardDismissBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(Icons.delete_outline, color: Colors.white, size: 24.r),
    );
  }
}
