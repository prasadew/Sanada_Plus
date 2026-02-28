import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 40),
            ),
            title: Text('My Profile', style: TextStyle(fontSize: 18)),
            subtitle: Text('+94 77 123 4567'), // In a real app, get this from auth provider
          ),
          const Divider(),
          _buildSettingsTile(Icons.key, 'Account', 'Security notifications, change number'),
          _buildSettingsTile(Icons.lock, 'Privacy', 'Block contacts, disappearing messages'),
          _buildSettingsTile(Icons.chat, 'Chats', 'Theme, wallpapers, chat history'),
          _buildSettingsTile(Icons.notifications, 'Notifications', 'Message, group & call tones'),
          _buildSettingsTile(Icons.data_usage, 'Storage and data', 'Network usage, auto-download'),
          _buildSettingsTile(Icons.help_outline, 'Help', 'Help center, contact us, privacy policy'),
          _buildSettingsTile(Icons.info_outline, 'About SANVADA+', ''),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authControllerProvider).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: () {},
    );
  }
}
