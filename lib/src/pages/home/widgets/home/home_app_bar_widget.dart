import 'package:analysis_app/src/core/exports/exports.dart';


class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Text(
        LocaleKeys.appTitle.tr,
        style: TextStyle(
          color: ColorConstant.textWhite,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
