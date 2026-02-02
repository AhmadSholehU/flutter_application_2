import 'package:flutter/material.dart';

class ExerciseImage extends StatelessWidget {
  final String imageUrl; // Berubah dari exerciseId menjadi imageUrl
  final double size;

  const ExerciseImage({Key? key, required this.imageUrl, this.size = 60})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl, // Langsung gunakan URL dari database/API
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Tidak perlu headers lagi untuk URL CDN langsung
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  color: Colors.white10,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: size,
                height: size,
                color: Colors.white10,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          : Container(
              width: size,
              height: size,
              color: Colors.white10,
              child: const Icon(Icons.fitness_center, color: Colors.grey),
            ),
    );
  }
}
