import 'package:flutter/material.dart';

import 'sign_language_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return SignLanguageScreen(
      finalText: '',
      onSendText: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detected text ready: $message')),
        );
      },
    );
  }
}
