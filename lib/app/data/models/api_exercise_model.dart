import 'dart:convert';

// Helper function untuk mem-parsing List<ApiExercise> dari JSON
List<ApiExercise> apiExerciseFromJson(String str) => List<ApiExercise>.from(
  json.decode(str).map((x) => ApiExercise.fromJson(x)),
);

class ApiExercise {
  final String name;
  final String muscle;
  final String difficulty;

  ApiExercise({
    required this.name,
    required this.muscle,
    required this.difficulty,
  });

  // Factory constructor untuk membuat objek dari Map (JSON)
  factory ApiExercise.fromJson(Map<String, dynamic> json) => ApiExercise(
    name: json["name"],
    muscle: json["muscle"],
    difficulty: json["difficulty"],
  );
}
