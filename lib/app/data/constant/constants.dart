class ApiConstants {
  static const String searchUrl =
      'https://exercisedb-api1.p.rapidapi.com/api/v1/exercises/search';
  static const String baseUrl =
      'https://exercisedb-api1.p.rapidapi.com/api/v1/exercises';
  static const String imageUrl = 'https://exercisedb.p.rapidapi.com/image?';
  static const String apiKey =
      '8b491eee0dmsh374d931666ed2c1p17a5fbjsne8a27e198bf7'; // Ganti dengan key Anda
  static const String apiHost = 'exercisedb-api1.p.rapidapi.com';

  static const Map<String, String> publicHeaders = {
    'Content-Type': 'application/json',
  };
  static const Map<String, String> headers = {
    'X-RapidAPI-Key': apiKey,
    'X-RapidAPI-Host': apiHost,
  };
}
