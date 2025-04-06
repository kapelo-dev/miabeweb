import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/chatbot_service.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatViewModel extends GetxController {
  final ChatbotService _chatbotService;
  final TextEditingController messageController = TextEditingController();
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;

  ChatViewModel(this._chatbotService) {
    // Ajouter un message de bienvenue
    messages.add(
      Message(
        text: "Salut ! Je suis votre assistant virtuel pour les pharmacies au Togo. Comment puis-je vous aider aujourd'hui ?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();
    
    // Ajouter le message de l'utilisateur
    messages.add(
      Message(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    
    // Vider le champ de texte
    messageController.clear();
    
    // Indiquer que la réponse est en cours de chargement
    isLoading.value = true;
    
    try {
      // Préparer les données de contexte
      final contextData = await _chatbotService.prepareContextData(userMessage);
      
      // Envoyer le message à l'API Deepseek
      final botResponse = await _chatbotService.sendMessageToDeepseek(
        userMessage,
        contextData,
      );
      
      // Ajouter la réponse du chatbot
      messages.add(
        Message(
          text: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      // En cas d'erreur, ajouter un message d'erreur
      messages.add(
        Message(
          text: "Désolé, une erreur s'est produite. Veuillez réessayer.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      print("Erreur lors de l'envoi du message: $e");
    } finally {
      // Désactiver l'indicateur de chargement
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}