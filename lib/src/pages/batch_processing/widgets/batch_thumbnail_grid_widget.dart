import 'dart:io';

import 'package:analysis_app/src/core/exports/exports.dart';
import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';

class BatchThumbnailGridWidget extends StatelessWidget {
  const BatchThumbnailGridWidget({super.key, required this.controller});

  final BatchProcessingController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
          final isCurrent = controller.currentIndex.value == index;
          final isDone =
              index < controller.currentIndex.value ||
              controller.isComplete.value;
          final hasFailed =
              isDone &&
              index < controller.results.length &&
              !controller.results[index].isSuccess;

          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isCurrent
                      ? ColorConstant.primaryPink
                      : hasFailed
                          ? Colors.redAccent
                          : isDone
                              ? Colors.greenAccent
                              : ColorConstant.progressTrack,
                  width: isCurrent ? 3 : 2,
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
                    ),
                    if (isDone && !hasFailed)
                      Container(
                        color: Colors.black38,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                          size: 28.r,
                        ),
                      ),
                    if (hasFailed)
                      Container(
                        color: Colors.black38,
                        child: Icon(
                          Icons.error,
                          color: Colors.redAccent,
                          size: 28.r,
                        ),
                      ),
                    if (isCurrent && !controller.isComplete.value)
                      Container(
                        color: Colors.black26,
                        child: Center(
                          child: SizedBox(
                            width: 28.r,
                            height: 28.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorConstant.primaryPink,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          });
      },
    );
  }
}
