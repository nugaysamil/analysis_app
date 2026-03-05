import 'package:analysis_app/src/core/exports/exports.dart';

class ResultActionButtonWidget extends StatelessWidget {
  const ResultActionButtonWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ColorConstant.primaryPink, ColorConstant.secondaryPink],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: ColorConstant.textWhite,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
