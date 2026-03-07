import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/home/model/history_item_model.dart';
import 'package:analysis_app/src/pages/home/widgets/history/history_card_dismiss_background_widget.dart';
import 'package:analysis_app/src/pages/home/widgets/history/history_card_info_widget.dart';
import 'package:analysis_app/src/pages/home/widgets/history/history_card_thumbnail_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';


class HistoryCardWidget extends StatelessWidget {
  const HistoryCardWidget({
    super.key,
    required this.controller,
    required this.item,
  });

  final HomeViewController controller;
  final HistoryItemModel item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: const HistoryCardDismissBackgroundWidget(),
      onDismissed: (_) => controller.deleteItem(item.id),
      child: GestureDetector(
        onTap: () => controller.onItemTap(item),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: ColorConstant.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              HistoryCardThumbnailWidget(processingType: item.processingType),
              SizedBox(width: 16.w),
              HistoryCardInfoWidget(controller: controller, item: item),
            ],
          ),
        ),
      ),
    );
  }
}
