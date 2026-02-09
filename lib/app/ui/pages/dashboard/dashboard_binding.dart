import 'package:flutter_application_2/app/controllers/data_controller.dart';
import 'package:flutter_application_2/app/controllers/exercise_list_controller.dart';
import 'package:flutter_application_2/app/data/repositories/analytics_repository.dart';
import 'package:flutter_application_2/app/data/repositories/exercise_repository.dart';
import 'package:flutter_application_2/app/data/repositories/workout_repository.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/dashboard_controller.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/controllers/nutrition_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());

    Get.lazyPut<NutritionController>(() => NutritionController());

    // 1. Inject Repository Dulu
    Get.lazyPut<WorkoutRepository>(() => WorkoutRepositoryImpl());

    // 2. Inject HomeController dengan Repository di dalamnya
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<WorkoutRepository>()),
    );

    // --- ANALYTICS / DATA TAB DEPENDENCIES (Perbaikan Error 1) ---
    Get.lazyPut<AnalyticsRepository>(() => AnalyticsRepositoryImpl());
    Get.lazyPut<DataController>(
      () => DataController(Get.find<AnalyticsRepository>()),
    );

    // --- EXERCISE LIST TAB DEPENDENCIES (Perbaikan Error 2) ---
    Get.lazyPut<ExerciseRepository>(() => ExerciseRepositoryImpl());
    Get.lazyPut<ExerciseListController>(
      () => ExerciseListController(Get.find<ExerciseRepository>()),
    );
  }
}
