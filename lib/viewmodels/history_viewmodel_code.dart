import 'package:flutter/material.dart';
import '../models/commande_model.dart';
import '../services/commande_service.dart';

class HistoryViewModelCode extends ChangeNotifier {
  final CommandeService _commandeService = CommandeService();
  List<CommandeModel> _commandes = [];
  bool _isLoading = false;
  String _error = '';

  List<CommandeModel> get commandes => _commandes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadCommandes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _commandes = await _commandeService.getCommandesForUser('sessou');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des commandes';
      print('Erreur de chargement des commandes: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
