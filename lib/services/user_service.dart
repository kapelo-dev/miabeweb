import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserInfo({
    required String nom,
    required String email,
    String? telephone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Aucun utilisateur connecté');

      await _firestore.collection('utilisateur').doc(user.uid).set({
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'dateCreation': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des informations: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Aucun utilisateur connecté');

      final docSnapshot =
          await _firestore.collection('utilisateur').doc(user.uid).get();
      return docSnapshot.data();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des informations: $e');
    }
  }
}
