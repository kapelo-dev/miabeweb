import 'package:flutter/material.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';
import 'package:miabe_pharmacie/utils/commande_status_utils.dart';

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
    return CommandeStatusUtils.getStatusColor(status);
  }

  String getStatusLabel() {
    return CommandeStatusUtils.formatStatus(status);
  }

  bool get canCancel => CommandeStatusUtils.canCancel(status);
}
