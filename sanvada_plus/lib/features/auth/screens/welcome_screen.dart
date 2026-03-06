import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── Logo ──────────────────────────────────────────
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mediumBrown,
                    AppColors.tan,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mediumBrown.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // ── App name ──────────────────────────────────────
            Text(
              'Sanvadha+',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.cream : AppColors.darkBrown,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Connect with friends and family\nseamlessly and securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.warmGray : AppColors.mediumBrown,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // ── Terms ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Read our Privacy Policy. Tap "Agree and Continue" to accept the Terms of Service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.warmGray.withOpacity(0.7)
                      : AppColors.tan,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Agree and Continue'),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
