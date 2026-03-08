import 'dart:io';

import 'package:analysis_app/src/core/exports/exports.dart';

class ProcessingImageWidget extends StatelessWidget {
  const ProcessingImageWidget({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.r,
      height: 140.r,
      decoration: BoxDecoration(
        color: ColorConstant.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            Icons.broken_image_outlined,
            color: ColorConstant.textGrey,
            size: 40.r,
          ),
        ),
      ),
    );
  }
}
