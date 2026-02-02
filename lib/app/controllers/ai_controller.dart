import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/data/services/ai_service.dart';
import 'package:get/get.dart';

class AiController extends GetxController {
  final AiService _aiService = AiService();
  final HomeController _homeController = Get.find<HomeController>();

  var messages = <Map<String, String>>[].obs;
  var isLoading = false.obs;

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    // 1. Tambahkan pesan user ke UI
    messages.add({"role": "user", "message": text});
    isLoading.value = true;

    // 2. Berikan konteks data latihan user agar AI lebih pintar (Personalized)
    String contextPrompt = _generateContextPrompt(text);

    // 3. Ambil respon dari AI
    String response = await _aiService.getAiResponse(contextPrompt);

    messages.add({"role": "ai", "message": response});
    isLoading.value = false;
  }

  // Teknik Prompt Engineering: Memberi tahu AI tentang data user saat ini
  String _generateContextPrompt(String userPrompt) {
    final totalVol = _homeController.totalVolume;
    return """
    Kamu adalah pelatih fitness AI profesional. 
    Data user saat ini: Total Volume hari ini adalah $totalVol kg.
    Pertanyaan user: $userPrompt
    Jawablah dengan singkat, motivatif, dan informatif.
    """;
  }
}
