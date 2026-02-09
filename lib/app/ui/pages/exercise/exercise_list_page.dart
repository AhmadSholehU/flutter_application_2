import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/app/controllers/exercise_list_controller.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';
import 'package:flutter_application_2/app/ui/widgets/exercise_image.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/new_add_workout_sheet.dart';

class ExerciseListPage extends GetView<ExerciseListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Gradient (Sesuai tema Home & Analytics)
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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Exercise",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
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
              // --- 1. SEARCH BAR ---
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

              // --- 2. TOMBOL ADD CUSTOM EXERCISE ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    const NewAddWorkoutSheet(isCustom: true),
                    isScrollControlled: true,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4AD0B2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4AD0B2).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Get.theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Add custom exercise",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 3. LIST EXERCISES (INFINITE SCROLL) ---
              Expanded(
                child: Obx(() {
                  // A. Loading Awal (Hanya saat list kosong & sedang loading)
                  if (controller.isLoading.value &&
                      controller.exercises.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // B. Kosong (Tidak ada data sama sekali)
                  if (controller.exercises.isEmpty) {
                    return Center(
                      child: Text(
                        "No exercises found",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }

                  // C. List Data dengan Loader di Bawah
                  return ListView.builder(
                    // PENTING: Hubungkan ScrollController dari Controller ke sini
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    // Tambah +1 untuk tempat loader di paling bawah
                    itemCount: controller.exercises.length + 1,
                    itemBuilder: (context, index) {
                      // Logic Loader Bagian Bawah
                      if (index == controller.exercises.length) {
                        return Obx(() {
                          // Tampilkan loader hanya jika sedang memuat halaman berikutnya
                          if (controller.isMoreLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          // Jika tidak ada lagi data, beri jarak kosong sedikit
                          return const SizedBox(height: 50);
                        });
                      }

                      // Render Item Latihan
                      final Exercise ex = controller.exercises[index];
                      return _buildExerciseItem(context, ex);
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

  // --- WIDGET ITEM (Sama seperti sebelumnya, disederhanakan) ---
  Widget _buildExerciseItem(BuildContext context, Exercise ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF232D37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          // Gambar Latihan
          ExerciseImage(imageUrl: ex.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.name.capitalizeFirst!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  // Menampilkan target muscle pertama & equipment
                  "${ex.targetMuscles.isNotEmpty ? ex.targetMuscles.first : '-'} • ${ex.equipments.isNotEmpty ? ex.equipments.first : '-'}",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Tombol Add (+)
          GestureDetector(
            onTap: () => Get.bottomSheet(
              NewAddWorkoutSheet(exercise: ex),
              isScrollControlled: true,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
