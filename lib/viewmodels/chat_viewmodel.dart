import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/chatbot_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/widgets/pharmacy_selector.dart';
import '../ui/widgets/order_form.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Widget? widget;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.widget,
  });
}

class ChatViewModel extends GetxController {
  final ChatbotService _chatbotService;
  final TextEditingController messageController = TextEditingController();
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOrderMode = false.obs;
  Map<String, dynamic>? selectedPharmacy;

  ChatViewModel(this._chatbotService) {
    messages.add(
      Message(
        text: "Salut ! Je suis votre assistant virtuel pour les pharmacies au Togo. Comment puis-je vous aider aujourd'hui ?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  bool _detectOrderIntent(String message) {
    final orderKeywords = [
      'commander',
      'acheter',
      'passer une commande',
      'faire une commande',
      'je veux commander',
      'je souhaite commander',
      'je voudrais commander',
      'ajouter au panier',
    ];

    message = message.toLowerCase();
    // Vérifier si le message contient une intention claire de commande
    bool hasOrderIntent = orderKeywords.any((keyword) => message.contains(keyword.toLowerCase()));
    
    // Éviter les faux positifs pour les questions d'information
    final informationKeywords = [
      'où',
      'où est',
      'où sont',
      'quelles sont',
      'quelle est',
      'proche',
      'proches',
      'proximité',
      'près',
      'près de',
      'autour',
      'autour de',
      'disponible',
      'disponibles',
      'horaires',
      'ouvert',
      'ouverte',
      'fermé',
      'fermée',
      'information',
      'renseignement',
      'cherche',
      'trouve',
      'trouver',
      'localiser',
      'connaître',
      'savoir',
    ];

    bool isInformationRequest = informationKeywords.any((keyword) => message.contains(keyword.toLowerCase()));

    // Si c'est clairement une demande d'information, ne pas considérer comme une intention de commande
    if (isInformationRequest && !hasOrderIntent) {
      return false;
    }

    // Pour les messages contenant "médicament" ou "produit", vérifier le contexte
    if (message.contains('médicament') || message.contains('produit')) {
      // Ne considérer comme intention de commande que si accompagné d'un mot clé de commande
      return hasOrderIntent;
    }

    return hasOrderIntent;
  }

  void _handleOrderIntent() {
    messages.add(
      Message(
        text: "Souhaitez-vous passer une commande de médicaments ? Je peux vous aider à commander auprès d'une pharmacie. Répondez par 'oui' pour commencer la commande ou 'non' pour continuer la discussion.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    isOrderMode.value = true;
  }

  void _startOrderProcess() {
    messages.add(
      Message(
        text: "D'accord, commençons la commande. Veuillez d'abord sélectionner une pharmacie :",
        isUser: false,
        timestamp: DateTime.now(),
        widget: PharmacySelector(
          onPharmacySelected: (pharmacy) {
            selectedPharmacy = pharmacy;
            messages.add(
              Message(
                text: "Vous avez sélectionné la pharmacie ${pharmacy['nom']}. Maintenant, choisissez vos produits :",
                isUser: false,
                timestamp: DateTime.now(),
                widget: OrderForm(
                  selectedPharmacy: pharmacy,
                  onOrderSubmit: _submitOrder,
                ),
              ),
            );
            messages.refresh();
            Future.delayed(const Duration(milliseconds: 100), () {
              Get.find<ScrollController>().animateTo(
                Get.find<ScrollController>().position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          },
        ),
      ),
    );
    messages.refresh();
  }

  Future<void> _submitOrder(List<Map<String, dynamic>> products) async {
    if (selectedPharmacy == null || products.isEmpty) return;

    isLoading.value = true;
    try {
      final prefs = await Get.find<SharedPreferences>();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await http.post(
        Uri.parse('https://miabe-pharmacie-api.onrender.com/api/pharmacies/commandes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'produits': products.map((p) => {
            'nom': p['nom'],
            'quantite': p['quantite'],
          }).toList(),
          'status_commande': 'en_cours',
          'utilisateur': userId,
          'pharmacieId': selectedPharmacy!['id']
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        messages.add(
          Message(
            text: "Votre commande a été enregistrée avec succès ! Vous pouvez la suivre dans la section 'Mes commandes'.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.find<ScrollController>().animateTo(
            Get.find<ScrollController>().position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        throw Exception('Erreur lors de la commande: ${response.body}');
      }
    } catch (e) {
      messages.add(
        Message(
          text: "Désolé, une erreur s'est produite lors de la commande : $e",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      isLoading.value = false;
      isOrderMode.value = false;
      selectedPharmacy = null;
    }
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();
    messages.add(
      Message(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    
    messageController.clear();
    isLoading.value = true;
    
    try {
      if (isOrderMode.value) {
        if (userMessage.toLowerCase() == 'oui') {
          _startOrderProcess();
        } else if (userMessage.toLowerCase() == 'non') {
          messages.add(
            Message(
              text: "D'accord, je reste à votre disposition pour vous renseigner. Comment puis-je vous aider ?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          isOrderMode.value = false;
        } else {
          messages.add(
            Message(
              text: "Je n'ai pas bien compris votre réponse. Veuillez répondre par 'oui' si vous souhaitez passer une commande, ou 'non' si vous voulez simplement des informations.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      } else {
        if (_detectOrderIntent(userMessage)) {
          _handleOrderIntent();
        } else {
          final contextData = await _chatbotService.prepareContextData(userMessage);
          final botResponse = await _chatbotService.sendMessageToDeepseek(
            userMessage,
            contextData,
          );
          
          messages.add(
            Message(
              text: botResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      messages.add(
        Message(
          text: "Je suis désolé, j'ai rencontré une erreur. Pouvez-vous reformuler votre demande ?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      print("Erreur lors de l'envoi du message: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}