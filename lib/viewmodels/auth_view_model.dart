import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthViewModel extends GetxController {
  final AuthService _authService;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool _isOtpSent = false.obs;

  AuthViewModel(this._authService);

  Future<bool> checkAuthStatus() async => await _authService.isUserLoggedIn();

  Future<void> signInWithEmail(String email, String password) async {
    if (isLoading.value || _isOtpSent.value) return;
    isLoading.value = true;
    _isOtpSent.value = true;
    error.value = '';
    
    await _authService.signInWithEmail(
      email: email,
      password: password,
      onCodeSent: (verificationId, otpCode) {
        Get.snackbar('Code OTP envoyé', 'Votre code est : $otpCode',
            duration: const Duration(seconds: 10));
        Get.toNamed('/otp', arguments: verificationId);
      },
      onError: (message) {
        error.value = message;
        Get.snackbar('Erreur', message);
        _isOtpSent.value = false;
      },
    );
    isLoading.value = false;
  }

  Future<void> verifyPhoneNumber(String phoneNumber, String password) async {
    if (isLoading.value || _isOtpSent.value) return;
    isLoading.value = true;
    _isOtpSent.value = true;
    error.value = '';
    
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      password: password,
      onCodeSent: (verificationId, otpCode) {
        Get.snackbar('Code OTP envoyé', 'Votre code est : $otpCode',
            duration: const Duration(seconds: 10));
        Get.toNamed('/otp', arguments: verificationId);
      },
      onError: (message) {
        error.value = message;
        Get.snackbar('Erreur', message);
        _isOtpSent.value = false;
      },
    );
    isLoading.value = false;
  }

  Future<bool> signInWithGoogle() async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      bool success = await _authService.signInWithGoogle();
      if (success) Get.offNamed('/home');
      return success;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Erreur', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser({
    String? email,
    String? phoneNumber,
    required String password,
    String? name,
  }) async {
    if (isLoading.value || _isOtpSent.value) return;
    isLoading.value = true;
    _isOtpSent.value = true;
    error.value = '';
    
    await _authService.createUser(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      name: name,
      onCodeSent: (verificationId, otpCode) {
        Get.snackbar('Code OTP envoyé', 'Votre code est : $otpCode',
            duration: const Duration(seconds: 10));
        Get.toNamed('/otp', arguments: verificationId);
      },
      onError: (message) {
        error.value = message;
        Get.snackbar('Erreur', message);
        _isOtpSent.value = false;
      },
    );
    isLoading.value = false;
  }

  Future<bool> createUserWithGoogle() async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      bool success = await _authService.createUserWithGoogle();
      if (success) Get.offNamed('/home');
      return success;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Erreur', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOTP(String verificationId, String code) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    error.value = '';
    
    try {
      bool success = await _authService.verifyOtp(verificationId, code);
      if (success) {
        Get.offAllNamed('/home');
        _isOtpSent.value = false;
      } else {
        Get.snackbar('Erreur', 'Code OTP incorrect');
      }
      return success;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Erreur', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      _isOtpSent.value = false;
      error.value = '';
      isLoading.value = false;
      Get.offAllNamed('/screen_option');
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      throw 'Erreur lors de la déconnexion: $e';
    }
  }
}