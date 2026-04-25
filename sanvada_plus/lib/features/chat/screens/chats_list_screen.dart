import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../providers/chat_provider.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatContactsAsync = ref.watch(chatContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanvadha+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => context.push('/camera'),
            tooltip: 'Sign Language Camera',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
            tooltip: 'Search',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  context.push('/settings');
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'new_group', child: Text('New group')),
              const PopupMenuItem(
                  value: 'starred', child: Text('Starred messages')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: chatContactsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mediumBrown),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: isDark ? AppColors.warmGray : AppColors.tan,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.cream : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to start chatting',
                    style: TextStyle(
                      color: isDark ? AppColors.warmGray : AppColors.tan,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: contacts.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 76),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Consumer(
                builder: (context, ref, _) {
                  final isTyping = ref
                          .watch(typingStatusProvider(contact.contactId))
                          .valueOrNull ??
                      false;

                  return ListTile(
                    onTap: () => context.push('/chat/${contact.contactId}'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          isDark ? AppColors.darkAppBar : AppColors.cream,
                      backgroundImage: contact.profilePic.isNotEmpty
                          ? CachedNetworkImageProvider(contact.profilePic)
                          : null,
                      child: contact.profilePic.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              color:
                                  isDark ? AppColors.warmGray : AppColors.tan,
                              size: 28,
                            )
                          : null,
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: isTyping
                        ? Text(
                            'typing...',
                            style: TextStyle(
                              color: AppColors.online,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Text(
                            contact.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? AppColors.warmGray : AppColors.tan,
                              fontSize: 14,
                            ),
                          ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatChatTime(contact.timeSent),
                          style: TextStyle(
                            fontSize: 12,
                            color: contact.unreadCount > 0
                                ? AppColors.mediumBrown
                                : (isDark ? AppColors.warmGray : AppColors.tan),
                            fontWeight: contact.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (contact.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.mediumBrown,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              contact.unreadCount > 99
                                  ? '99+'
                                  : '${contact.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts'),
        child: const Icon(Icons.message_rounded),
      ),
    );
  }
}
