import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/chat_contact_model.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/user_model.dart';
import '../services/chat_service.dart';

// ── Service ─────────────────────────────────────────────────────
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// ── Chat contacts stream (for chat list screen) ─────────────────
final chatContactsProvider = StreamProvider<List<ChatContactModel>>((ref) {
  return ref.watch(chatServiceProvider).getChatContacts();
});

// ── Messages for a given conversation ───────────────────────────
final chatMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, otherUserId) {
  return ref.watch(chatServiceProvider).getChatMessages(otherUserId);
});

// ── Stream a user's data ────────────────────────────────────────
final userDataProvider =
    StreamProvider.family<UserModel, String>((ref, userId) {
  return ref.watch(chatServiceProvider).streamUserData(userId);
});
