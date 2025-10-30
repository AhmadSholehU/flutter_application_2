import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Mendapatkan instance dari Cloud Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper untuk mendapatkan User ID yang sedang login
  String? get _userId => _auth.currentUser?.uid;

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
}
