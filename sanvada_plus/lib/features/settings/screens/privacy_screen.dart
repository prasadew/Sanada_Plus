import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _lastSeen = 'Everyone';
  String _profilePhoto = 'Everyone';
  String _about = 'Everyone';
  String _readReceipts = 'On';
  bool _disappearingMessages = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        children: [
          _buildSectionHeader('Who can see my personal info', isDark),

          _buildPrivacyOption(
            title: 'Last seen & online',
            subtitle: _lastSeen,
            options: ['Everyone', 'My contacts', 'Nobody'],
            currentValue: _lastSeen,
            onChanged: (v) => setState(() => _lastSeen = v),
          ),
          _buildPrivacyOption(
            title: 'Profile photo',
            subtitle: _profilePhoto,
            options: ['Everyone', 'My contacts', 'Nobody'],
            currentValue: _profilePhoto,
            onChanged: (v) => setState(() => _profilePhoto = v),
          ),
          _buildPrivacyOption(
            title: 'About',
            subtitle: _about,
            options: ['Everyone', 'My contacts', 'Nobody'],
            currentValue: _about,
            onChanged: (v) => setState(() => _about = v),
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Messaging', isDark),

          _buildPrivacyOption(
            title: 'Read receipts',
            subtitle: _readReceipts == 'On'
                ? 'Blue ticks are on'
                : 'Blue ticks are off',
            options: ['On', 'Off'],
            currentValue: _readReceipts,
            onChanged: (v) => setState(() => _readReceipts = v),
          ),

          SwitchListTile(
            title: const Text('Disappearing messages'),
            subtitle: Text(
              _disappearingMessages
                  ? 'Messages disappear after 24 hours'
                  : 'Off',
            ),
            value: _disappearingMessages,
            onChanged: (v) => setState(() => _disappearingMessages = v),
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Blocked contacts', isDark),

          ListTile(
            leading: const Icon(Icons.block_rounded),
            title: const Text('Blocked contacts'),
            subtitle: const Text('0 contacts blocked'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No blocked contacts')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(title),
            children: options
                .map(
                  (opt) => RadioListTile<String>(
                    title: Text(opt),
                    value: opt,
                    groupValue: currentValue,
                    activeColor: AppColors.mediumBrown,
                    onChanged: (v) {
                      if (v != null) {
                        onChanged(v);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
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
