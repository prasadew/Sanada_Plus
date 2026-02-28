import 'package:flutter_riverpod/flutter_riverpod.dart';

// MOCK: In the full app, this would use FirebaseAuth.instance
final authStateProvider = StateProvider<bool>((ref) => false); // false = logged out, true = logged in

final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  Future<void> signInWithPhone(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Usually you would call FirebaseAuth instance verifyPhoneNumber here
  }

  Future<bool> verifyOTP(String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In actual implementation, confirm PhoneAuthCredential here
    
    // For mock purposes, any OTP of length 6 is "valid"
    if (otp.length == 6) {
      _ref.read(authStateProvider.notifier).state = true;
      return true;
    }
    return false;
  }
  
  void signOut() {
    _ref.read(authStateProvider.notifier).state = false;
  }
}
