import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          _buildSectionHeader('Security', isDark),
          SwitchListTile(
            secondary: const Icon(Icons.security_rounded),
            title: const Text('Two-step verification'),
            subtitle: const Text('Add extra security with a PIN'),
            value: false,
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Two-step verification coming soon')),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.fingerprint_rounded),
            title: Text('Fingerprint lock'),
            subtitle: Text('Require fingerprint to unlock Sanvadha+'),
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Change Number', isDark),
          ListTile(
            leading: const Icon(Icons.phone_rounded),
            title: const Text('Change phone number'),
            subtitle: const Text('Migrate your account to a new number'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change number feature coming soon')),
              );
            },
          ),

          _buildDivider(isDark),
          _buildSectionHeader('Request Account Info', isDark),
          const ListTile(
            leading: Icon(Icons.description_rounded),
            title: Text('Request account info'),
            subtitle:
                Text('Request a report of your Sanvadha+ account information'),
          ),

          _buildDivider(isDark),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded,
                color: AppColors.error),
            title: const Text('Delete my account',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'This will permanently delete your account and all data. This action cannot be undone.',
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
                          const SnackBar(
                            content: Text('Account deletion coming soon'),
                          ),
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
