import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const bool _phoneAuthTestMode =
      bool.fromEnvironment('PHONE_AUTH_TEST_MODE', defaultValue: false);

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Phone Auth ────────────────────────────────────────────────
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    required Function(String verificationId) onAutoRetrievalTimeout,
    required Function(String error) onError,
    int? resendToken,
  }) async {
    try {
      debugPrint('📱 [AUTH] Sending OTP to: $phoneNumber');
      debugPrint('📱 [AUTH] Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      debugPrint('📱 [AUTH] Resend token: $resendToken');

      if (kIsWeb) {
        // On web, use signInWithPhoneNumber with invisible reCAPTCHA
        debugPrint('📱 [AUTH] Using web flow with invisible reCAPTCHA...');
        try {
          // Set app verification to invisible mode for testing
          await _auth.setSettings(appVerificationDisabledForTesting: false);
          
          final confirmationResult = await _auth.signInWithPhoneNumber(
            phoneNumber,
          );
          debugPrint('📨 [AUTH] Code SENT via web flow!');
          _webConfirmationResult = confirmationResult;
          onCodeSent('web-verification', null);
        } on FirebaseAuthException catch (e) {
          debugPrint('❌ [AUTH] Web verification FAILED: ${e.code} - ${e.message}');
          if (e.code == 'too-many-requests') {
            onError('Too many attempts. Please wait a few minutes and try again.');
          } else if (e.code == 'captcha-check-failed') {
            onError('reCAPTCHA verification failed. Please try again.');
          } else {
            onError('Firebase web auth failed: ${e.code} - ${e.message ?? 'Verification failed'}');
          }
        }
      } else {
        if (kDebugMode && _phoneAuthTestMode) {
          await _auth.setSettings(appVerificationDisabledForTesting: true);
          debugPrint(
            '⚠️ [AUTH] PHONE_AUTH_TEST_MODE enabled: app verification disabled for testing.',
          );
        }

        // On mobile, use the standard verifyPhoneNumber flow
        _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          forceResendingToken: resendToken,
          verificationCompleted: (PhoneAuthCredential credential) {
            debugPrint('✅ [AUTH] Auto-verification completed!');
            onAutoVerify(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint('❌ [AUTH] Verification FAILED: ${e.code} - ${e.message}');
            final rawMessage = e.message ?? 'Verification failed';
            final normalized = rawMessage.toLowerCase();
            if (normalized.contains('missing initial state') ||
                normalized.contains('error code:39')) {
              onError(
                'Firebase phone auth failed: ${e.code} - $rawMessage. '
                'This usually means Android app verification is not configured correctly '
                '(SHA fingerprints / Play Integrity / browser session state).',
              );
              return;
            }
            onError('Firebase phone auth failed: ${e.code} - $rawMessage');
          },
          codeSent: (String verificationId, int? resendToken) {
            debugPrint('📨 [AUTH] Code SENT! VerificationId: $verificationId');
            onCodeSent(verificationId, resendToken);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            debugPrint('⏰ [AUTH] Auto-retrieval TIMEOUT');
            onAutoRetrievalTimeout(verificationId);
          },
          timeout: const Duration(seconds: 60),
        );
      }
      debugPrint('📱 [AUTH] verifyPhoneNumber call completed');
    } catch (e) {
      debugPrint('💥 [AUTH] EXCEPTION in verifyPhoneNumber: $e');
      onError(e.toString());
    }
  }

  // Store web confirmation result for OTP verification
  ConfirmationResult? _webConfirmationResult;

  /// Sign in with OTP
  Future<UserCredential> signInWithOTP({
    required String verificationId,
    required String otp,
  }) async {
    if (kIsWeb && _webConfirmationResult != null) {
      // On web, use the confirmation result to verify
      debugPrint('📱 [AUTH] Verifying OTP via web flow...');
      final result = await _webConfirmationResult!.confirm(otp);
      _webConfirmationResult = null;
      return result;
    }
    // On mobile, use standard credential flow
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Sign in with a credential (used for auto-verification)
  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // ── User Profile ──────────────────────────────────────────────
  /// Upload profile picture to Firebase Storage
  Future<String> uploadProfilePic(File imageFile) async {
    final ref = _storage
        .ref()
        .child(FirebaseConstants.profilePicsFolder)
        .child('${_auth.currentUser!.uid}.jpg');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  /// Save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  /// Update specific user fields
  Future<void> updateUserData(Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_auth.currentUser!.uid)
        .update(data);
  }

  /// Get user data by UID
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Stream current user data
  Stream<UserModel?> streamCurrentUser() {
    if (_auth.currentUser == null) return Stream.value(null);
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((snap) {
      if (snap.exists && snap.data() != null) {
        return UserModel.fromMap(snap.data()!);
      }
      return null;
    });
  }

  /// Check if a user profile exists in Firestore
  Future<bool> userProfileExists() async {
    if (_auth.currentUser == null) return false;
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_auth.currentUser!.uid)
        .get();
    return doc.exists;
  }

  /// Get all registered users (for contacts matching)
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != _auth.currentUser?.uid)
        .toList();
  }

  /// Set user online/offline status
  Future<void> setOnlineStatus(bool isOnline) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_auth.currentUser!.uid)
        .update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Sign out
  Future<void> signOut() async {
    await setOnlineStatus(false);
    await _auth.signOut();
  }
}
