import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';
import 'package:flutter_application_2/app/data/models/workout_set_model.dart';
import 'package:flutter_application_2/app/data/services/firestore_service.dart';
import 'package:flutter_application_2/app/controllers/add_workout_controller.dart'; // Kita pakai ulang SetEntryControllers
import 'package:flutter_application_2/app/routes/app_routes.dart';

class WorkoutDetailController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // 1. Ambil data workout yang dikirim dari halaman home
  late final Workout workout;

  // 2. State untuk UI
  var isEditing = false.obs;
  var setEntries = <SetEntryControllers>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil objek Workout dari argumen navigasi
    workout = Get.arguments as Workout;
  }

  // 3. Logika untuk masuk/keluar mode edit
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (isEditing.value) {
      // Jika masuk mode edit, siapkan text controller
      loadSetsForEditing();
    } else {
      // Jika keluar mode edit, bersihkan
      clearSetEntries();
    }
  }

  // 4. Menyiapkan text controller dengan data yang ada
  void loadSetsForEditing() {
    clearSetEntries(); // Bersihkan dulu
    for (var set in workout.setDetails) {
      setEntries.add(
        SetEntryControllers(
          reps: TextEditingController(text: set.reps.toString()),
          weight: TextEditingController(text: set.weight.toString()),
        ),
      );
    }
  }

  // 5. Logika untuk mengelola set (sama seperti di AddWorkout)
  void addNewSet() {
    setEntries.add(
      SetEntryControllers(
        reps: TextEditingController(),
        weight: TextEditingController(),
      ),
    );
  }

  void removeSet(int index) {
    setEntries[index].dispose();
    setEntries.removeAt(index);
  }

  // 6. Logika untuk menyimpan perubahan
  Future<void> saveChanges() async {
    List<WorkoutSet> updatedSetsData = [];
    try {
      for (var entry in setEntries) {
        final reps = int.tryParse(entry.reps.text);
        final weight = double.tryParse(entry.weight.text);
        if (reps == null || weight == null) throw Exception();
        updatedSetsData.add(WorkoutSet(reps: reps, weight: weight));
      }

      // Hitung ulang total
      int setCount = updatedSetsData.length;
      double totalVolume = updatedSetsData.fold(
        0.0,
        (sum, set) => sum + (set.reps * set.weight),
      );

      final updatedData = {
        'setDetails': updatedSetsData.map((s) => s.toJson()).toList(),
        'sets': setCount,
        'totalVolume': totalVolume,
      };

      // 1. Simpan ke Firebase
      await _firestoreService.updateWorkout(workout.id!, updatedData);

      // 2. Perbarui objek 'workout' lokal (yang ada di memori)
      //    (Sekarang ini valid karena field-nya tidak lagi 'final')
      workout.setDetails = updatedSetsData; // <-- Cara yang benar
      workout.sets = setCount;
      workout.totalVolume = totalVolume;

      toggleEditMode(); // Keluar dari mode edit

      // 3. Update UI secara manual (karena 'workout' bukan .obs)
      //    Kita tambahkan 'update()' untuk memberi tahu GetX agar me-refresh UI
      update();

      Get.snackbar("Success", "Workout updated!");
    } catch (e) {
      Get.snackbar("Error", "Please fill all fields correctly.");
    }
  }

  // 7. Logika untuk menghapus workout
  void confirmDeleteWorkout() {
    Get.defaultDialog(
      title: "Delete Workout?",
      middleText:
          "Are you sure you want to delete this workout? This action cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          await _firestoreService.deleteWorkout(workout.id!);
          Get.back(); // Tutup dialog
          Get.offAllNamed(Routes.DASHBOARD); // Kembali ke dashboard
          Get.snackbar("Success", "Workout deleted.");
        } catch (e) {
          Get.snackbar("Error", "Failed to delete workout.");
        }
      },
    );
  }

  // 8. Bersihkan controller
  @override
  void onClose() {
    clearSetEntries();
    super.onClose();
  }

  void clearSetEntries() {
    for (var entry in setEntries) {
      entry.dispose();
    }
    setEntries.clear();
  }
}
