import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<bool> isUserLoggedIn() async => _prefs.getBool('isAuthenticated') ?? false;

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
      final doc = await _firestore.collection('utilisateur').doc(email).get();
      if (!doc.exists) {
        onError('Utilisateur non trouvé dans la base de données');
        return;
      }

      final data = doc.data()!;
      if (data['password'] == _hashPassword(password)) {
        String otp = _generateOtp();
        await _prefs.setString('tempOtp', otp);
        await _prefs.setString('tempUserId', email);
        onCodeSent('email-$email', otp);
      } else {
        onError('Mot de passe incorrect');
      }
    } catch (e) {
      onError('Erreur lors de la connexion : $e');
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required String password,
    required Function(String, String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();
      if (!doc.exists) {
        onError('Utilisateur non trouvé dans la base de données');
        return;
      }

      final data = doc.data()!;
      if (data['password'] == _hashPassword(password)) {
        String otp = _generateOtp();
        await _prefs.setString('tempOtp', otp);
        await _prefs.setString('tempUserId', phoneNumber);
        onCodeSent('phone-$phoneNumber', otp);
      } else {
        onError('Mot de passe incorrect');
      }
    } catch (e) {
      onError('Erreur lors de la connexion : $e');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final doc = await _firestore.collection('utilisateur').doc(user.email).get();
      if (!doc.exists) {
        throw 'Utilisateur non trouvé dans la base de données';
      }

      await _prefs.setBool('isAuthenticated', true);
      await _prefs.setString('userId', user.email!);
      return true;
    } catch (e) {
      throw 'Erreur lors de la connexion Google : $e';
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
      final doc = await _firestore.collection('utilisateur').doc(userId).get();
      if (doc.exists) {
        onError('Utilisateur déjà existant');
        return;
      }

      await _firestore.collection('utilisateur').doc(userId).set({
        'email': email ?? '',
        'phoneNumber': phoneNumber ?? '',
        'name': name ?? '',
        'password': _hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      String otp = _generateOtp();
      await _prefs.setString('tempOtp', otp);
      await _prefs.setString('tempUserId', userId);
      onCodeSent('register-$userId', otp);
    } catch (e) {
      onError('Erreur lors de la création : $e');
    }
  }

  Future<bool> createUserWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final doc = await _firestore.collection('users').doc(user.email).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.email).set({
          'email': user.email,
          'phoneNumber': '',
          'name': user.displayName ?? '',
          'password': '',
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
      if (storedOtp == code && tempUserId != null) {
        final doc = await _firestore.collection('users').doc(tempUserId).get();
        if (!doc.exists) {
          return false; // L'utilisateur n'existe pas dans Firestore
        }
        await _prefs.setBool('isAuthenticated', true);
        await _prefs.setString('userId', tempUserId);
        await _prefs.remove('tempOtp');
        await _prefs.remove('tempUserId');
        return true;
      }
      return false;
    } catch (e) {
      throw 'Erreur lors de la vérification OTP : $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _prefs.clear();
  }
}