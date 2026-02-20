import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/controllers/ai_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Catatan: Jika Anda sudah menerapkan Dependency Injection, Anda bisa
// mengganti StatelessWidget ini menjadi GetView<AiController> dan
// menghapus baris "final controller = Get.put(AiController());"
class AiPage extends StatelessWidget {
  final controller = Get.put(AiController());
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2A3A), // Biru tua
              Color(0xFF121212), // Hitam
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "AI Coach",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() {
                  // 1. TAMPILAN EMPTY STATE (KOSONG) ALA GEMINI
                  if (controller.messages.isEmpty &&
                      !controller.isLoading.value) {
                    return _buildEmptyState();
                  }

                  // 2. TAMPILAN LIST CHAT & BUBBLE LOADING
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    // Tambah +1 pada itemCount jika AI sedang berpikir
                    itemCount:
                        controller.messages.length +
                        (controller.isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Jika index mencapai akhir pesan dan statusnya loading, tampilkan animasi
                      if (index == controller.messages.length &&
                          controller.isLoading.value) {
                        return _buildTypingIndicatorBubble();
                      }

                      final msg = controller.messages[index];
                      bool isUser = msg['role'] == 'user';
                      return _buildChatBubble(msg['message']!, isUser);
                    },
                  );
                }),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET EMPTY STATE (SAPAAN AWAL) ---
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon bercahaya
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4AD0B2), Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(
                Icons.auto_awesome,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Hello, I'm your AI Coach",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "How can I help you crush your goals today?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUBBLE CHAT ---
  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser
              ? Get.theme.colorScheme.primary
              : const Color(0xFF232D37).withOpacity(0.7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- WIDGET INDIKATOR TYPING (LOADING) ---
  Widget _buildTypingIndicatorBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF232D37).withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(20),
          ),
        ),
        // Menggunakan LinearProgressIndicator mini sebagai efek berpikir
        child: const SizedBox(
          width: 50,
          height: 3,
          child: LinearProgressIndicator(
            color: Color(0xFF4AD0B2),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  // --- WIDGET INPUT AREA ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 110),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tanya AI Coach...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Get.theme.colorScheme.primary,
            radius: 25,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black, size: 20),
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  controller.sendMessage(_textController.text);
                  _textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
