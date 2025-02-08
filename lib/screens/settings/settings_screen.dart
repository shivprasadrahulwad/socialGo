import 'package:flutter/material.dart';
import 'package:social/screens/Home/qr_scan_screen.dart';
import 'package:social/screens/chat/create_new_password.dart';
import 'package:social/screens/chat/passowrd_reset_screen.dart';
import 'package:social/screens/qr_code/qr_code_screen.dart';
import 'package:social/screens/settings/account_screen.dart';
import 'package:social/screens/settings/help_screen.dart';
import 'package:social/screens/settings/notifications_setting_screen.dart';
import 'package:social/screens/settings/privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shivprasad Rahulwad',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'If you really look clocks',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const QRCodeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            SettingsTile(
              icon: Icons.person,
              title: 'Account',
              subtitle: 'Security notifications, change number',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.lock,
              title: 'Privacy',
              subtitle: 'Block contacts, disappearing messages',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.message,
              title: 'Chats',
              subtitle: 'Themes, wallpapers, chat history',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Message, group & call tones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificationSettingScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.storage,
              title: 'Storage and data',
              subtitle: 'Network usage, auto-download',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  PasswordResetScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.language,
              title: 'App language',
              subtitle: 'English (device language)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateNewPassword()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.help,
              title: 'Help',
              subtitle: 'Help center, contact us, privacy policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.group,
              title: 'Invite friends',
              subtitle: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
