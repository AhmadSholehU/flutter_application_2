import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/exercise_list_controller.dart';
import 'package:flutter_application_2/app/data/repositories/exercise_repository.dart';

class ExerciseListBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inject Repository terlebih dahulu
    // Get.lazyPut membuat objek hanya saat dibutuhkan (hemat memori)
    Get.lazyPut<ExerciseRepository>(() => ExerciseRepositoryImpl());

    // 2. Inject Controller, dan masukkan Repository yang sudah di-inject di atas
    Get.lazyPut<ExerciseListController>(
      () => ExerciseListController(Get.find<ExerciseRepository>()),
    );
  }
}
