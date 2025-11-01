import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/app/data/models/daily_nutrition_model.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  // Mendapatkan instance dari Cloud Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper untuk mendapatkan User ID yang sedang login
  String? get _userId => _auth.currentUser?.uid;
  String _nutritionDocId(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); // cth: '2025-11-01'
  }

  // Method untuk menambahkan workout baru
  Future<void> addWorkout(Workout workout) async {
    final userId = _userId;
    if (userId == null) throw Exception("User not logged in");
    // Simpan workout di dalam sub-koleksi milik user
    await _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .add(workout.toFirestore());
  }

  // Method untuk mengambil semua workout milik user yang sedang login
  Stream<List<Workout>> getWorkoutsStream(DateTime selectedDate) {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    // Tentukan rentang waktu: dari awal hari (00:00) hingga akhir hari (23:59)
    DateTime startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
      0,
    );
    DateTime endDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    return _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        // Query baru: hanya ambil data di antara rentang waktu
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList(),
        );
  }

  // TAMBAHKAN METHOD UNTUK UPDATE
  Future<void> updateWorkout(String workoutId, Map<String, dynamic> data) {
    final userId = _userId;
    if (userId == null) throw Exception("User not logged in");
    return _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .update(data);
  }

  // TAMBAHKAN METHOD UNTUK DELETE
  Future<void> deleteWorkout(String workoutId) {
    final userId = _userId;
    if (userId == null) throw Exception("User not logged in");
    return _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  // Method untuk mengambil data nutrisi harian
  Stream<DailyNutrition> getNutritionStream(DateTime date) {
    final userId = _userId;
    if (userId == null) throw Exception("User not logged in");

    final docId = _nutritionDocId(date);
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('nutrition')
        .doc(docId);

    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return DailyNutrition.fromFirestore(snapshot);
      } else {
        // Jika dokumen hari itu belum ada, kirim data default
        return DailyNutrition.defaultData(docId);
      }
    });
  }

  // Method untuk menambah (update) konsumsi
  Future<void> addConsumption(
    DateTime date,
    double calories,
    double protein,
  ) async {
    final userId = _userId;
    if (userId == null) throw Exception("User not logged in");

    final docId = _nutritionDocId(date);
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('nutrition')
        .doc(docId);

    // Gunakan FieldValue.increment untuk menambah data yang ada
    // SetOptions(merge: true) akan membuat dokumen jika belum ada
    await docRef.set({
      'consumedCalories': FieldValue.increment(calories),
      'consumedProtein': FieldValue.increment(protein),
      // Set target jika dokumen baru dibuat (tidak akan menimpa jika sudah ada)
      'targetCalories': 2000,
      'targetProtein': 120,
    }, SetOptions(merge: true));
  }
}
