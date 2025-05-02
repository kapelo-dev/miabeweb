import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_models;

class EditProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  app_models.User? _user;
  bool _isLoading = false;
  String? _error;

  EditProfileViewModel(this._authService);

  app_models.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser(userId);
      if (_user == null) {
        _error = 'Utilisateur non trouvé';
      }
    } catch (e) {
      _error = 'Erreur lors du chargement de l\'utilisateur: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> userData = {
        'nom_prenom': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
      };

      if (password != null && password.isNotEmpty) {
        userData['password'] = password;
      }

      bool success = await _authService.updateUser(
        userId: userId,
        nom: nom,
        email: email,
        telephone: telephone,
        adresse: adresse,
        oldPassword: oldPassword,
        password: password,
      );

      if (success) {
        _user = app_models.User(
          id: userId,
          nom: nom,
          email: email,
          telephone: telephone,
          adresse: adresse,
          password: password ?? _user?.password ?? '',
        );
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
