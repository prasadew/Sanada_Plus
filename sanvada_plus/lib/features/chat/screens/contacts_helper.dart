import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// Helper to wrap flutter_contacts calls.
/// This should only be called on mobile (not web).
class ContactsHelper {
  /// Request contacts permission (mobile only).
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      return await FlutterContacts.requestPermission(readonly: true);
    } catch (e) {
      debugPrint('❌ [CONTACTS] Permission request failed: $e');
      return false;
    }
  }

  /// Get all contacts as a list of maps with 'name' and 'phone' keys.
  /// Returns empty list on web or if permission denied.
  static Future<List<Map<String, String>>> getContacts() async {
    if (kIsWeb) return [];
    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final result = <Map<String, String>>[];

      for (final contact in contacts) {
        if (contact.phones.isEmpty) continue;
        result.add({
          'name': contact.displayName,
          'phone': contact.phones.first.number,
        });
      }

      return result;
    } catch (e) {
      debugPrint('❌ [CONTACTS] Failed to get contacts: $e');
      rethrow;
    }
  }
}
