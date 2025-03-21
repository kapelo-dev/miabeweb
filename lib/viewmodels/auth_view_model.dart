import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthViewModel extends GetxController {
  final AuthService _authService;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  AuthViewModel(this._authService);

  Future<bool> checkAuthStatus() async => await _authService.isUserLoggedIn();

  Future<void> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    await _authService.signInWithEmail(
      email: email,
      password: password,
      onCodeSent: (verificationId, otpCode) {
        Get.snackbar('Code OTP', 'Votre code est : $otpCode', duration: const Duration(seconds: 10));
        Get.toNamed('/otp', arguments: verificationId);
      },
      onError: (message) => error.value = message,
    );
    isLoading.value = false;
  }

  Future<void> verifyPhoneNumber(String phoneNumber, String password) async {
    isLoading.value = true;
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      password: password,
      onCodeSent: (verificationId, otpCode) {
        Get.snackbar('Code OTP', 'Votre code est : $otpCode', duration: const Duration(seconds: 10));
        Get.toNamed('/otp', arguments: verificationId);
      },
      onError: (message) => error.value = message,
    );
    isLoading.value = false;
  }

  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    try {
      bool success = await _authService.signInWithGoogle();
      if (success) Get.offNamed('/home');
      return success;
    } catch (e) {
      error.value = e.toString();
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
    isLoading.value = true;
    await _authService.createUser(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      name: name,
      onCodeSent: (verificationId, otpCode) {
        Get.snackbar('Code OTP', 'Votre code est : $otpCode', duration: const Duration(seconds: 10));
        Get.toNamed('/otp', arguments: verificationId);
      },
      onError: (message) => error.value = message,
    );
    isLoading.value = false;
  }

  Future<bool> createUserWithGoogle() async {
    isLoading.value = true;
    try {
      bool success = await _authService.createUserWithGoogle();
      if (success) Get.offNamed('/home');
      return success;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOTP(String verificationId, String code) async {
    isLoading.value = true;
    try {
      bool success = await _authService.verifyOtp(verificationId, code);
      if (success) Get.offAllNamed('/home');
      return success;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed('/screen_option');
  }
}
