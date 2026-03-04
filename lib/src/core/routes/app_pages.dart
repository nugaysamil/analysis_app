import 'package:analysis_app/src/core/routes/app_routes.dart';
import 'package:analysis_app/src/pages/home/binding/home_binding.dart';
import 'package:analysis_app/src/pages/home/view/home_view.dart';
import 'package:get/get.dart';

// Defines all pages with their routes, bindings and transitions.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.home;

  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: HomeView.new,
      binding: HomeBinding(),
    ),
  ];
}
