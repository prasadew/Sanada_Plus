import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  bool _autoDownloadPhotos = true;
  bool _autoDownloadVideos = false;
  bool _autoDownloadDocuments = true;
  String _mediaUploadQuality = 'Standard';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Storage and Data')),
      body: ListView(
        children: [
          // ── Storage usage ──────────────────────────────
          _buildSectionHeader('Storage', isDark),

          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: const Text('Manage storage'),
            subtitle: const Text('View storage usage by chats'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage manager coming soon')),
              );
            },
          ),

          _buildDivider(isDark),

          // ── Network usage ─────────────────────────────
          _buildSectionHeader('Network usage', isDark),

          ListTile(
            leading: const Icon(Icons.data_usage_rounded),
            title: const Text('Network usage'),
            subtitle: const Text('View sent and received data'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Network Usage'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Messages sent: 0'),
                      SizedBox(height: 4),
                      Text('Messages received: 0'),
                      SizedBox(height: 4),
                      Text('Data sent: 0 MB'),
                      SizedBox(height: 4),
                      Text('Data received: 0 MB'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usage stats reset')),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),

          _buildDivider(isDark),

          // ── Auto-download ─────────────────────────────
          _buildSectionHeader('Auto-download media', isDark),

          SwitchListTile(
            secondary: const Icon(Icons.photo_rounded),
            title: const Text('Photos'),
            subtitle: const Text('Auto-download photos'),
            value: _autoDownloadPhotos,
            onChanged: (v) => setState(() => _autoDownloadPhotos = v),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.videocam_rounded),
            title: const Text('Videos'),
            subtitle: const Text('Auto-download videos'),
            value: _autoDownloadVideos,
            onChanged: (v) => setState(() => _autoDownloadVideos = v),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.description_rounded),
            title: const Text('Documents'),
            subtitle: const Text('Auto-download documents'),
            value: _autoDownloadDocuments,
            onChanged: (v) => setState(() => _autoDownloadDocuments = v),
          ),

          _buildDivider(isDark),

          // ── Upload quality ────────────────────────────
          _buildSectionHeader('Upload quality', isDark),

          ListTile(
            leading: const Icon(Icons.high_quality_rounded),
            title: const Text('Media upload quality'),
            subtitle: Text(_mediaUploadQuality),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Upload quality'),
                  children: ['Standard', 'High', 'Best'].map((q) {
                    return RadioListTile<String>(
                      title: Text(q),
                      subtitle: Text(q == 'Standard'
                          ? 'Uses less data'
                          : q == 'High'
                              ? 'Balanced quality'
                              : 'Original quality'),
                      value: q,
                      groupValue: _mediaUploadQuality,
                      activeColor: AppColors.mediumBrown,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _mediaUploadQuality = v);
                          Navigator.pop(ctx);
                        }
                      },
                    );
                  }).toList(),
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
