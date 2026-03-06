import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../services/auth_service.dart';

// ── Service provider ────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth state: true if a Firebase user is signed in ────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Quick boolean check: is the user logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).whenOrNull(data: (u) => u != null) ??
      false;
});

// ── Current user profile from Firestore ────────────────────────
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).streamCurrentUser();
});

// ── Phone verification state ────────────────────────────────────
class PhoneVerificationState {
  final String verificationId;
  final int? resendToken;
  final bool isLoading;
  final String? error;
  final bool codeSent;
  final bool verified;

  const PhoneVerificationState({
    this.verificationId = '',
    this.resendToken,
    this.isLoading = false,
    this.error,
    this.codeSent = false,
    this.verified = false,
  });

  PhoneVerificationState copyWith({
    String? verificationId,
    int? resendToken,
    bool? isLoading,
    String? error,
    bool? codeSent,
    bool? verified,
  }) {
    return PhoneVerificationState(
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      codeSent: codeSent ?? this.codeSent,
      verified: verified ?? this.verified,
    );
  }
}

final phoneVerificationProvider = StateNotifierProvider<
    PhoneVerificationNotifier, PhoneVerificationState>((ref) {
  return PhoneVerificationNotifier(ref.watch(authServiceProvider));
});

class PhoneVerificationNotifier extends StateNotifier<PhoneVerificationState> {
  final AuthService _authService;

  PhoneVerificationNotifier(this._authService)
      : super(const PhoneVerificationState());

  Future<void> sendOTP(String phoneNumber) async {
    debugPrint('🔵 [PROVIDER] sendOTP called with: $phoneNumber');
    state = state.copyWith(isLoading: true, error: null, codeSent: false);

    // Use a Completer so we can await until a callback fires
    final completer = Completer<void>();

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      resendToken: state.resendToken,
      onCodeSent: (verificationId, resendToken) {
        debugPrint('🔵 [PROVIDER] onCodeSent received');
        state = state.copyWith(
          verificationId: verificationId,
          resendToken: resendToken,
          isLoading: false,
          codeSent: true,
        );
        if (!completer.isCompleted) completer.complete();
      },
      onAutoVerify: (credential) async {
        debugPrint('🔵 [PROVIDER] onAutoVerify received');
        try {
          await _authService.signInWithCredential(credential);
          state = state.copyWith(isLoading: false, verified: true);
        } catch (e) {
          debugPrint('🔵 [PROVIDER] onAutoVerify error: $e');
          state = state.copyWith(isLoading: false, error: e.toString());
        }
        if (!completer.isCompleted) completer.complete();
      },
      onError: (error) {
        debugPrint('🔵 [PROVIDER] onError: $error');
        state = state.copyWith(isLoading: false, error: error);
        if (!completer.isCompleted) completer.complete();
      },
    );

    debugPrint('🔵 [PROVIDER] Waiting for callback...');
    // Wait until one of the callbacks fires
    return completer.future;
  }

  Future<bool> verifyOTP(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithOTP(
        verificationId: state.verificationId,
        otp: otp,
      );
      state = state.copyWith(isLoading: false, verified: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Invalid OTP',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const PhoneVerificationState();
  }
}

// ── Auth controller (profile creation, sign out etc.) ──────────
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

class AuthController {
  final AuthService _authService;
  AuthController(this._authService);

  Future<void> saveUserProfile({
    required String name,
    required String about,
    required String phoneNumber,
    required String countryCode,
    File? profileImage,
  }) async {
    String profilePicUrl = '';
    if (profileImage != null) {
      profilePicUrl = await _authService.uploadProfilePic(profileImage);
    }

    final user = UserModel(
      uid: _authService.currentUser!.uid,
      name: name,
      about: about.isEmpty ? 'Hey there! I am using Sanvadha+' : about,
      profilePic: profilePicUrl,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _authService.saveUserData(user);
  }

  Future<bool> userProfileExists() async {
    return await _authService.userProfileExists();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
