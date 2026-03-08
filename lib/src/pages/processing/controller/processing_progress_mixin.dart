import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';

mixin ProcessingProgressMixin<T extends StatefulWidget> on State<T> {
  ProgressingViewController get progressController;

  Worker? _progressWorker;

  @override
  void initState() {
    super.initState();
    _progressWorker = ever<double>(
      progressController.progress,
      (_) {},
    );
  }

  @override
  void dispose() {
    _progressWorker?.dispose();
    super.dispose();
  }
}
