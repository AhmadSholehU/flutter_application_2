import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/app/controllers/nutrition_controller.dart';

class ConsumptionCard extends GetView<NutritionController> {
  const ConsumptionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232d37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gunakan Obx untuk update UI secara reaktif
          Obx(() {
            final nutrition = controller.dailyNutrition.value;
            // Hitung progress (0.0 - 1.0), pastikan tidak lebih dari 1.0
            double calorieProgress =
                (nutrition.consumedCalories / nutrition.targetCalories).clamp(
                  0.0,
                  1.0,
                );
            double proteinProgress =
                (nutrition.consumedProtein / nutrition.targetProtein).clamp(
                  0.0,
                  1.0,
                );

            return Column(
              children: [
                _buildProgressBar(
                  title: "Calorie",
                  currentValue: nutrition.consumedCalories,
                  targetValue: nutrition.targetCalories,
                  progress: calorieProgress,
                  unit: "cal",
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.redAccent,
                ),
                const SizedBox(height: 20),
                _buildProgressBar(
                  title: "Protein",
                  currentValue: nutrition.consumedProtein,
                  targetValue: nutrition.targetProtein,
                  progress: proteinProgress,
                  unit: "gr",
                  icon: Icons
                      .restaurant_rounded, // Ganti dengan ikon daging/protein
                  iconColor: Colors.greenAccent,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Widget untuk progress bar kustom
  Widget _buildProgressBar({
    required String title,
    required double currentValue,
    required double targetValue,
    required double progress,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                children: [
                  TextSpan(
                    text: "${currentValue.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: "/${targetValue.toStringAsFixed(0)} $unit"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Custom Progress Bar dengan Stack
        LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            final double barHeight = 12.0;
            final double iconSize = 28.0;

            return Stack(
              clipBehavior: Clip.none, // Izinkan ikon keluar dari batas
              children: [
                // 1. Latar belakang bar (gelap)
                Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(barHeight / 2),
                  ),
                ),
                // 2. Progress bar (terisi)
                Container(
                  width: barWidth * progress,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(barHeight / 2),
                  ),
                ),
                // 3. Ikon di ujung progress
                Positioned(
                  left: (barWidth * progress) - (iconSize / 2),
                  top: (barHeight / 2) - (iconSize / 2),
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: iconColor, width: 2),
                    ),
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
