import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../providers/auth_provider.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> registrationData;
  const OTPScreen({super.key, required this.registrationData});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _profileSaved = false;

  String get phoneNumber =>
      widget.registrationData['phoneNumber'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    // Listen for auto-verification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(phoneVerificationProvider, (prev, next) {
        if (next.verified && !_profileSaved && mounted) {
          _onVerificationSuccess();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getOTP() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _onVerificationSuccess() async {
    if (_profileSaved) return;
    _profileSaved = true;

    try {
      await ref.read(authControllerProvider).saveUserProfile(
            name: widget.registrationData['name'] as String? ?? '',
            about: widget.registrationData['about'] as String? ?? '',
            phoneNumber:
                widget.registrationData['localPhone'] as String? ?? '',
            countryCode:
                widget.registrationData['countryCode'] as String? ?? '+94',
            profileImage:
                widget.registrationData['profileImage'] as File?,
          );

      if (mounted) {
        showSnackBar(context, 'Welcome to Sanvadha+!');
        context.go('/chats');
      }
    } catch (e) {
      _profileSaved = false;
      if (mounted) {
        showSnackBar(context, 'Error saving profile: $e', isError: true);
      }
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTP();
    if (otp.length < 6) {
      showSnackBar(context, 'Please enter the 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final success =
          await ref.read(phoneVerificationProvider.notifier).verifyOTP(otp);

      if (success && mounted) {
        await _onVerificationSuccess();
      } else if (mounted) {
        final error = ref.read(phoneVerificationProvider).error;
        showSnackBar(context, error ?? 'Invalid OTP. Please try again.',
            isError: true);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Verification failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _resendOTP() {
    ref.read(phoneVerificationProvider.notifier).sendOTP(phoneNumber);
    showSnackBar(context, 'OTP resent to $phoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verificationState = ref.watch(phoneVerificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.cream : AppColors.darkBrown,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Illustration ───────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkAppBar
                    : AppColors.cream,
              ),
              child: Icon(
                Icons.mark_email_read_rounded,
                size: 48,
                color: AppColors.mediumBrown,
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Verification Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.cream : AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We have sent the OTP verification code to\n$phoneNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.warmGray : AppColors.tan,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),

            // ── OTP Fields ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 48,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.cream : AppColors.darkBrown,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.cream.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.warmGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.mediumBrown,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      // Auto verify when all 6 digits entered
                      if (_getOTP().length == 6) {
                        _verifyOTP();
                      }
                    },
                  ),
                );
              }),
            ),

            if (verificationState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                verificationState.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 32),

            // ── Resend ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    color: isDark ? AppColors.warmGray : AppColors.tan,
                  ),
                ),
                TextButton(
                  onPressed: verificationState.isLoading ? null : _resendOTP,
                  child: const Text(
                    'Resend',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Verify Button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_isVerifying || verificationState.isLoading)
                    ? null
                    : _verifyOTP,
                child: (_isVerifying || verificationState.isLoading)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
