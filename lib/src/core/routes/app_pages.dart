import 'package:analysis_app/src/core/bindings/app_bindings.dart';
import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/pages/home/view/home_view.dart';
import 'package:analysis_app/src/common/pages/processing/view/processing_view.dart';
import 'package:get/get.dart';

// Defines all pages with their routes, bindings and transitions.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.home;

  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: HomeView.new,
      binding: AppBindings.home(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.processing,
      page: ProcessingView.new,
      binding: AppBindings.processing(),
      transition: Transition.noTransition,
    ),
  ];
}
