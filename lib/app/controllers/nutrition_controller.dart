import 'package:get/get.dart';
import 'package:flutter_application_2/app/data/models/daily_nutrition_model.dart';
import 'package:flutter_application_2/app/data/services/firestore_service.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart'; // Untuk mendengarkan perubahan tanggal

class NutritionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final HomeController _homeController = Get.find<HomeController>();

  // State untuk data nutrisi
  var dailyNutrition = DailyNutrition.defaultData('default').obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Ambil data nutrisi untuk tanggal yang sedang dipilih
    dailyNutrition.bindStream(
      _firestoreService.getNutritionStream(_homeController.selectedDate.value),
    );

    // 2. Dengarkan perubahan tanggal dari HomeController
    ever(_homeController.selectedDate, (newDate) {
      dailyNutrition.bindStream(_firestoreService.getNutritionStream(newDate));
    });
  }

  // Method untuk menambah konsumsi
  Future<void> addConsumption(double calories, double protein) async {
    try {
      // Gunakan tanggal yang sedang dipilih dari HomeController
      await _firestoreService.addConsumption(
        _homeController.selectedDate.value,
        calories,
        protein,
      );
      Get.back(); // Tutup bottom sheet
      Get.snackbar("Success", "Consumption added!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add consumption.");
    }
  }
}
