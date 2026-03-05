import 'package:analysis_app/src/core/exports/exports.dart';

class PdfResultIconWidget extends StatelessWidget {
  const PdfResultIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 140.h,
      decoration: BoxDecoration(
        color: ColorConstant.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorConstant.primaryPink,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
         StringConstant.pdf,
          style: TextStyle(
            color: ColorConstant.primaryPink,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
