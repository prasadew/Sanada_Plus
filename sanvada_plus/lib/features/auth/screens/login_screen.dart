import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Legacy screen — users are now directed to [RegistrationScreen].
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/welcome');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
