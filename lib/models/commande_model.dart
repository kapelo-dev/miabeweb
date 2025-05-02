import 'package:flutter/material.dart';

class CommandeItem {
  final String nom;
  final String description;
  final int quantite;
  final double prix;

  CommandeItem({
    required this.nom,
    this.description = '',
    required this.quantite,
    required this.prix,
  });
}

class CommandeModel {
  final String code_commande;
  final String date;
  final String pharmacieNom;
  final String pharmacieAdresse;
  final List<CommandeItem> items;
  final String total;
  final String? heureRetrait;
  final String status;

  CommandeModel({
    required this.code_commande,
    required this.date,
    required this.pharmacieNom,
    required this.pharmacieAdresse,
    required this.items,
    required this.total,
    this.heureRetrait,
    required this.status,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'en attente':
        return Colors.orange;
      case 'confirmée':
        return Colors.green;
      case 'annulée':
        return Colors.red;
      case 'terminée':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'en attente':
        return 'En attente';
      case 'confirmée':
        return 'Confirmée';
      case 'annulée':
        return 'Annulée';
      case 'terminée':
        return 'Terminée';
      default:
        return 'Inconnu';
    }
  }
}
