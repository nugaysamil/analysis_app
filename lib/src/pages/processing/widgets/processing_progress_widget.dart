import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/pages/processing/widgets/processing_error_body_widget.dart';
import 'package:analysis_app/src/pages/processing/widgets/processing_progress_body_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProcessingProgressWidget extends StatelessWidget {
  const ProcessingProgressWidget({super.key, required this.controller});

  final ProgressingViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.hasError.value
          ? ProcessingErrorBodyWidget(controller: controller)
          : ProcessingProgressBodyWidget(controller: controller),
    );
  }
}
