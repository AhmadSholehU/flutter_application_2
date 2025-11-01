import 'package:cloud_firestore/cloud_firestore.dart';

class DailyNutrition {
  final String id; // ID Dokumen (misal: '2025-11-01')
  double consumedCalories;
  double consumedProtein;
  final double targetCalories;
  final double targetProtein;

  DailyNutrition({
    required this.id,
    this.consumedCalories = 0,
    this.consumedProtein = 0,
    required this.targetCalories,
    required this.targetProtein,
  });

  factory DailyNutrition.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return DailyNutrition(
      id: snapshot.id,
      consumedCalories: (data['consumedCalories'] as num?)?.toDouble() ?? 0,
      consumedProtein: (data['consumedProtein'] as num?)?.toDouble() ?? 0,
      targetCalories: (data['targetCalories'] as num?)?.toDouble() ?? 2000,
      targetProtein: (data['targetProtein'] as num?)?.toDouble() ?? 120,
    );
  }

  // Jika dokumen tidak ada, buat data default
  factory DailyNutrition.defaultData(String id) {
    return DailyNutrition(
      id: id,
      targetCalories: 2000, // Target default
      targetProtein: 120, // Target default
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'consumedCalories': consumedCalories,
      'consumedProtein': consumedProtein,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
    };
  }
}
