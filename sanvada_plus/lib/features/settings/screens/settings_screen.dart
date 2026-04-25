import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Profile header ──────────────────────────────
          userAsync.when(
            data: (user) => ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => context.push('/settings/profile'),
              leading: CircleAvatar(
                radius: 32,
                backgroundColor:
                    isDark ? AppColors.darkAppBar : AppColors.cream,
                backgroundImage:
                    user != null && user.profilePic.isNotEmpty
                        ? CachedNetworkImageProvider(user.profilePic)
                        : null,
                child: (user == null || user.profilePic.isEmpty)
                    ? Icon(Icons.person_rounded,
                        size: 36,
                        color:
                            isDark ? AppColors.warmGray : AppColors.tan)
                    : null,
              ),
              title: Text(
                user?.name ?? 'User',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                user?.about ?? 'Hey there! I am using Sanvadha+',
                style: TextStyle(
                  color: isDark ? AppColors.warmGray : AppColors.tan,
                ),
              ),
              trailing: Icon(
                Icons.qr_code_rounded,
                color: isDark ? AppColors.tan : AppColors.mediumBrown,
              ),
            ),
            loading: () => const ListTile(
              leading: CircleAvatar(radius: 32),
              title: Text('Loading...'),
            ),
            error: (_, __) => const ListTile(
              leading: CircleAvatar(radius: 32),
              title: Text('Error loading profile'),
            ),
          ),

          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          // ── Settings options ───────────────────────────
          _SettingsTile(
            icon: Icons.key_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'Account',
            subtitle: 'Security notifications, change number',
            onTap: () => context.push('/settings/account'),
          ),
          _SettingsTile(
            icon: Icons.lock_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'Privacy',
            subtitle: 'Block contacts, disappearing messages',
            onTap: () => context.push('/settings/privacy'),
          ),
          _SettingsTile(
            icon: Icons.chat_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'Chats',
            subtitle: 'Theme, wallpapers, chat history',
            onTap: () => context.push('/settings/chat-settings'),
          ),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'Notifications',
            subtitle: 'Message, group & call tones',
            onTap: () => context.push('/settings/notifications'),
          ),
          _SettingsTile(
            icon: Icons.data_usage_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'Storage and Data',
            subtitle: 'Network usage, auto-download',
            onTap: () => context.push('/settings/storage'),
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'Help',
            subtitle: 'Help center, contact us, privacy policy',
            onTap: () => context.push('/settings/help'),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.mediumBrown,
            title: 'About Sanvadha+',
            subtitle: '',
            onTap: () => context.push('/settings/about'),
          ),

          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          // ── Sign out ───────────────────────────────────
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _showSignOutDialog(context, ref),
          ),

          const SizedBox(height: 24),

          // ── Footer ─────────────────────────────────────
          Center(
            child: Text(
              'Sanvadha+ v1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.warmGray : AppColors.tan,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) context.go('/welcome');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.warmGray : AppColors.tan,
              ),
            )
          : null,
    );
  }
}
