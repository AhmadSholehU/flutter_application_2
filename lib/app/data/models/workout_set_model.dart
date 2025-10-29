class WorkoutSet {
  final int reps;
  final double weight;

  WorkoutSet({required this.reps, required this.weight});

  // Method untuk mengubah objek menjadi Map (untuk Firestore)
  Map<String, dynamic> toJson() {
    return {'reps': reps, 'weight': weight};
  }

  // Factory untuk membuat objek dari Map (dari Firestore)
  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }
}
