import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/country_codes.dart';
import '../../../core/utils/utils.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  CountryCode _selectedCountry = countryCodes.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                          leading:
                              Text(c.flag, style: const TextStyle(fontSize: 28)),
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

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final fullPhone = '${_selectedCountry.dialCode}$phone';

    setState(() => _isLoading = true);

    ref.read(phoneVerificationProvider.notifier).reset();
    await ref.read(phoneVerificationProvider.notifier).sendOTP(fullPhone);

    if (!mounted) return;

    final state = ref.read(phoneVerificationProvider);
    if (state.error != null) {
      setState(() => _isLoading = false);
      showSnackBar(context, state.error!, isError: true);
      return;
    }

    setState(() => _isLoading = false);

    context.push('/otp', extra: {
      'phoneNumber': fullPhone,
      'countryCode': _selectedCountry.dialCode,
      'localPhone': phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
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
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkAppBar : AppColors.cream,
                ),
                child: const Icon(
                  Icons.login_rounded,
                  size: 48,
                  color: AppColors.mediumBrown,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream : AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your phone number to log in\nand access your chats.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.warmGray : AppColors.tan,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          Text(_selectedCountry.flag,
                              style: const TextStyle(fontSize: 22)),
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
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Log In'),
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
