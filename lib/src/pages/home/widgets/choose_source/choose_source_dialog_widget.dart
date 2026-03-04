import 'package:analysis_app/src/pages/home/widgets/choose_source/choose_source_option_tile_widget.dart';
import 'package:analysis_app/src/core/exports/exports.dart';

class ChooseSourceDialogWidget extends StatelessWidget {
  const ChooseSourceDialogWidget({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorConstant.dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              StringConstant.chooseSource,
              style: TextStyle(
                color: ColorConstant.textWhite,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ChooseSourceOptionTileWidget(
              icon: Icons.camera_alt_outlined,
              label: StringConstant.camera,
              onTap: onCameraTap,
            ),
            SizedBox(height: 12.h),
            ChooseSourceOptionTileWidget(
              icon: Icons.photo_library_outlined,
              label: StringConstant.gallery,
              onTap: onGalleryTap,
            ),
          ],
        ),
      ),
    );
  }
}
