class FirebaseConstants {
  // Collections
  static const String usersCollection = 'utilisateur';
  static const String pharmaciesCollection = 'pharmacies';
  static const String ordersCollection = 'commandes';
  static const String productsCollection = 'produits';

  // Champs utilisateur
  static const String userIdField = 'userId';
  static const String userNameField = 'nom';
  static const String userEmailField = 'email';
  static const String userPhoneField = 'telephone';
  static const String userAddressField = 'adresse';

  // Champs commande
  static const String orderCodeField = 'code_commande';
  static const String orderDateField = 'date_commande';
  static const String orderStatusField = 'status_commande';
  static const String orderTotalField = 'montant_total';
  static const String orderUserField = 'utilisateur';
  static const String orderProductsField = 'produits';

  // Champs produit
  static const String productNameField = 'nom';
  static const String productPriceField = 'prix_unitaire';
  static const String productQuantityField = 'quantite';
  static const String productDescriptionField = 'description';
  static const String productPrescriptionField = 'sur_ordonnance';

  // Champs pharmacie
  static const String pharmacyNameField = 'nom';
  static const String pharmacyAddressField = 'emplacement';
  static const String pharmacyOpeningField = 'ouverture';
  static const String pharmacyClosingField = 'fermeture';
  static const String pharmacyPhoneField = 'telephone1';
}
