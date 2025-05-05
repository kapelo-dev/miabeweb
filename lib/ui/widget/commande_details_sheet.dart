import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:miabe_pharmacie/models/commande_model.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';
import 'package:miabe_pharmacie/utils/commande_status_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:get/get.dart';

class CommandeDetailsSheet extends StatefulWidget {
  final CommandeModel commande;
  final Function(String) onCancelOrder;

  const CommandeDetailsSheet({
    Key? key,
    required this.commande,
    required this.onCancelOrder,
  }) : super(key: key);

  @override
  State<CommandeDetailsSheet> createState() => _CommandeDetailsSheetState();
}

class _CommandeDetailsSheetState extends State<CommandeDetailsSheet> {
  final screenshotController = ScreenshotController();
  String? qrCodeUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    try {
      setState(() => isLoading = true);
      final encodedData = Uri.encodeComponent(widget.commande.code_commande);
      final url = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$encodedData';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          qrCodeUrl = url;
          isLoading = false;
        });
      } else {
        throw Exception('Échec de génération du QR Code');
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Erreur',
        'Impossible de générer le QR Code',
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _saveQrCode() async {
    if (qrCodeUrl == null) return;
    
    try {
      final response = await http.get(Uri.parse(qrCodeUrl!));
      if (response.statusCode == 200) {
        final result = await ImageGallerySaver.saveImage(
          response.bodyBytes,
          name: 'commande_${widget.commande.code_commande}_qr',
          quality: 100,
        );
        
        if (result['isSuccess']) {
          Get.snackbar(
            'Succès',
            'QR Code sauvegardé dans la galerie',
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else {
          throw Exception('Échec de la sauvegarde');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le QR Code',
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.commande.getStatusColor();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commande #${widget.commande.code_commande}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(widget.commande.date)),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CommandeStatusUtils.getStatusIcon(widget.commande.status),
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CommandeStatusUtils.formatStatus(widget.commande.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: AppTheme.fontSizeXSmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Informations de la pharmacie
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_pharmacy_outlined,
                            size: 20,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.commande.pharmacieNom,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeNormal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.commande.pharmacieAdresse.trim().isEmpty 
                                ? 'Emplacement non disponible'
                                : widget.commande.pharmacieAdresse,
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeSmall,
                                color: widget.commande.pharmacieAdresse.trim().isEmpty 
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // QR Code
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            )
                          : qrCodeUrl != null
                            ? Image.network(
                                qrCodeUrl!,
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              )
                            : const Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red,
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: qrCodeUrl != null ? _saveQrCode : null,
                        icon: const Icon(Icons.download),
                        label: const Text('Télécharger le QR Code'),
                        style: TextButton.styleFrom(
                          foregroundColor: qrCodeUrl != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Produits commandés',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeNormal,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.commande.items.map((produit) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.medication_outlined,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produit.nom,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeNormal,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qté: ${produit.quantite} x ${produit.prix} FCFA',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(produit.quantite * produit.prix)} FCFA',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeNormal,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.commande.total,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.commande.status.toLowerCase() == 'en attente')
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => widget.onCancelOrder(widget.commande.code_commande),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Annuler cette commande'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Implémenter la fonction pour contacter la pharmacie
                  },
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('Contacter la pharmacie'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 