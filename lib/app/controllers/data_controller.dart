import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart'; // Hanya untuk QueryDocumentSnapshot (jika diperlukan)
import 'package:flutter_application_2/app/data/services/ai_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Import Repository
import 'package:flutter_application_2/app/data/repositories/analytics_repository.dart';

class DataController extends GetxController {
  final AiService _aiService = AiService();

  // Inject Repository
  final AnalyticsRepository _analyticsRepository;
  DataController(this._analyticsRepository);

  var heatmapData = <DateTime, int>{}.obs;
  var weeklyPRs = <Map<String, dynamic>>[].obs;

  // Data Harian (7 Hari)
  var dailyLabels = <String>[].obs;
  var dailyVolumes = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  // Data Mingguan (4 Minggu)
  var weeklyTrend = <double>[0, 0, 0, 0].obs;
  var muscleSplit = <String, double>{}.obs;
  var aiInsight = "Menganalisis data harian Anda...".obs;

  var isLoading = false.obs;
  var isLoadingAi = false.obs;

  List<MapEntry<String, double>> get sortedMuscleSplit {
    var entries = muscleSplit.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    isLoading.value = true;
    try {
      // 1. Ambil Data Harian & Raw Docs (28 hari terakhir untuk trend mingguan)
      final analyticsData = await _analyticsRepository.getAllAnalyticsData();

      // A. Proses Chart Harian (7 Hari Terakhir)
      _processDailyChart(analyticsData.dailyVolumes);

      // B. Proses Muscle Split (Langsung dari repo sudah jadi map)
      muscleSplit.assignAll(analyticsData.muscleSplit);

      // C. Proses Weekly Trend (Logic tetap di controller karena butuh kalkulasi spesifik)
      _processWeeklyTrend(analyticsData.rawDocs);

      // D. Proses Heatmap
      _processHeatmap(analyticsData.rawDocs);

      // 2. Ambil Personal Records (7 Hari Terakhir)
      final prData = await _analyticsRepository.getPersonalRecords(7);
      _sortAndAssignPRs(prData);

      // 3. AI Insights (Opsional)
      // _generateAiTips();
    } catch (e) {
      print("Controller Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _processDailyChart(Map<String, double> dataMap) {
    List<String> labels = [];
    List<double> volumes = [];
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = DateTime(now.year, now.month, now.day - 6);

    for (int i = 0; i < 7; i++) {
      DateTime date = sevenDaysAgo.add(Duration(days: i));
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      labels.add(DateFormat('E').format(date));
      volumes.add(dataMap[dateKey] ?? 0.0);
    }

    dailyLabels.assignAll(labels);
    dailyVolumes.assignAll(volumes);
  }

  void _processWeeklyTrend(List<QueryDocumentSnapshot> docs) {
    List<double> weeks = [0, 0, 0, 0];
    DateTime now = DateTime.now();

    for (var doc in docs) {
      DateTime date = (doc['createdAt'] as Timestamp).toDate();
      double volume = (doc['totalVolume'] ?? 0.0).toDouble();

      int daysAgo = now.difference(date).inDays;
      if (daysAgo < 7)
        weeks[3] += volume; // Minggu ini
      else if (daysAgo < 14)
        weeks[2] += volume; // 1 minggu lalu
      else if (daysAgo < 21)
        weeks[1] += volume; // 2 minggu lalu
      else if (daysAgo < 28)
        weeks[0] += volume; // 3 minggu lalu
    }
    weeklyTrend.assignAll(weeks);
  }

  void _processHeatmap(List<QueryDocumentSnapshot> docs) {
    Map<DateTime, int> tempHeatmap = {};
    for (var doc in docs) {
      DateTime date = (doc['createdAt'] as Timestamp).toDate();
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      tempHeatmap[normalizedDate] = (tempHeatmap[normalizedDate] ?? 0) + 1;
    }
    heatmapData.value = tempHeatmap;
  }

  void _sortAndAssignPRs(List<Map<String, dynamic>> prList) {
    prList.sort((a, b) {
      int dateCompare = b['date'].compareTo(a['date']);
      if (dateCompare != 0) return dateCompare;
      return b['weight'].compareTo(a['weight']);
    });
    weeklyPRs.assignAll(prList);
  }

  void _generateAiTips() async {
    isLoadingAi.value = true;
    double totalVol = dailyVolumes.fold(0, (p, c) => p + c);
    String topMuscle = muscleSplit.keys.isNotEmpty
        ? muscleSplit.keys.first
        : "General";

    String prompt =
        """
      User telah mengangkat total: ${totalVol.toInt()} kg minggu ini.
      Otot paling sering dilatih: $topMuscle.
      Berikan 1 tips singkat dan motivatif.
    """;

    aiInsight.value = await _aiService.getAiResponse(prompt);
    isLoadingAi.value = false;
  }

  // Fungsi fake heatmap untuk testing visual UI
  void generateFakeHeatmapData() {
    Map<DateTime, int> fakeData = {};
    DateTime startDate = DateTime(2025, 11, 1);
    DateTime endDate = DateTime.now();
    Random random = Random();

    for (
      DateTime date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      if (random.nextDouble() < 0.5) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        fakeData[normalizedDate] = random.nextInt(5) + 1;
      }
    }
    heatmapData.value = fakeData;
  }
}
