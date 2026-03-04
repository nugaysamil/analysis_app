import 'package:analysis_app/src/core/exports/exports.dart';

class ChooseSourceOptionTileWidget extends StatelessWidget {
  const ChooseSourceOptionTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConstant.dialogOptionBackground,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(icon, color: ColorConstant.textGrey, size: 24.r),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  color: ColorConstant.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
