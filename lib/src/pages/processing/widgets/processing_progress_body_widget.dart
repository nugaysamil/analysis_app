import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/core/exports/exports.dart';

class ProcessingProgressBodyWidget extends StatefulWidget {
  const ProcessingProgressBodyWidget({super.key, required this.controller});

  final ProgressingViewController controller;

  @override
  State<ProcessingProgressBodyWidget> createState() =>
      _ProcessingProgressBodyWidgetState();
}

class _ProcessingProgressBodyWidgetState
    extends State<ProcessingProgressBodyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _progressAnim;
  Worker? _progressWorker;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _progressWorker = ever<double>(
      widget.controller.progress,
      (target) => _animateTo(target),
    );
  }

  void _animateTo(double target) {
    final from = _progressAnim.value;
    _progressAnim = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _progressWorker?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Text(
            widget.controller.stepDescription.value.isEmpty
                ? LocaleKeys.processing.tr
                : widget.controller.stepDescription.value,
            style: TextStyle(
              color: ColorConstant.textWhite,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24.h),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                backgroundColor: ColorConstant.progressTrack,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ColorConstant.primaryPink,
                ),
                minHeight: 6.h,
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        Obx(
          () => Text(
            '${(widget.controller.progress.value * 100).toInt()}%',
            style: TextStyle(color: ColorConstant.textGrey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
