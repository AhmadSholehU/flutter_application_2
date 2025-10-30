import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/workout_detail_controller.dart';

class WorkoutDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WorkoutDetailController());
  }
}
