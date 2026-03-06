import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';

class ChatSettingsScreen extends ConsumerWidget {
  const ChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView(
        children: [
          _buildSectionHeader('Display', isDark),

          // ── Theme selector ────────────────────────────
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text('Theme'),
            subtitle: Text(_themeModeName(themeMode)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Choose theme'),
                  children: ThemeMode.values.map((mode) {
                    return RadioListTile<ThemeMode>(
                      title: Text(_themeModeName(mode)),
                      value: mode,
                      groupValue: themeMode,
                      activeColor: AppColors.mediumBrown,
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(themeModeProvider.notifier).setThemeMode(v);
                          Navigator.pop(ctx);
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.wallpaper_rounded),
            title: const Text('Wallpaper'),
            subtitle: const Text('Change chat background'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wallpaper feature coming soon')),
              );
            },
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Chat settings', isDark),

          SwitchListTile(
            secondary: const Icon(Icons.text_fields_rounded),
            title: const Text('Font size'),
            subtitle: const Text('Medium'),
            value: false,
            onChanged: (_) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.play_circle_outline_rounded),
            title: const Text('Media visibility'),
            subtitle: const Text(
                'Show newly downloaded media in your gallery'),
            value: true,
            onChanged: (_) {},
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Chat history', isDark),

          ListTile(
            leading: const Icon(Icons.cloud_upload_rounded),
            title: const Text('Chat backup'),
            subtitle: const Text('Back up your chats to cloud'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat backup coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Transfer chats'),
            subtitle: const Text('Move your chats to another device'),
            onTap: () {},
          ),

          _buildDivider(isDark),

          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded,
                color: AppColors.error),
            title: const Text('Delete all chats',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete all chats?'),
                  content: const Text(
                    'This will delete all chat messages from this device.',
                  ),
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
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chats deleted')),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.tan : AppColors.mediumBrown,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}
