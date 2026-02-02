import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/controllers/exercise_list_controller.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/new_add_workout_sheet.dart';
import 'package:flutter_application_2/app/ui/widgets/exercise_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseListPage extends StatelessWidget {
  final controller = Get.put(ExerciseListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2A3A), // Biru tua
              Color(0xFF121212), // Hitam
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor:
              Colors.transparent, // Transparan agar gradien terlihat
          appBar: AppBar(
            backgroundColor: Colors.transparent, //
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Exercise",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                // Langkah 2: Tambahkan subtitle untuk konsistensi UI
                Text(
                  "Find your routine or add custom.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (value) => controller.onSearchChanged(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search for exercises...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF232D37).withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              // --- TOMBOL ADD CUSTOM EXERCISE ---
              // Tombol ditambahkan di sini, di bawah search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
                  // Saat diklik, buka NewAddWorkoutSheet dengan mode custom
                  onTap: () => Get.bottomSheet(
                    // Kita akan modifikasi widget ini di langkah berikutnya
                    const NewAddWorkoutSheet(isCustom: true),
                    isScrollControlled: true,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Get.theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        "Add custom exercise",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- LIST EXERCISES ---
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.exercises.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.exercises.isEmpty) {
                    return const Center(
                      child: Text(
                        "No exercises found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        controller.exercises.length +
                        (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index ==
                          controller.defaultExercises.length +
                              controller.exercises.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      Exercise ex;
                      // 2. Tampilkan Default Exercises Terlebih Dahulu
                      if (index < controller.defaultExercises.length) {
                        ex = controller.defaultExercises[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index == 0)
                              _buildSectionTitle(
                                "Frequently Used",
                              ), // Label pemisah
                            _buildExerciseItem(context, ex, isDefault: true),
                          ],
                        );
                      }
                      // 3. Tampilkan API Exercises
                      else {
                        final apiIndex =
                            index - controller.defaultExercises.length;
                        ex = controller.exercises[apiIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (apiIndex == 0)
                              _buildSectionTitle(
                                "All Exercises",
                              ), // Label pemisah
                            _buildExerciseItem(context, ex),
                          ],
                        );
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem(
    BuildContext context,
    Exercise ex, {
    bool isDefault = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Menggunakan warna kartu yang sama dengan HomePage/DataPage
        color: const Color(0xFF232D37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: isDefault
            ? Border.all(
                color: const Color(0xFF4AD0B2).withOpacity(0.4),
                width: 1,
              )
            : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          ExerciseImage(imageUrl: ex.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ex.name.capitalizeFirst!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.stars,
                        color: Color(0xFF4AD0B2),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  "${ex.targetMuscles.join(', ')} • ${ex.equipments.join(', ')}",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.bottomSheet(
              NewAddWorkoutSheet(exercise: ex),
              isScrollControlled: true,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDefault
                    ? const Color(0xFF4AD0B2)
                    : Get.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: const Color(0xFF4AD0B2).withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // void _showAddWorkoutSheet(BuildContext context, dynamic exercise) {
  //   // Navigasi ke Bottom Sheet yang sudah dimodifikasi untuk menerima data latihan
  //   Get.bottomSheet(
  //     NewAddWorkoutSheet(exercise: exercise), // Sesuaikan widget sheet Anda
  //     isScrollControlled: true,
  //     ignoreSafeArea: false,
  //   );
  // }
}
