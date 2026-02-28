import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatControllerProvider).sendMessage(widget.chatId, text);
      _msgController.clear();
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(chatProvider(widget.chatId));
    final messages = thread?.messages ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp background color
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    thread?.contactName ?? 'Contact ${widget.chatId}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    'online',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // typical chat view reversed
              itemCount: messages.length,
              itemBuilder: (context, index) {
                // messages are added to the end of the list, so reversal handles newest at bottom
                final message = messages[messages.length - 1 - index];
                final isMe = message.senderId == 'me';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe 
                        ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                        : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message.text, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat.Hm().format(message.timestamp), 
                          style: TextStyle(fontSize: 10, color: Colors.grey[600])
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                   IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                      ),
                      onChanged: (text) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                   if (_msgController.text.isEmpty)
                    IconButton(
                        icon: const Icon(Icons.currency_rupee, color: Colors.grey),
                        onPressed: () {},
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: Icon(
                _msgController.text.isEmpty ? Icons.camera_alt : Icons.send,
                color: Colors.white,
              ),
              onPressed: () {
                if (_msgController.text.isEmpty) {
                  context.push('/camera').then((detectedText) {
                    if (detectedText != null && detectedText is String) {
                      setState(() {
                         _msgController.text = detectedText;
                      });
                    }
                  });
                } else {
                  _sendMessage();
                 }
              },
            ),
          ),
        ],
      ),
    );
  }
}
