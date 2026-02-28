import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatListProvider);
    
    // Sort threads so the ones with newest messages show up first
    final sortedThreads = [...threads];
    sortedThreads.sort((a, b) {
      if (a.messages.isEmpty && b.messages.isEmpty) return 0;
      if (a.messages.isEmpty) return 1;
      if (b.messages.isEmpty) return -1;
      return b.messages.last.timestamp.compareTo(a.messages.last.timestamp);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('SANVADA+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined), 
            onPressed: () => context.push('/camera')
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: sortedThreads.isEmpty 
        ? const Center(child: Text('No messages yet. Start a chat!'))
        : ListView.builder(
            itemCount: sortedThreads.length,
            itemBuilder: (context, index) {
              final thread = sortedThreads[index];
              final lastMessage = thread.messages.isNotEmpty ? thread.messages.last : null;
              
              return ListTile(
                onTap: () => context.push('/chat/${thread.id}'),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                title: Text(
                  thread.contactName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  lastMessage?.text ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: lastMessage == null ? null : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.Hm().format(lastMessage.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    // Just fake some unread count logic
                    if (index == 0) 
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts'),
        child: const Icon(Icons.message),
      ),
    );
  }
}
