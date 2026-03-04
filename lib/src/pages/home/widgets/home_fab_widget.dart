import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFabWidget extends StatelessWidget {
  const HomeFabWidget({super.key, required this.controller});

  final HomeViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorConstant.fabGlow,
            blurRadius: 24.r,
            spreadRadius: 6.r,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: controller.onNewCaptureTap,
        backgroundColor: ColorConstant.primaryPink,
        elevation: 0,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 28.r),
      ),
    );
  }
}
