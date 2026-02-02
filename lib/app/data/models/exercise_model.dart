class Exercise {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> bodyParts;
  final List<String> targetMuscles;
  final List<String> equipments;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bodyParts,
    required this.targetMuscles,
    required this.equipments,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, {String? docId}) {
    return Exercise(
      id: docId ?? json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      // Menangani data list dari JSON
      bodyParts: List<String>.from(json['bodyParts'] ?? []),
      targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
      equipments: List<String>.from(json['equipments'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}
