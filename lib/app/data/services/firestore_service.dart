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
  Stream<List<Workout>> getWorkoutsStream() {
    final userId = _userId;
    if (userId == null)
      return Stream.value([]); // Kembalikan stream kosong jika belum login
    return _db
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList(),
        );
  }
}
