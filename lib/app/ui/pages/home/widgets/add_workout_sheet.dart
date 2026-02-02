import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/app/controllers/add_workout_controller.dart';

// 1. Ubah dari GetView<...> menjadi StatelessWidget
class AddWorkoutSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 2. Inisialisasi controller di sini.
    // GetX akan secara otomatis menghapusnya saat sheet ditutup.
    final AddWorkoutController controller = Get.put(AddWorkoutController());

    // 3. Sisanya sama persis seperti sebelumnya
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Workout",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // --- Search Field ---
            TextFormField(
              controller: controller.searchController,

              decoration: InputDecoration(
                labelText: 'Search Exercise (e.g., bench press)',
                suffixIcon: Obx(
                  () => controller.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Search Results List ---
            Obx(() {
              if (controller.searchResults.isEmpty) {
                return const SizedBox.shrink(); // Kosong jika tidak ada hasil
              }
              return Container(
                height: 150, // Batasi tinggi list
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final exercise = controller.searchResults[index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        exercise.muscle.capitalizeFirst ?? exercise.muscle,
                      ),
                      onTap: () {
                        controller.selectExercise(exercise);
                      },
                    );
                  },
                ),
              );
            }),

            // --- Form Fields (hanya tampil jika exercise sudah dipilih) ---
            Obx(() {
              if (controller.selectedExercise.value == null) {
                return const SizedBox.shrink(); // Sembunyikan jika belum ada exercise
              }
              // Tampilkan daftar set yang dinamis
              return Column(
                children: [
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.setEntries.length,
                    itemBuilder: (context, index) {
                      return _buildSetRow(controller, index);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Tombol "Add Set"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.addNewSet,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Set"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.surface,
                        side: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: controller.saveWorkout, // Panggil method controller
                child: Text(
                  'Save Workout',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(AddWorkoutController controller, int index) {
    final entry = controller.setEntries[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          // Label Set (misal: "1")
          Text(
            "${index + 1}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          // Field "Reps"
          Expanded(
            child: TextFormField(
              controller: entry.reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Reps",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Field "Weight (kg)"
          Expanded(
            child: TextFormField(
              controller: entry.weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tombol Hapus Set
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => controller.removeSet(index),
          ),
        ],
      ),
    );
  }
}
