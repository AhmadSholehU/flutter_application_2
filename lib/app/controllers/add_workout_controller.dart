import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/data/models/api_exercise_model.dart';
import 'package:flutter_application_2/app/data/services/exercise_api_service.dart';
import 'dart:async';

class AddWorkoutController extends GetxController {
  final ExerciseApiService _apiService = ExerciseApiService();
  // Temukan HomeController yang sudah ada untuk menyimpan data
  final HomeController _homeController = Get.find<HomeController>();

  // Controllers untuk input form
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // State untuk UI
  var isLoading = false.obs;
  var searchResults = <ApiExercise>[].obs;
  var selectedExercise = Rxn<ApiExercise>(); // Rxn = Rx (reaktif) + nullable

  final _debouncer = Debouncer(milliseconds: 500);
  @override
  void onInit() {
    super.onInit();
  }

  void onSearchChanged(String query) {
    // Jalankan pencarian menggunakan debouncer
    _debouncer.run(() {
      _fetchExercises(query);
    });
  }

  // Mendaftarkan RxString untuk debounce di atas
  @override
  void onReady() {
    super.onReady();
    // Daftarkan RxString agar bisa di-debounce oleh GetX
    Get.put(RxString(searchController.text));
  }

  // Method untuk mencari exercise
  Future<void> _fetchExercises(String query) async {
    if (query.length < 3) {
      searchResults.clear();
      return;
    }
    isLoading.value = true;
    try {
      final results = await _apiService.searchExercisesByName(query);
      searchResults.assignAll(results);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch exercises: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Method saat user memilih exercise dari hasil pencarian
  void selectExercise(ApiExercise exercise) {
    selectedExercise.value = exercise;
    searchController.text = exercise.name;
    searchResults.clear();
  }

  // Method untuk menyimpan workout ke Firebase
  void saveWorkout() {
    if (selectedExercise.value == null) {
      Get.snackbar("Error", "Please select an exercise first.");
      return;
    }
    if (volumeController.text.isEmpty || setsController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in volume and sets.");
      return;
    }

    // Panggil method addWorkout dari HomeController
    _homeController.addWorkout(
      name: selectedExercise.value!.name,
      muscleGroup: selectedExercise.value!.muscle,
      totalVolume: double.parse(volumeController.text),
      sets: int.parse(setsController.text),
    );
  }

  // Bersihkan controller saat bottom sheet ditutup
  @override
  void onClose() {
    _debouncer.dispose();
    volumeController.dispose();
    setsController.dispose();
    searchController.dispose();
    Get.delete<RxString>(); // Hapus RxString dari memori
    super.onClose();
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
