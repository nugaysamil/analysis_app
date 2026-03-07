import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/home/widgets/history/history_card_widget.dart';

class HistoryListWidget extends StatelessWidget {
  const HistoryListWidget({super.key, required this.controller});

  final HomeViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.historyItems.isEmpty) {
        return Center(
          child: Text(
            LocaleKeys.noHistoryItems.tr,
            style: TextStyle(
              color: ColorConstant.textGrey,
              fontSize: 16.sp,
            ),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: controller.historyItems.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = controller.historyItems[index];
          return HistoryCardWidget(controller: controller, item: item);
        },
      );
    });
  }
}
