import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/country_codes.dart';
import '../../../core/utils/utils.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CountryCode _selectedCountry = countryCodes.first; // Sri Lanka
  File? _profileImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageOptionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(ctx);
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                        maxWidth: 512,
                      );
                      if (picked != null) {
                        setState(() => _profileImage = File(picked.path));
                      }
                    },
                  ),
                  _imageOptionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(ctx);
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                        maxWidth: 512,
                      );
                      if (picked != null) {
                        setState(() => _profileImage = File(picked.path));
                      }
                    },
                  ),
                  if (_profileImage != null)
                    _imageOptionButton(
                      icon: Icons.delete_rounded,
                      label: 'Remove',
                      color: AppColors.error,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _profileImage = null);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageOptionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color ?? AppColors.mediumBrown,
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color ?? AppColors.mediumBrown, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppColors.mediumBrown,
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String search = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = countryCodes
                .where((c) =>
                    c.name.toLowerCase().contains(search.toLowerCase()) ||
                    c.dialCode.contains(search))
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollController) => Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.warmGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Country',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                      onChanged: (v) => setSheetState(() => search = v),
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return ListTile(
                          leading: Text(c.flag, style: const TextStyle(fontSize: 28)),
                          title: Text(c.name),
                          trailing: Text(
                            c.dialCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.mediumBrown,
                            ),
                          ),
                          onTap: () {
                            setState(() => _selectedCountry = c);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _continue() async {
    if (!_formKey.currentState!.validate()) return;

    final rawPhone = _phoneController.text.trim();
    final localDigitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (localDigitsOnly.isEmpty) {
      showSnackBar(context, 'Please enter a valid phone number', isError: true);
      return;
    }

    var localForInternational = localDigitsOnly;
    if (localForInternational.startsWith('0')) {
      localForInternational = localForInternational.substring(1);
    }

    final fullPhone = '${_selectedCountry.dialCode}$localForInternational';
    final isLikelyE164 = RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(fullPhone);
    if (!isLikelyE164) {
      showSnackBar(
        context,
        'Invalid phone format. Please check country code and number.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Reset any previous state
    final notifier = ref.read(phoneVerificationProvider.notifier);
    notifier.reset();

    try {
      // Start OTP request and continue to OTP screen immediately.
      // Firebase phone callbacks can be delayed on some devices/networks.
      unawaited(notifier.sendOTP(fullPhone));

      if (!mounted) return;

      // Navigate to OTP screen with registration data
      context.push('/otp', extra: {
        'phoneNumber': fullPhone,
        'name': _nameController.text.trim(),
        'about': _aboutController.text.trim(),
        'countryCode': _selectedCountry.dialCode,
        'localPhone': localDigitsOnly,
        'profileImage': _profileImage,
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to send OTP: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.cream : AppColors.darkBrown,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Profile Image ──────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor:
                          isDark ? AppColors.darkAppBar : AppColors.cream,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: isDark
                                  ? AppColors.warmGray
                                  : AppColors.tan,
                            )
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
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add profile photo',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.warmGray : AppColors.tan,
                ),
              ),
              const SizedBox(height: 28),

              // ── Name ───────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // ── About ──────────────────────────────────────
              TextFormField(
                controller: _aboutController,
                maxLength: 140,
                decoration: const InputDecoration(
                  labelText: 'About',
                  hintText: 'Hey there! I am using Sanvadha+',
                  prefixIcon: Icon(Icons.info_outline_rounded),
                ),
              ),
              const SizedBox(height: 8),

              // ── Phone Number ───────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country code selector
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.warmGray),
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? AppColors.darkSurface : Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flag,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCountry.dialCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Phone input
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (v.trim().length < 7) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ── Continue Button ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
