import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _updateProfilePic() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );
    if (picked == null) return;

    setState(() => _isSaving = true);
    try {
      final authService = ref.read(authServiceProvider);
      final url = await authService.uploadProfilePic(File(picked.path));
      await authService.updateUserData({'profilePic': url});
      if (mounted) showSnackBar(context, 'Profile photo updated');
    } catch (e) {
      if (mounted) showSnackBar(context, 'Failed to update photo', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showSnackBar(context, 'Name cannot be empty', isError: true);
      return;
    }
    try {
      await ref.read(authServiceProvider).updateUserData({'name': name});
      if (mounted) {
        showSnackBar(context, 'Name updated');
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Failed to update name', isError: true);
    }
  }

  Future<void> _saveAbout() async {
    try {
      await ref
          .read(authServiceProvider)
          .updateUserData({'about': _aboutController.text.trim()});
      if (mounted) {
        showSnackBar(context, 'About updated');
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Failed to update about', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.mediumBrown)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user != null && !_isInitialized) {
            _nameController.text = user.name;
            _aboutController.text = user.about;
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ── Profile Picture ────────────────────────
                GestureDetector(
                  onTap: _isSaving ? null : _updateProfilePic,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor:
                            isDark ? AppColors.darkAppBar : AppColors.cream,
                        backgroundImage: user != null &&
                                user.profilePic.isNotEmpty
                            ? CachedNetworkImageProvider(user.profilePic)
                            : null,
                        child: (user == null || user.profilePic.isEmpty)
                            ? Icon(Icons.person_rounded,
                                size: 64,
                                color: isDark
                                    ? AppColors.warmGray
                                    : AppColors.tan)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.mediumBrown,
                            shape: BoxShape.circle,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_rounded,
                                  size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Name ───────────────────────────────────
                _ProfileField(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  controller: _nameController,
                  onSave: _saveName,
                ),
                const SizedBox(height: 16),

                // ── About ──────────────────────────────────
                _ProfileField(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  controller: _aboutController,
                  onSave: _saveAbout,
                  maxLength: 140,
                ),
                const SizedBox(height: 16),

                // ── Phone (read-only) ──────────────────────
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined,
                      color: AppColors.mediumBrown),
                  title: const Text('Phone'),
                  subtitle: Text(
                    user != null
                        ? '${user.countryCode} ${user.phoneNumber}'
                        : 'Not set',
                    style: TextStyle(
                      color: isDark ? AppColors.warmGray : AppColors.tan,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final int? maxLength;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.onSave,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: const Icon(Icons.check_rounded, color: AppColors.mediumBrown),
          onPressed: onSave,
          tooltip: 'Save',
        ),
      ),
      onSubmitted: (_) => onSave(),
    );
  }
}
