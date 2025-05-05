import 'package:flutter/material.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';

class CommandeStatusUtils {
  static String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
      case 'en attente':
      case 'en_attente':
      case 'pending':
        return 'En cours';
      case 'validee':
      case 'validée':
      case 'confirmée':
      case 'confirmee':
      case 'confirmed':
        return 'Validée';
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return 'Annulée';
      case 'terminee':
      case 'terminée':
      case 'recuperee':
      case 'récupérée':
      case 'completed':
        return 'Terminée';
      default:
        return 'En cours';
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
      case 'en attente':
      case 'en_attente':
      case 'pending':
        return AppTheme.warningColor;
      case 'validee':
      case 'validée':
      case 'confirmée':
      case 'confirmee':
      case 'confirmed':
        return AppTheme.successColor;
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return AppTheme.errorColor;
      case 'terminee':
      case 'terminée':
      case 'recuperee':
      case 'récupérée':
      case 'completed':
        return AppTheme.primaryColor;
      default:
        return AppTheme.warningColor;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en_cours':
      case 'en attente':
      case 'en_attente':
      case 'pending':
        return Icons.pending_outlined;
      case 'validee':
      case 'validée':
      case 'confirmée':
      case 'confirmee':
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'terminee':
      case 'terminée':
      case 'recuperee':
      case 'récupérée':
      case 'completed':
        return Icons.inventory_2_outlined;
      default:
        return Icons.pending_outlined;
    }
  }

  static bool canCancel(String status) {
    final statusLower = status.toLowerCase();
    return statusLower == 'en_cours' || 
           statusLower == 'en attente' || 
           statusLower == 'en_attente' ||
           statusLower == 'pending';
  }
} 