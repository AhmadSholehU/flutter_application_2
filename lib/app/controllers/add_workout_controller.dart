import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/data/models/api_exercise_model.dart';
import 'package:flutter_application_2/app/data/services/exercise_api_service.dart';
import 'package:flutter_application_2/app/data/models/workout_set_model.dart';
import 'dart:async';

// Helper class untuk menampung text controller dari setiap set
class SetEntryControllers {
  final TextEditingController reps;
  final TextEditingController weight;

  SetEntryControllers({required this.reps, required this.weight});

  void dispose() {
    reps.dispose();
    weight.dispose();
  }
}

class AddWorkoutController extends GetxController {
  final ExerciseApiService _apiService = ExerciseApiService();
  // Temukan HomeController yang sudah ada untuk menyimpan data
  final HomeController _homeController = Get.find<HomeController>();

  // Controllers untuk input form
  final TextEditingController searchController = TextEditingController();
  var setEntries = <SetEntryControllers>[].obs; // List dinamis untuk set

  // State untuk UI
  var isLoading = false.obs;
  var searchResults = <ApiExercise>[].obs;
  var selectedExercise = Rxn<ApiExercise>(); // Rxn = Rx (reaktif) + nullable

  final _debouncer = Debouncer(milliseconds: 500);
  @override
  void onInit() {
    super.onInit();
    ever(selectedExercise, (exercise) {
      if (exercise != null && setEntries.isEmpty) {
        addNewSet();
      }
    });
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

  void addNewSet() {
    setEntries.add(
      SetEntryControllers(
        reps: TextEditingController(),
        weight: TextEditingController(),
      ),
    );
  }

  void removeSet(int index) {
    // Hapus controller dari memori sebelum menghapus dari list
    setEntries[index].dispose();
    setEntries.removeAt(index);
  }

  // Method untuk menyimpan workout ke Firebase
  void saveWorkout() {
    if (selectedExercise.value == null) {
      Get.snackbar("Error", "Please select an exercise first.");
      return;
    }
    if (setEntries.isEmpty) {
      Get.snackbar("Error", "Please add at least one set.");
      return;
    }

    List<WorkoutSet> setsData = [];
    try {
      // Loop melalui setiap text controller dan parse datanya
      for (var entry in setEntries) {
        final reps = int.tryParse(entry.reps.text);
        final weight = double.tryParse(entry.weight.text);

        if (reps == null || weight == null || reps <= 0 || weight < 0) {
          throw Exception("Invalid data in one of the sets.");
        }
        setsData.add(WorkoutSet(reps: reps, weight: weight));
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Please fill all reps and weight fields correctly.",
      );
      return;
    }

    // Panggil method addWorkout dari HomeController dengan data set yang baru
    _homeController.addWorkout(
      name: selectedExercise.value!.name,
      muscleGroup: selectedExercise.value!.muscle,
      sets: setsData,
    );
  }

  // Bersihkan controller saat bottom sheet ditutup
  @override
  void onClose() {
    _debouncer.dispose();
    searchController.dispose();
    for (var entry in setEntries) {
      entry.dispose();
    }
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
