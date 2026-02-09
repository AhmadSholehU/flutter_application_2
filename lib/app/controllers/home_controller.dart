import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';
import 'package:flutter_application_2/app/data/models/workout_set_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import repository
import 'package:flutter_application_2/app/data/repositories/workout_repository.dart';

class HomeController extends GetxController {
  // 1. Ganti FirestoreService dengan Repository
  final WorkoutRepository _workoutRepository;

  // 2. Inject via Constructor
  HomeController(this._workoutRepository);

  final workouts = <Workout>[].obs;
  var selectedDate = DateTime.now().obs;

  double get totalVolume =>
      workouts.fold(0, (sum, item) => sum + item.totalVolume);
  int get totalSets => workouts.fold(0, (sum, item) => sum + item.sets);
  int get totalReps => totalSets * 8;

  @override
  void onInit() {
    super.onInit();
    // Gunakan repository untuk stream data
    workouts.bindStream(
      _workoutRepository.getWorkoutsStream(selectedDate.value),
    );
    ever(selectedDate, (newDate) {
      workouts.bindStream(_workoutRepository.getWorkoutsStream(newDate));
    });
  }

  void changeSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
  }

  Future<void> addWorkout({
    required String name,
    required String muscleGroup,
    required List<WorkoutSet> sets,
  }) async {
    try {
      int setCount = sets.length;
      double totalVolume = sets.fold(
        0.0,
        (sum, set) => sum + (set.reps * set.weight),
      );

      final newWorkout = Workout(
        name: name,
        muscleGroup: muscleGroup,
        setDetails: sets,
        totalVolume: totalVolume,
        sets: setCount,
        indicatorColor: Colors.primaries[setCount % Colors.primaries.length],
        createdAt: Timestamp.now(),
      );

      // Gunakan repository untuk menyimpan
      await _workoutRepository.addWorkout(newWorkout);

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
