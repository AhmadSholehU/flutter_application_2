import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';

class ExerciseResult {
  final List<Exercise> data;
  final DocumentSnapshot? lastDocument; // Kursor untuk halaman berikutnya

  ExerciseResult({required this.data, this.lastDocument});
}
