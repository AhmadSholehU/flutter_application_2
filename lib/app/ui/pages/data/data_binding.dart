import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/data_controller.dart';
import 'package:flutter_application_2/app/data/repositories/analytics_repository.dart';

class DataBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inject Repository
    Get.lazyPut<AnalyticsRepository>(() => AnalyticsRepositoryImpl());

    // 2. Inject Controller dengan Repo
    Get.lazyPut<DataController>(
      () => DataController(Get.find<AnalyticsRepository>()),
    );
  }
}
