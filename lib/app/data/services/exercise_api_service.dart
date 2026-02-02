import 'package:flutter_application_2/app/data/constant/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExerciseApiService {
  Future<Map<String, dynamic>> getExercises({
    String? after,
    String? query,
  }) async {
    final Map<String, String> queryParams = {
      'limit': '10',
      if (after != null && after.isNotEmpty) 'after': after, // Parameter cursor
      if (query != null && query.isNotEmpty) 'bodyParts': query,
    };

    final uri = Uri.parse(
      ApiConstants.baseUrl,
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: ApiConstants.headers);
    print('request URL :$uri');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Gagal memuat data API');
  }
}
