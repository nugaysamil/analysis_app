import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';

mixin BatchProgressMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  // Subclasses must provide the controller instance.
  BatchProcessingController get batchController;

  Worker? _indexWorker;
  Worker? _itemWorker;

  late final AnimationController animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late Animation<double> progressAnim = Tween<double>(begin: 0, end: 0)
      .animate(CurvedAnimation(parent: animController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();

    _itemWorker = ever<double>(
      batchController.itemProgress,
      (_) => animateTo(batchController.overallProgress),
    );
    _indexWorker = ever<int>(
      batchController.currentIndex,
      (_) => animateTo(batchController.overallProgress),
    );
  }

  void animateTo(double target) {
    final from = progressAnim.value;
    progressAnim = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );
    animController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _indexWorker?.dispose();
    _itemWorker?.dispose();
    animController.dispose();
    super.dispose();
  }
}