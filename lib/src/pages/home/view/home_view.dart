import 'package:analysis_app/src/core/constants/color_constant.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/home/widgets/history_list_widget.dart';
import 'package:analysis_app/src/pages/home/widgets/home_app_bar_widget.dart';
import 'package:analysis_app/src/pages/home/widgets/home_fab_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeViewModel>();
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeAppBarWidget(),
            SizedBox(height: 16.h),
            Expanded(child: HistoryListWidget(controller: controller)),
          ],
        ),
      ),
      floatingActionButton: HomeFabWidget(controller: controller),
    );
  }
}
