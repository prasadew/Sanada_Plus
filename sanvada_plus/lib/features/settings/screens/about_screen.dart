import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // ── Logo ──────────────────────────────────────
            Container(
              width: 120,
              height: 120,
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
              ),
              child: const Icon(
                Icons.chat_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Sanvadha+',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.cream : AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.warmGray : AppColors.tan,
              ),
            ),
            const SizedBox(height: 32),

            // ── Description ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Sanvadha+',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.cream : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sanvadha+ is a real-time messaging application designed to keep you connected with friends, family, and colleagues. '
                    'Built with modern technology and a focus on user privacy and security.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? AppColors.warmGray : AppColors.mediumBrown,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Features ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.cream : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _featureItem(Icons.message_rounded, 'Real-time messaging', isDark),
                  _featureItem(Icons.lock_rounded, 'Secure conversations', isDark),
                  _featureItem(Icons.palette_rounded, 'Light & Dark themes', isDark),
                  _featureItem(Icons.contacts_rounded, 'Easy contact integration', isDark),
                  _featureItem(Icons.notifications_rounded, 'Smart notifications', isDark),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Text(
              '© 2026 Sanvadha+ Team. All rights reserved.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.warmGray : AppColors.tan,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.mediumBrown),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.warmGray : AppColors.mediumBrown,
            ),
          ),
        ],
      ),
    );
  }
}
