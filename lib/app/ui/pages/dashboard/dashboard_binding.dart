import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/dashboard_controller.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/controllers/nutrition_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<NutritionController>(() => NutritionController());
  }
}
