import 'package:analysis_app/src/core/exports/exports.dart';

class ResultAppBarWidget extends StatelessWidget {
  const ResultAppBarWidget({
    super.key,
    required this.title,
    required this.onBackTap,
  });

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Icon(
              Icons.arrow_back,
              color: ColorConstant.textWhite,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              color: ColorConstant.textWhite,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
