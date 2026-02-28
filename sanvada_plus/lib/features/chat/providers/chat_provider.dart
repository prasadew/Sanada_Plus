import 'package:flutter_riverpod/flutter_riverpod.dart';

// MOCK DATA STRUCTURES
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}

class ChatThread {
  final String id;
  final String contactName;
  final String contactId;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.contactName,
    required this.contactId,
    required this.messages,
  });
}

// MOCK DATA
final _mockThreads = [
  ChatThread(
    id: '1',
    contactName: 'Alice',
    contactId: 'user_alice',
    messages: [
      ChatMessage(id: 'm1', senderId: 'user_alice', text: 'Hey there! How are you?', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      ChatMessage(id: 'm2', senderId: 'me', text: 'I am doing well, thanks! You?', timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
    ],
  ),
  ChatThread(
    id: '2',
    contactName: 'Bob',
    contactId: 'user_bob',
    messages: [
      ChatMessage(id: 'm3', senderId: 'user_bob', text: 'Did you see the latest update?', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    ],
  ),
];

// PROVIDERS
final chatListProvider = StateProvider<List<ChatThread>>((ref) => _mockThreads);

final chatProvider = Provider.family<ChatThread?, String>((ref, id) {
  final threads = ref.watch(chatListProvider);
  return threads.firstWhere((t) => t.id == id, orElse: () => ChatThread(id: id, contactName: 'Unknown', contactId: 'unknown', messages: []));
});

class ChatController {
  final Ref _ref;
  ChatController(this._ref);

  void sendMessage(String threadId, String text) {
    var threads = _ref.read(chatListProvider);
    final index = threads.indexWhere((t) => t.id == threadId);
    
    if (index != -1) {
      final thread = threads[index];
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me', // Assuming 'me' is the current user's ID
        text: text,
        timestamp: DateTime.now(),
      );
      
      final updatedThread = ChatThread(
        id: thread.id,
        contactName: thread.contactName,
        contactId: thread.contactId,
        messages: [...thread.messages, newMessage],
      );
      
      final updatedThreads = [...threads];
      updatedThreads[index] = updatedThread;
      _ref.read(chatListProvider.notifier).state = updatedThreads;
    } else {
       // if it's a new chat, create a new thread
       final newThread = ChatThread(
        id: threadId,
        contactName: 'Contact $threadId',
        contactId: threadId,
        messages: [
           ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'me',
            text: text,
            timestamp: DateTime.now(),
          )
        ],
      );
      _ref.read(chatListProvider.notifier).state = [...threads, newThread];
    }
  }
}

final chatControllerProvider = Provider((ref) => ChatController(ref));
