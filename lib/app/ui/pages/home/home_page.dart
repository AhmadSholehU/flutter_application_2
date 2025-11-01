import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/add_consumption_sheet.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/add_workout_sheet.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/consumption_card.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/date_scroller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/summary_card.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/workout_tile.dart';
import 'package:intl/intl.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            formatAppBarTitle(controller.selectedDate.value),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(AddWorkoutSheet(), isScrollControlled: true);
        },
        backgroundColor: Get.theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DateScroller(),

            const SizedBox(height: 24),
            // --- Bagian Header Total Volume ---
            Text(
              'TOTAL VOLUMES',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                '${controller.totalVolume.toStringAsFixed(0)} kg',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Bagian 3 Kartu Ringkasan ---
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Workouts',
                      value: controller.workouts.length.toString(),
                      icon: 'assets/icons/ic_wo.svg',
                      backgroundColor: const Color(0xFF2C2C2E),
                      iconColor: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SummaryCard(
                      title: 'Sets',
                      value: controller.totalSets.toString(),
                      icon: 'assets/icons/ic_set.svg',
                      backgroundColor: const Color(
                        0xFF2C2C2E,
                      ), // Warna abu gelap
                      iconColor: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SummaryCard(
                      title: 'Reps',
                      value: controller.totalReps.toString(),
                      icon: 'assets/icons/ic_rep.svg',
                      backgroundColor: const Color(
                        0xFF2C2C2E,
                      ), // Warna abu gelap
                      iconColor: Colors.lightGreenAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'TODAY\'S CONSUMPTION',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Tampilkan bottom sheet saat diklik
                Get.bottomSheet(
                  AddConsumptionSheet(),
                  isScrollControlled: true,
                );
              },
              child: const ConsumptionCard(),
            ),
            const SizedBox(height: 30),
            // --- Bagian Daftar Latihan ---
            Text(
              'TODAY\'S WORKOUTS',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Obx(() {
              // Tampilkan pesan jika tidak ada data workout
              if (controller.workouts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No workouts yet. Tap the + button to add one!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              // Tampilkan list jika ada data
              return ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.workouts.length,
                itemBuilder: (context, index) {
                  final workout = controller.workouts[index];
                  return WorkoutTile(workout: workout);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- 3. TAMBAHKAN HELPER METHOD INI ---
  // Helper untuk memformat judul AppBar
  String formatAppBarTitle(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Today";
    }
    if (date.day == now.subtract(const Duration(days: 1)).day &&
        date.month == now.month) {
      return "Yesterday";
    }
    // Format tanggal lain (misal: "Oct 27")
    return DateFormat('MMM d').format(date);
  }
}
