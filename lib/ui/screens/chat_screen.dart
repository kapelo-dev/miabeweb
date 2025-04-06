import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../services/chatbot_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Initialiser directement sans late
  final ChatViewModel viewModel = Get.put(ChatViewModel(ChatbotService()));

  @override
  void initState() {
    super.initState();
    // Plus besoin d'initialiser viewModel ici
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assistant Virtuel MiabéPharmacie',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6AAB64),
      ),
      body: _buildChatInterface(),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Liste des messages
        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: viewModel.messages.length,
            reverse: false,
            itemBuilder: (context, index) {
              final message = viewModel.messages[index];
              return _buildMessageItem(message);
            },
          )),
        ),
        
        // Indicateur de chargement
        Obx(() => viewModel.isLoading.value
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          : const SizedBox.shrink()
        ),
        
        // Zone de saisie et bouton d'envoi
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMessageItem(Message message) {
    return Align(
      alignment: message.isUser 
        ? Alignment.centerRight
        : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser 
            ? const Color(0xFF6AAB64) 
            : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser 
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Champ de texte
          Expanded(
            child: TextField(
              controller: viewModel.messageController,
              decoration: InputDecoration(
                hintText: 'Posez votre question ici...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, 
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => viewModel.sendMessage(),
            ),
          ),
          
          // Bouton d'envoi
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6AAB64),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: viewModel.sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
