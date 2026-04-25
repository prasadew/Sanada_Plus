import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _messageNotifications = true;
  bool _showPreview = true;
  bool _groupNotifications = true;
  bool _callRingtone = true;
  bool _vibrate = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          _buildSectionHeader('Message notifications', isDark),

          SwitchListTile(
            title: const Text('Message notifications'),
            subtitle: const Text('Show notifications for new messages'),
            value: _messageNotifications,
            onChanged: (v) => setState(() => _messageNotifications = v),
          ),

          SwitchListTile(
            title: const Text('Show preview'),
            subtitle: const Text('Display message text in notifications'),
            value: _showPreview,
            onChanged: (v) => setState(() => _showPreview = v),
          ),

          ListTile(
            title: const Text('Notification tone'),
            subtitle: const Text('Default'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Custom tones coming soon')),
              );
            },
          ),

          SwitchListTile(
            title: const Text('Vibrate'),
            subtitle: const Text('Vibrate on notifications'),
            value: _vibrate,
            onChanged: (v) => setState(() => _vibrate = v),
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Group notifications', isDark),

          SwitchListTile(
            title: const Text('Group notifications'),
            subtitle: const Text('Show notifications for group messages'),
            value: _groupNotifications,
            onChanged: (v) => setState(() => _groupNotifications = v),
          ),

          ListTile(
            title: const Text('Group notification tone'),
            subtitle: const Text('Default'),
            onTap: () {},
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Calls', isDark),

          SwitchListTile(
            title: const Text('Ringtone'),
            subtitle: const Text('Play ringtone for incoming calls'),
            value: _callRingtone,
            onChanged: (v) => setState(() => _callRingtone = v),
          ),

          ListTile(
            title: const Text('Ringtone'),
            subtitle: const Text('Default'),
            onTap: () {},
          ),
        ],
      ),
    );
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
