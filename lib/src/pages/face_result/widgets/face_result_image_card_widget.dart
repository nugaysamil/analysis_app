import 'dart:io';

import 'package:analysis_app/src/core/exports/exports.dart';

class FaceResultImageCardWidget extends StatelessWidget {
  const FaceResultImageCardWidget({
    super.key,
    required this.label,
    required this.imagePath,
    this.sublabel,
  });

  final String label;
  final String imagePath;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: ColorConstant.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorConstant.textGrey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ColorConstant.textGrey,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstant.scaffoldBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: imagePath.isNotEmpty
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: ColorConstant.textGrey,
                            size: 32.r,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          sublabel ?? '',
                          style: TextStyle(
                            color: ColorConstant.textGrey,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
