import 'package:flutter/material.dart';

/// Utility helpers used across the app.

void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
}

/// Generates a deterministic chat ID for two users.
String getChatId(String uid1, String uid2) {
  final sorted = [uid1, uid2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

/// Normalise a phone number for comparison (strip spaces, dashes).
String normalizePhone(String phone) {
  return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
}

/// Format a DateTime for display in chat list.
String formatChatTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (dateToCheck == today) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  final yesterday = today.subtract(const Duration(days: 1));
  if (dateToCheck == yesterday) {
    return 'Yesterday';
  }

  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
