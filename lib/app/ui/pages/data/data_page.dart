import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/controllers/data_controller.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DataPage extends StatelessWidget {
  final DataController controller = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          backgroundColor: Colors.transparent, // Agar gradien terlihat
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analytics",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                // Subtitle baru
                Text(
                  "Your Progress Overview.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildAiInsightCard(), // Kartu Tips dari AI
                const SizedBox(height: 20),
                _buildDailyVolumeChart(),
                const SizedBox(height: 20),
                _buildWeeklyTrendChart(), // Bar Chart Volume
                const SizedBox(height: 20),
                _buildMuscleRankChart(),
                const SizedBox(height: 20),
                _buildConsistencyHeatmap(),
                const SizedBox(height: 20),
                _buildPersonalRecords(), // Pie Chart Otot
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.2),
            Colors.purpleAccent.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text(
                "AI Smart Tips",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => controller.isLoadingAi.value
                ? const LinearProgressIndicator()
                : Text(
                    controller.aiInsight.value,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyHeatmap() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232d37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Workout Consistency",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            return HeatMap(
              datasets: Map<DateTime, int>.from(controller.heatmapData),
              colorMode: ColorMode.opacity,
              defaultColor: Colors.white.withOpacity(0.05),
              textColor: Colors.white,
              showColorTip: false,
              showText: false,
              scrollable: true,
              size: 20,
              colorsets: {1: Get.theme.colorScheme.primary},
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendChart() {
    // Nilai target statis (bisa dibuat dinamis dari controller nanti)
    const double targetValue = 2500;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF232d37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Trend",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(
              () => LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  // Menambahkan garis horizontal untuk Target
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: targetValue,
                        color: const Color(0xFF4AD0B2),
                        strokeWidth: 2,
                        dashArray: [8, 4], // Garis putus-putus
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(bottom: 5),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          labelResolver: (line) => "Target", // Label "Target"
                        ),
                      ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.weeklyTrend.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF4AD0B2),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      // Kustomisasi titik data agar putih dengan border teal
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: const Color(0xFF4AD0B2),
                          );
                        },
                      ),
                      // Area di bawah kurva dengan gradien vertikal
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF4AD0B2).withOpacity(0.5),
                            const Color(0xFF4AD0B2).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Judul di kiri, View More di kanan
        Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Menjauhkan posisi antar anak widget
          crossAxisAlignment:
              CrossAxisAlignment.center, // Memastikan sejajar secara vertikal
          children: [
            Text(
              "Last Week's PRs",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Tombol hanya muncul jika PR lebih dari 3
            Obx(
              () => controller.weeklyPRs.length > 3
                  ? TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets
                            .zero, // Menghilangkan padding bawaan agar rapat ke kanan
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showAllPrSheet(),
                      child: Text(
                        "View More",
                        style: GoogleFonts.poppins(
                          color: const Color(
                            0xFF4AD0B2,
                          ), // Warna teal konsisten
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Obx(() {
          if (controller.weeklyPRs.isEmpty) {
            return const Center(
              child: Text(
                "No PRs last week",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final displayList = controller.weeklyPRs.take(3).toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              return _buildPrItem(displayList[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildDailyVolumeChart() {
    final double maxY = controller.dailyVolumes.isEmpty
        ? 100
        : controller.dailyVolumes.reduce((a, b) => a > b ? a : b) * 1.2;
    return Container(
      height: 320,
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF232d37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Volume",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(
              () => BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: false, // Nonaktifkan tooltip default
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        // Fungsi ini sekarang digunakan untuk menampilkan label permanen
                        return BarTooltipItem(
                          "${rod.toY.toInt()} kg",
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 &&
                              index < controller.dailyLabels.length) {
                            return Text(
                              controller.dailyLabels[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text("");
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: controller.dailyVolumes.asMap().entries.map((
                    entry,
                  ) {
                    return BarChartGroupData(
                      x: entry.key,
                      showingTooltipIndicators: entry.value > 0 ? [0] : [],
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: const Color(0xFF4AD0B2), // Warna teal cerah
                          width: 22, // Batang lebih lebar
                          // Membuat ujung batang bulat sempurna seperti kapsul
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleRankChart() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF232d37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Muscle Focus Ranking",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 25),
          Obx(() {
            final sortedData = controller.sortedMuscleSplit;
            if (sortedData.isEmpty)
              return const Center(
                child: Text("No data", style: TextStyle(color: Colors.grey)),
              );

            // Ambil nilai tertinggi sebagai pembanding (100%)
            double maxVal = sortedData.first.value;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: sortedData.length,
              itemBuilder: (context, index) {
                final entry = sortedData[index];
                final double percent = entry.value / maxVal;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == sortedData.length - 1 ? 0 : 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(), // Nama otot
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${entry.value.toInt()} sessions",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar Custom
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percent,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4AD0B2),
                                    Color(0xFF2196F3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showAllPrSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E), // Background gelap konsisten
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              "All Weekly PRs",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: controller.weeklyPRs.length,
                itemBuilder: (context, index) {
                  return _buildPrItem(controller.weeklyPRs[index]);
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  Widget _buildPrItem(Map<String, dynamic> pr) {
    final DateTime date = pr['date'];
    final bool isNewRecord = pr['isToday'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF232d37).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Kotak Tanggal Menonjol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4AD0B2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4AD0B2).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(date),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4AD0B2),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date).toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        pr['name'],
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isNewRecord) ...[
                      const SizedBox(width: 8),
                      _buildNewBadge(), // Panggil badge NEW yang sudah dibuat sebelumnya
                    ],
                  ],
                ),
                Text(
                  isNewRecord
                      ? "Just achieved today! 🔥"
                      : "Highest set weight",
                  style: GoogleFonts.poppins(
                    color: isNewRecord ? const Color(0xFF4AD0B2) : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${pr['weight'].toInt()}",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4AD0B2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "KG",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4AD0B2), // Warna teal utama
        borderRadius: BorderRadius.circular(4),
        // Efek glow agar badge terlihat menyala di dark mode
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4AD0B2).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        "NEW",
        style: GoogleFonts.poppins(
          color: Colors.black, // Kontras gelap di atas warna cerah
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
