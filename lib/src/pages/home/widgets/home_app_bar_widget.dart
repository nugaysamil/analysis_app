import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:analysis_app/src/core/constants/string_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Text(
        StringConstant.appTitle,
        style: TextStyle(
          color: ColorConstant.textWhite,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
