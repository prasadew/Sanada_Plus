import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId; // This is the other user's UID
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // Mark messages as seen when entering the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatServiceProvider).markMessagesSeen(widget.chatId);
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final otherUser = ref.read(userDataProvider(widget.chatId));
    otherUser.whenData((user) {
      ref.read(chatServiceProvider).sendTextMessage(
            receiverId: widget.chatId,
            receiverName: user.name,
            receiverProfilePic: user.profilePic,
            text: text,
          );
    });

    _msgController.clear();
    setState(() {});

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final userAsync = ref.watch(userDataProvider(widget.chatId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkChatBg : AppColors.lightChatBg,
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 30,
        title: userAsync.when(
          data: (user) => Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    isDark ? AppColors.darkSurface : AppColors.cream,
                backgroundImage: user.profilePic.isNotEmpty
                    ? CachedNetworkImageProvider(user.profilePic)
                    : null,
                child: user.profilePic.isEmpty
                    ? const Icon(Icons.person_rounded, size: 22)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.isOnline
                          ? 'online'
                          : 'last seen ${formatChatTime(user.lastSeen)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: user.isOnline
                            ? AppColors.online
                            : AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => Text('Chat ${widget.chatId}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages list ───────────────────────────────
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.mediumBrown),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 36,
                          color: isDark ? AppColors.warmGray : AppColors.tan,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Messages are end-to-end encrypted.\nSend a message to start chatting.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isDark ? AppColors.warmGray : AppColors.tan,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUid;
                    return ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // ── Message input ──────────────────────────────
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: isDark ? AppColors.darkAppBar : Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: isDark ? AppColors.warmGray : AppColors.tan,
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        maxLines: 5,
                        minLines: 1,
                        style: TextStyle(
                          color: isDark ? AppColors.cream : AppColors.darkBrown,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.warmGray.withOpacity(0.6)
                                : AppColors.tan,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          fillColor: Colors.transparent,
                          filled: true,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_file_rounded,
                        color: isDark ? AppColors.warmGray : AppColors.tan,
                      ),
                      onPressed: () {},
                    ),
                    if (_msgController.text.isEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          color: isDark ? AppColors.warmGray : AppColors.tan,
                        ),
                        onPressed: () => context.push('/camera'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.mediumBrown,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _msgController.text.isEmpty
                      ? Icons.mic_rounded
                      : Icons.send_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_msgController.text.isNotEmpty) {
                    _sendMessage();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
