import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/data/services/firestore_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  // Membuat list workout menjadi reaktif
  final workouts = <Workout>[].obs;

  // Getters untuk menghitung total secara otomatis
  // UI akan update jika list workouts berubah
  double get totalVolume =>
      workouts.fold(0, (sum, item) => sum + item.totalVolume);
  int get totalSets => workouts.fold(0, (sum, item) => sum + item.sets);
  int get totalReps => totalSets * 8; // Asumsi 8 repetisi per set

  @override
  void onInit() {
    super.onInit();
    workouts.bindStream(_firestoreService.getWorkoutsStream());
  }

  Future<void> addWorkout({
    required String name,
    required String muscleGroup,
    required double totalVolume,
    required int sets,
  }) async {
    try {
      final newWorkout = Workout(
        name: name,
        muscleGroup: muscleGroup,
        totalVolume: totalVolume,
        sets: sets,
        // Kita beri warna acak untuk contoh
        indicatorColor: Colors.primaries[sets % Colors.primaries.length],
        createdAt: Timestamp.now(), // Gunakan waktu saat ini
      );
      await _firestoreService.addWorkout(newWorkout);
      Get.back(); // Tutup bottom sheet setelah berhasil
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
