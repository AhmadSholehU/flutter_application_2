import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AnalyticsData {
  final Map<String, double> dailyVolumes;
  final Map<String, double> muscleSplit;
  final List<QueryDocumentSnapshot> rawDocs;

  AnalyticsData({
    required this.dailyVolumes,
    required this.muscleSplit,
    required this.rawDocs,
  });
}

abstract class AnalyticsRepository {
  // 1. Ubah nama fungsi dan hapus parameter daysBack
  Future<AnalyticsData> getAllAnalyticsData();
  Future<List<Map<String, dynamic>>> getPersonalRecords(int daysBack);
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<AnalyticsData> getAllAnalyticsData() async {
    if (_userId.isEmpty) {
      return AnalyticsData(dailyVolumes: {}, muscleSplit: {}, rawDocs: []);
    }

    try {
      // 2. Hapus filter where('createdAt') untuk mengambil SEMUA data
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workouts')
          .orderBy('createdAt', descending: false)
          .get();

      Map<String, double> dayMap = {};
      Map<String, double> muscleMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime date = (data['createdAt'] as Timestamp).toDate();
        String dateKey = DateFormat('yyyy-MM-dd').format(date);

        // Volume Total (Semua Waktu)
        double volume = (data['totalVolume'] ?? 0.0).toDouble();
        dayMap[dateKey] = (dayMap[dateKey] ?? 0.0) + volume;

        // Muscle Split (Semua Waktu)
        String muscle = data['muscleGroup'] ?? 'General';
        muscleMap[muscle] = (muscleMap[muscle] ?? 0) + 1;
      }

      return AnalyticsData(
        dailyVolumes: dayMap,
        muscleSplit: muscleMap,
        rawDocs: snapshot.docs, // Ini akan berisi SELURUH riwayat latihan
      );
    } catch (e) {
      throw Exception("Gagal mengambil data analitik: $e");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPersonalRecords(int daysBack) async {
    // ... Logika getPersonalRecords TETAP SAMA seperti sebelumnya
    if (_userId.isEmpty) return [];

    DateTime now = DateTime.now();
    DateTime pastDate = DateTime(now.year, now.month, now.day - daysBack);

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workouts')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(pastDate),
          )
          .get();

      Map<String, Map<String, dynamic>> prFinder = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String name = data['name'] ?? 'Unknown';
        List sets = data['setDetails'] ?? [];

        double maxWeightInWorkout = 0;
        for (var set in sets) {
          double weight = (set['weight'] ?? 0.0).toDouble();
          if (weight > maxWeightInWorkout) maxWeightInWorkout = weight;
        }

        if (!prFinder.containsKey(name) ||
            maxWeightInWorkout > prFinder[name]!['weight']) {
          DateTime workoutDate = (data['createdAt'] as Timestamp).toDate();
          bool isToday =
              workoutDate.year == now.year &&
              workoutDate.month == now.month &&
              workoutDate.day == now.day;

          prFinder[name] = {
            'name': name,
            'weight': maxWeightInWorkout,
            'date': workoutDate,
            'isToday': isToday,
          };
        }
      }

      return prFinder.values.toList();
    } catch (e) {
      throw Exception("Gagal mengambil PR: $e");
    }
  }
}
