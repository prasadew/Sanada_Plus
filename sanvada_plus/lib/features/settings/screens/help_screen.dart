import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.help_center_rounded),
            title: const Text('Help Center'),
            subtitle: const Text('Get answers to frequently asked questions'),
            onTap: () => _launchUrl('https://sanvadhaplus.com/help'),
          ),

          ListTile(
            leading: const Icon(Icons.contact_support_rounded),
            title: const Text('Contact us'),
            subtitle: const Text('Send us a message for support'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text('Contact Us'),
                    content: TextField(
                      controller: controller,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe your issue...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message sent! We\'ll get back to you soon.'),
                            ),
                          );
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('Privacy Policy'),
            onTap: () => _launchUrl('https://sanvadhaplus.com/privacy'),
          ),

          ListTile(
            leading: const Icon(Icons.gavel_rounded),
            title: const Text('Terms of Service'),
            onTap: () => _launchUrl('https://sanvadhaplus.com/terms'),
          ),

          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: const Text('Licenses'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Sanvadha+',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
