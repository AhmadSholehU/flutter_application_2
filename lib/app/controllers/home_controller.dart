import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/data/services/firestore_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';
import 'package:flutter_application_2/app/data/models/workout_set_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  // Membuat list workout menjadi reaktif
  final workouts = <Workout>[].obs;
  var selectedDate = DateTime.now().obs;
  // Getters untuk menghitung total secara otomatis
  // UI akan update jika list workouts berubah
  double get totalVolume =>
      workouts.fold(0, (sum, item) => sum + item.totalVolume);
  int get totalSets => workouts.fold(0, (sum, item) => sum + item.sets);
  int get totalReps => totalSets * 8; // Asumsi 8 repetisi per set

  @override
  void onInit() {
    super.onInit();
    workouts.bindStream(
      _firestoreService.getWorkoutsStream(selectedDate.value),
    );
    ever(selectedDate, (newDate) {
      workouts.bindStream(_firestoreService.getWorkoutsStream(newDate));
    });
  }

  void changeSelectedDate(DateTime newDate) {
    // Set tanggal baru. Ini akan memicu listener 'ever' di atas.
    selectedDate.value = newDate;
  }

  Future<void> addWorkout({
    required String name,
    required String muscleGroup,
    required List<WorkoutSet> sets, // Terima List<WorkoutSet>
  }) async {
    try {
      // Lakukan kalkulasi di sini
      int setCount = sets.length;
      double totalVolume = sets.fold(
        0.0,
        (sum, set) => sum + (set.reps * set.weight),
      );

      final newWorkout = Workout(
        name: name,
        muscleGroup: muscleGroup,
        setDetails: sets, // Simpan detail set
        totalVolume: totalVolume, // Simpan total volume kalkulasi
        sets: setCount, // Simpan jumlah set
        indicatorColor: Colors.primaries[setCount % Colors.primaries.length],
        createdAt: Timestamp.now(),
      );

      await _firestoreService.addWorkout(newWorkout);
      Get.back(); // Tutup bottom sheet
      Get.snackbar(
        "Success",
        "Workout added successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add workout: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
