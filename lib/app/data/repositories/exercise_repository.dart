import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';
import 'package:flutter_application_2/app/data/models/exercise_result.dart';

// Abstract class agar controller tidak bergantung pada implementasi detail
abstract class ExerciseRepository {
  Future<ExerciseResult> getExercises({
    int limit = 10,
    DocumentSnapshot? startAfter,
  });
  Future<List<Exercise>> searchExercises(String query);
}

class ExerciseRepositoryImpl implements ExerciseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName =
      'default_exercises'; // Pastikan nama koleksi di Firebase sesuai

  @override
  Future<ExerciseResult> getExercises({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(collectionName)
          .orderBy('name') // Penting: Harus diurutkan agar pagination stabil
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot snapshot = await query.get();

      // Konversi data
      List<Exercise> exercises = snapshot.docs.map((doc) {
        return Exercise.fromJson(
          doc.data() as Map<String, dynamic>,
          docId: doc.id,
        );
      }).toList();

      // Ambil dokumen terakhir sebagai kursor
      DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;

      return ExerciseResult(data: exercises, lastDocument: lastDoc);
    } catch (e) {
      throw Exception("Gagal mengambil data dari Firebase: $e");
    }
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      // Pencarian sederhana prefix (Case sensitive tergantung input user/data)
      // Pastikan data di firebase konsisten (misal: disimpan lowercase)
      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where(
            'name',
            isLessThan: query + '\uf8ff',
          ) // Karakter unicode terakhir
          .get();

      return snapshot.docs.map((doc) {
        return Exercise.fromJson(
          doc.data() as Map<String, dynamic>,
          docId: doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception("Gagal mencari data: $e");
    }
  }
}
