import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_models;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<bool> isUserLoggedIn() async =>
      _prefs.getBool('isAuthenticated') ?? false;

  Future<String?> getUserId() async => _prefs.getString('userId');

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateOtp() => (1000 + Random().nextInt(9000)).toString();

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required Function(String, String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // Normalisation de l'email
      final normalizedEmail = email.trim().toLowerCase();

      final doc =
          await _firestore.collection('utilisateur').doc(normalizedEmail).get();

      if (!doc.exists) {
        onError('Aucun utilisateur trouvé avec cet email');
        return;
      }

      final data = doc.data()!;
      final storedPassword = data['password'] as String?;

      if (storedPassword == null || storedPassword.isEmpty) {
        onError('Compte invalide - mot de passe non défini');
        return;
      }

      if (data['password'] == _hashPassword(password)) {
        String otp = _generateOtp();
        await _prefs.setString('tempOtp', otp);
        await _prefs.setString('tempUserId', normalizedEmail);
        onCodeSent('email-$normalizedEmail', otp);
      } else {
        onError('Mot de passe incorrect');
      }
    } catch (e) {
      onError('Erreur lors de la connexion : ${e.toString()}');
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required String password,
    required Function(String, String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // Normalisation du numéro de téléphone avec le préfixe +228
      final normalizedPhone = phoneNumber.startsWith('+228')
          ? phoneNumber.trim()
          : '+228${phoneNumber.trim()}';

      final doc =
          await _firestore.collection('utilisateur').doc(normalizedPhone).get();

      if (!doc.exists) {
        onError('Aucun utilisateur trouvé avec ce numéro');
        return;
      }

      final data = doc.data()!;
      final storedPassword = data['password'] as String?;

      if (storedPassword == null || storedPassword.isEmpty) {
        onError('Compte invalide - mot de passe non défini');
        return;
      }

      if (data['password'] == _hashPassword(password)) {
        String otp = _generateOtp();
        await _prefs.setString('tempOtp', otp);
        await _prefs.setString('tempUserId', normalizedPhone);
        onCodeSent('phone-$normalizedPhone', otp);
      } else {
        onError('Mot de passe incorrect');
      }
    } catch (e) {
      onError('Erreur lors de la connexion : ${e.toString()}');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Erreur de connexion Google: $e');
    }
  }

  Future<void> createUser({
    String? email,
    String? phoneNumber,
    required String password,
    String? name,
    required Function(String, String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      String userId = email ?? phoneNumber!;
      final normalizedUserId = email != null
          ? email.trim().toLowerCase()
          : (phoneNumber!.startsWith('+228')
              ? phoneNumber.trim()
              : '+228${phoneNumber.trim()}');

      final doc = await _firestore
          .collection('utilisateur')
          .doc(normalizedUserId)
          .get();
      if (doc.exists) {
        onError('Utilisateur déjà existant');
        return;
      }

      await _firestore.collection('utilisateur').doc(normalizedUserId).set({
        'email': email ?? '',
        'telephone': phoneNumber ?? '',
        'nom_prenom': name ?? '',
        'adresse': '',
        'password': _hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      String otp = _generateOtp();
      await _prefs.setString('tempOtp', otp);
      await _prefs.setString('tempUserId', normalizedUserId);
      onCodeSent('register-$normalizedUserId', otp);
    } catch (e) {
      onError('Erreur lors de la création : $e');
    }
  }

  Future<bool> createUserWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final doc =
          await _firestore.collection('utilisateur').doc(user.email).get();
      if (!doc.exists) {
        await _firestore.collection('utilisateur').doc(user.email).set({
          'email': user.email,
          'telephone': '',
          'nom_prenom': user.displayName ?? '',
          'password': '',
          'adresse': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _prefs.setBool('isAuthenticated', true);
      await _prefs.setString('userId', user.email!);
      return true;
    } catch (e) {
      throw 'Erreur lors de l\'inscription Google : $e';
    }
  }

  Future<bool> verifyOtp(String verificationId, String code) async {
    try {
      String? storedOtp = _prefs.getString('tempOtp');
      String? tempUserId = _prefs.getString('tempUserId');

      print('Verification ID: $verificationId');
      print('Stored OTP: "$storedOtp"');
      print('Entered OTP: "$code"');
      print('Temp User ID: $tempUserId');

      if (storedOtp == null || tempUserId == null) {
        print('Échec : OTP ou UserID temporaire non trouvé');
        return false;
      }

      if (storedOtp == code.trim()) {
        final doc =
            await _firestore.collection('utilisateur').doc(tempUserId).get();
        if (!doc.exists) {
          print('Utilisateur non trouvé pour tempUserId: $tempUserId');
          return false;
        }

        await _prefs.setBool('isAuthenticated', true);
        await _prefs.setString('userId', tempUserId);
        await _prefs.remove('tempOtp');
        await _prefs.remove('tempUserId');
        print('Vérification OTP réussie');
        return true;
      }

      print('Échec : OTP incorrect');
      return false;
    } catch (e) {
      print('Erreur lors de la vérification OTP : $e');
      throw 'Erreur lors de la vérification OTP : $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<app_models.User?> getCurrentUser(String userId) async {
    try {
      final doc = await _firestore.collection('utilisateur').doc(userId).get();
      if (doc.exists) {
        return app_models.User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<bool> updateUser({
    required String userId,
    required String nom,
    required String email,
    required String telephone,
    required String adresse,
    String? oldPassword,
    String? password,
  }) async {
    try {
      final userRef = _firestore.collection('utilisateur').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data()!;

      // Vérifier l'ancien mot de passe si un nouveau est fourni
      if (password != null && password.isNotEmpty) {
        if (_hashPassword(oldPassword ?? '') != userData['password']) {
          return false;
        }
      }

      await userRef.update({
        'nom_prenom': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        if (password != null && password.isNotEmpty)
          'password': _hashPassword(password),
      });

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur: $e');
      return false;
    }
  }
}
