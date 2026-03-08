import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/home/widgets/history/history_list_widget.dart';
import 'package:analysis_app/src/pages/home/widgets/home/home_app_bar_widget.dart';
import 'package:analysis_app/src/pages/home/widgets/home/home_fab_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';

class HomeView extends GetView<HomeViewController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
