import 'package:http/http.dart' as http;
import 'package:flutter_application_2/app/data/models/api_exercise_model.dart';

class ExerciseApiService {
  static const String _baseUrl = 'https://api.api-ninjas.com/v1/exercises';

  // GANTI DENGAN API KEY ANDA YANG SEBENARNYA
  static const String _apiKey = 'WXHNixkWnzfwDt788KwmSQ==TiyqAmEbtpAYlIYJ';

  Future<List<ApiExercise>> searchExercisesByName(String nameQuery) async {
    // Jika query kosong, kembalikan list kosong
    if (nameQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$_baseUrl?name=$nameQuery');

    try {
      final response = await http.get(uri, headers: {'X-Api-Key': _apiKey});

      if (response.statusCode == 200) {
        // Jika sukses, parse JSON dan kembalikan list
        return apiExerciseFromJson(response.body);
      } else {
        // Jika gagal, lempar exception
        throw Exception(
          'Failed to load exercises (Status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }
}
