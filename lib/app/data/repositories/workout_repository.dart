import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/app/data/models/workout_model.dart';

abstract class WorkoutRepository {
  Future<void> addWorkout(Workout workout);
  Stream<List<Workout>> getWorkoutsStream(DateTime date);
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<void> addWorkout(Workout workout) async {
    if (_userId.isEmpty) return;

    // Simpan ke: users/{uid}/workouts
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .add(workout.toMap());
  }

  @override
  Stream<List<Workout>> getWorkoutsStream(DateTime date) {
    if (_userId.isEmpty) return Stream.value([]);

    // Filter range tanggal (Start of Day - End of Day)
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Workout.fromMap(doc.data(), docId: doc.id);
          }).toList();
        });
  }
}
