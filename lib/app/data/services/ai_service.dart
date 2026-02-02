import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', // Versi cepat dan gratis
      apiKey: 'AIzaSyBWeSAzh1Mz9XG_D250PLaHAmeOXVKHzEg',
    );
  }

  // Fungsi untuk mengirim pesan ke AI
  Future<String> getAiResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Maaf, saya tidak bisa memproses permintaan itu.";
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }
}
