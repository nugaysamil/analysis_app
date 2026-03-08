import 'dart:io';

import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';

class BatchThumbnailGridWidget extends StatelessWidget {
  const BatchThumbnailGridWidget({super.key, required this.controller});

  final BatchProcessingController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.w,
        ),
        itemCount: controller.totalImages,
        itemBuilder: (context, index) {
          return Obx(() {
            final state = controller.tileState(index);
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: state.isCurrent
                      ? ColorConstant.primaryPink
                      : state.hasFailed
                      ? Colors.redAccent
                      : state.isDone
                      ? Colors.greenAccent
                      : ColorConstant.progressTrack,
                  width: state.isCurrent ? 3 : 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(controller.imagePaths[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: ColorConstant.cardBackground,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: ColorConstant.textGrey,
                          size: 28.r,
                        ),
                      ),
                    ),
                    if (state.isDone && !state.hasFailed)
                      Container(
                        color: Colors.black38,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                          size: 28.r,
                        ),
                      ),
                    if (state.hasFailed)
                      Container(
                        color: Colors.black38,
                        child: Icon(
                          Icons.error,
                          color: Colors.redAccent,
                          size: 28.r,
                        ),
                      ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
