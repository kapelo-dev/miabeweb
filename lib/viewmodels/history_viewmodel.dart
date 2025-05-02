import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_models;
import '../services/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/firebase_constants.dart';

class HistoryViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<app_models.Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<app_models.Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setOrders(List<app_models.Order> newOrders) {
    _orders = newOrders;
    notifyListeners();
  }

  Future<String> getConnectedUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

      if (!isAuthenticated || userId == null || userId.isEmpty) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Vérifier dans Firestore avec l'ID utilisateur (email ou téléphone)
      final userDoc =
          await _firestore.collection('utilisateur').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null &&
            userData['nom_prenom'] != null &&
            userData['nom_prenom'].isNotEmpty) {
          return userData['nom_prenom'];
        } else if (userData != null &&
            userData['telephone'] != null &&
            userData['telephone'].isNotEmpty) {
          return userData['telephone'];
        } else if (userData != null &&
            userData['email'] != null &&
            userData['email'].isNotEmpty) {
          return userData['email'];
        }
      }

      // Si l'utilisateur existe dans les préférences mais pas dans Firestore
      final userName = prefs.getString('nom_prenom');
      if (userName != null && userName.isNotEmpty) {
        return userName;
      }

      // Si aucune information n'est trouvée, retourner l'ID utilisateur
      return userId;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération du nom d\'utilisateur: $e');
    }
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userName = await getConnectedUserName();
      if (userName.isEmpty) {
        throw Exception('Nom d\'utilisateur non trouvé');
      }

      print('Chargement des commandes pour: $userName');
      _orders = await _orderService.getOrders(userName);

      if (_orders.isEmpty) {
        print('Aucune commande trouvée pour: $userName');
      } else {
        print('${_orders.length} commandes trouvées pour: $userName');
      }

      _error = null;
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
      _error = e.toString();
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyUserInFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('Aucun utilisateur connecté.');
        return;
      }

      print('Vérification des données utilisateur pour UID : ${user.uid}');

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        print('Données utilisateur trouvées : ${userDoc.data()}');
      } else {
        print('Aucune donnée utilisateur trouvée pour UID : ${user.uid}');
      }
    } catch (e) {
      print('Erreur lors de la vérification des données utilisateur : $e');
    }
  }
}
