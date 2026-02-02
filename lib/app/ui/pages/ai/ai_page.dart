import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/controllers/ai_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AiPage extends StatelessWidget {
  final controller = Get.put(AiController());
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
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
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  bool isUser = msg['role'] == 'user';
                  return _buildChatBubble(msg['message']!, isUser);
                },
              ),
            ),
          ),
          if (controller.isLoading.value)
            const LinearProgressIndicator(color: Colors.blueAccent),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser
              ? Get.theme.colorScheme.primary
              : const Color(0xFF2C2C2E),
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
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
      color: const Color(0xFF1C1C1E),
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
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Get.theme.colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () {
                controller.sendMessage(_textController.text);
                _textController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
