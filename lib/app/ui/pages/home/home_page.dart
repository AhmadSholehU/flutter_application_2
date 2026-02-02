import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/add_consumption_sheet.dart';

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
      // Bungkus dengan Container bergradien agar identik dengan DataPage
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2A3A), // Biru tua di atas
              Color(0xFF121212), // Hitam di bawah
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor:
              Colors.transparent, // Transparan agar gradien terlihat
          appBar: AppBar(
            backgroundColor: Colors.transparent, //
            elevation: 0, //
            title: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatAppBarTitle(controller.selectedDate.value),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  // Tambahkan subtitle seperti pada DataPage
                  Text(
                    "Daily Activities Summary.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 120.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DateScroller(),
                const SizedBox(height: 24),

                // --- Bagian Header Total Volume ---
                Text(
                  'TOTAL VOLUMES',
                  style: GoogleFonts.poppins(
                    color: const Color(
                      0xFF4AD0B2,
                    ).withOpacity(0.8), // Menggunakan aksen Teal agar kontras
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    '${controller.totalVolume.toStringAsFixed(0)} kg',
                    style: GoogleFonts.poppins(
                      fontSize: 42, // Diperbesar agar lebih menonjol
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // --- Bagian 3 Kartu Ringkasan ---
                Obx(
                  () => Row(
                    children: [
                      _buildSummaryCard(
                        'Workouts',
                        controller.workouts.length.toString(),
                        Colors.redAccent,
                        'wo',
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'Sets',
                        controller.totalSets.toString(),
                        Colors.amber,
                        'set',
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'Reps',
                        controller.totalReps.toString(),
                        Colors.lightGreenAccent,
                        'rep',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                _buildSectionHeader('TODAY\'S CONSUMPTION'),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Get.bottomSheet(
                    AddConsumptionSheet(),
                    isScrollControlled: true,
                  ),
                  child: const ConsumptionCard(),
                ),

                const SizedBox(height: 35),

                _buildSectionHeader('TODAY\'S WORKOUTS'),
                const SizedBox(height: 16),
                _buildWorkoutList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS UNTUK KONSISTENSI ---

  Widget _buildSummaryCard(
    String title,
    String value,
    Color iconColor,
    String icon,
  ) {
    return Expanded(
      child: SummaryCard(
        title: title,
        value: value,
        icon: 'assets/icons/ic_$icon.svg',
        backgroundColor: const Color(
          0xFF232D37,
        ).withOpacity(0.7), // Sedikit transparan agar menyatu dengan gradien
        iconColor: iconColor,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.grey.withOpacity(0.8),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildWorkoutList() {
    return Obx(() {
      if (controller.workouts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'No workouts yet. Tap the + button to add one!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      }
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.workouts.length,
        itemBuilder: (context, index) =>
            WorkoutTile(workout: controller.workouts[index]),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      );
    });
  }

  String formatAppBarTitle(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year)
      return "Today";
    if (date.day == now.subtract(const Duration(days: 1)).day &&
        date.month == now.month)
      return "Yesterday";
    return DateFormat('MMMM d, y').format(date);
  }
}
