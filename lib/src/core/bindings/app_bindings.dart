import 'package:analysis_app/src/pages/batch_processing/controller/batch_processing_controller.dart';
import 'package:analysis_app/src/pages/batch_summary/controller/batch_summary_controller.dart';
import 'package:analysis_app/src/pages/processing/controller/processing_view_controller.dart';
import 'package:analysis_app/src/pages/face_result/controller/face_result_view_controller.dart';
import 'package:analysis_app/src/pages/history_detail/controller/history_detail_view_controller.dart';
import 'package:analysis_app/src/pages/home/controller/home_view_controller.dart';
import 'package:analysis_app/src/pages/pdf_result/controller/pdf_result_view_controller.dart';
import 'package:get/get.dart';

// Centralized binding management for all pages.
class AppBindings {
  AppBindings._();

  // Home page dependencies.
  static BindingsBuilder<dynamic> home() {
    return BindingsBuilder(() {
      Get.lazyPut<HomeViewController>(HomeViewController.new);
    });
  }

  // Processing page dependencies.
  static BindingsBuilder<dynamic> processing() {
    return BindingsBuilder(() {
      Get.lazyPut<ProgressingViewController>(ProgressingViewController.new);
    });
  }

  // Face result page dependencies.
  static BindingsBuilder<dynamic> faceResult() {
    return BindingsBuilder(() {
      Get.lazyPut<FaceResultViewController>(FaceResultViewController.new);
    });
  }

  // PDF result page dependencies.
  static BindingsBuilder<dynamic> pdfResult() {
    return BindingsBuilder(() {
      Get.lazyPut<PdfResultViewController>(PdfResultViewController.new);
    });
  }

  // History detail page dependencies.
  static BindingsBuilder<dynamic> historyDetail() {
    return BindingsBuilder(() {
      Get.lazyPut<HistoryDetailViewController>(HistoryDetailViewController.new);
    });
  }

  // Batch processing page dependencies.
  static BindingsBuilder<dynamic> batchProcessing() {
    return BindingsBuilder(() {
      Get.lazyPut<BatchProcessingController>(BatchProcessingController.new);
    });
  }

  // Batch summary page dependencies.
  static BindingsBuilder<dynamic> batchSummary() {
    return BindingsBuilder(() {
      Get.lazyPut<BatchSummaryController>(BatchSummaryController.new);
    });
  }
}
