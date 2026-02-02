import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_2/app/data/services/ai_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DataController extends GetxController {
  final AiService _aiService = AiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var heatmapData = <DateTime, int>{}.obs;
  var personalRecords = <Map<String, dynamic>>[].obs;
  // Data harian (7 hari terakhir)
  var dailyLabels = <String>[].obs;
  var dailyVolumes = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  var weeklyTrend = <double>[0, 0, 0, 0].obs;
  // Data Mingguan & Analisis
  var totalWeeklyVolume = 0.0.obs;
  var muscleSplit = <String, double>{}.obs;
  var aiInsight = "Menganalisis data harian Anda...".obs;
  var isLoading = false.obs;
  var isLoadingAi = false.obs;
  var weeklyPRs = <Map<String, dynamic>>[].obs;
  // Di lib/app/controllers/data_controller.dart
  List<MapEntry<String, double>> get sortedMuscleSplit {
    // Mengurutkan dari frekuensi latihan terbanyak
    var entries = muscleSplit.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDailyDataFromFirebase();
  }

  Future<void> fetchDailyDataFromFirebase() async {
    isLoading.value = true;
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = DateTime(now.year, now.month, now.day - 6);
    // Tarik data 28 hari (4 minggu) agar bisa membuat tren mingguan
    DateTime fourWeeksAgo = DateTime(now.year, now.month, now.day - 27);
    try {
      // Query menggunakan 'createdAt' sesuai data di Firebase
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fourWeeksAgo),
          )
          .orderBy('createdAt', descending: false)
          .get();

      Map<String, double> dayMap = {};
      List<String> labels = [];

      // Inisialisasi 7 hari terakhir agar chart tidak kosong
      for (int i = 0; i < 7; i++) {
        DateTime date = sevenDaysAgo.add(Duration(days: i));
        String dateKey = DateFormat('yyyy-MM-dd').format(date);
        dayMap[dateKey] = 0.0;
        labels.add(DateFormat('E').format(date));
      }

      Map<String, double> tempMuscleSplit = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime date = (data['createdAt'] as Timestamp).toDate(); //
        String dateKey = DateFormat('yyyy-MM-dd').format(date);

        // Ambil totalVolume langsung dari field
        double volume = (data['totalVolume'] ?? 0.0).toDouble();
        if (dayMap.containsKey(dateKey)) {
          dayMap[dateKey] = dayMap[dateKey]! + volume;
        }

        // Ambil muscleGroup untuk distribusi otot
        String muscle = data['muscleGroup'] ?? 'General';
        tempMuscleSplit[muscle] = (tempMuscleSplit[muscle] ?? 0) + 1;
      }
      // 2. Proses Weekly Trend (4 Minggu Terakhir)
      _processWeeklyTrend(snapshot.docs);
      dailyLabels.assignAll(labels);
      dailyVolumes.assignAll(dayMap.values.toList());
      muscleSplit.assignAll(tempMuscleSplit);

      //_generateAiTips();
      processHeatmap(snapshot.docs);
      fetchPersonalRecords();
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
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

  void processHeatmap(List<QueryDocumentSnapshot> docs) {
    Map<DateTime, int> tempHeatmap = {};
    for (var doc in docs) {
      DateTime date = (doc['createdAt'] as Timestamp).toDate();
      // Normalisasi tanggal (hilangkan jam/menit)
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      tempHeatmap[normalizedDate] = (tempHeatmap[normalizedDate] ?? 0) + 1;
    }
    heatmapData.value = tempHeatmap;
  }

  void processPersonalRecords(List<QueryDocumentSnapshot> docs) {
    Map<String, Map<String, dynamic>> prMap = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      String name = data['name'] ?? 'Unknown';
      double volume = (data['totalVolume'] ?? 0.0).toDouble();

      if (!prMap.containsKey(name) || volume > prMap[name]!['volume']) {
        prMap[name] = {
          'name': name,
          'volume': volume,
          'date': (data['createdAt'] as Timestamp).toDate(),
        };
      }
    }
    personalRecords.value = prMap.values.toList();
  }

  void _generateAiTips() async {
    isLoadingAi.value = true;
    String prompt =
        """
      User telah mengangkat total: ${dailyVolumes.reduce((a, b) => a + b)} kg minggu ini.
      Otot paling sering dilatih: ${muscleSplit.keys.take(2).join(', ')}.
      Berikan 1 tips singkat dan motivatif untuk latihan berikutnya.
    """;

    aiInsight.value = await _aiService.getAiResponse(prompt);
    isLoadingAi.value = false;
  }

  Future<void> fetchPersonalRecords() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DateTime now = DateTime.now();
    DateTime lastWeek = DateTime(now.year, now.month, now.day - 7);

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeek),
          )
          .get();

      // Map untuk menyimpan PR tertinggi per nama latihan
      Map<String, Map<String, dynamic>> prFinder = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String name = data['name'] ?? 'Unknown';
        DateTime date = (data['createdAt'] as Timestamp).toDate();

        // Cari berat tertinggi di dalam setDetails
        List sets = data['setDetails'] ?? [];
        double maxWeightInWorkout = 0;

        for (var set in sets) {
          double weight = (set['weight'] ?? 0.0).toDouble();
          if (weight > maxWeightInWorkout) maxWeightInWorkout = weight;
        }

        // Simpan jika ini adalah rekor tertinggi untuk latihan tersebut minggu ini
        if (!prFinder.containsKey(name) ||
            maxWeightInWorkout > prFinder[name]!['weight']) {
          DateTime workoutDate = (data['createdAt'] as Timestamp).toDate();
          DateTime now = DateTime.now();

          // Cek apakah tanggal latihan sama dengan hari ini
          bool isToday =
              workoutDate.year == now.year &&
              workoutDate.month == now.month &&
              workoutDate.day == now.day;
          prFinder[name] = {
            'name': name,
            'weight': maxWeightInWorkout,
            'date': date,
            'isToday': isToday,
          };
        }
      }

      // Ubah ke list dan urutkan berdasarkan berat tertinggi
      var sortedPRs = prFinder.values.toList();
      sortedPRs.sort((a, b) {
        // Pertama, urutkan berdasarkan tanggal terbaru
        int dateCompare = b['date'].compareTo(a['date']);
        if (dateCompare != 0) return dateCompare;

        // Jika tanggal sama, urutkan berdasarkan berat beban tertinggi
        return b['weight'].compareTo(a['weight']);
      });
      weeklyPRs.assignAll(sortedPRs);
    } catch (e) {
      print("Error PR: $e");
    }
  }

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
        // 3-4 kali seminggu
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);

        // Memberikan nilai acak 1-5 untuk variasi warna
        // 1-2: Warna Muda, 3-4: Warna Sedang, 5: Warna Pekat
        fakeData[normalizedDate] = random.nextInt(5) + 1;
      }
    }

    heatmapData.value = fakeData;
  }
}
