import 'package:flutter/material.dart';
import 'package:social/screens/settings/app_lock_screen.dart';
import 'package:social/screens/settings/blocked_contacts_screen.dart';
import 'package:social/screens/settings/biometric_chat_lock_screen.dart';
import 'package:social/screens/settings/message_timer_screen.dart';
import 'package:social/screens/settings/privacy_checkup_screen.dart';

// Privacy Screen Main Page
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: ListView(
        children: [
          PrivacyTile(
            icon: Icons.block,
            title: 'Blocked contacts',
            subtitle: '33',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlockedContactsScreen()),
              );
            },
          ),
          PrivacyTile(
            icon: Icons.lock,
            title: 'App lock',
            subtitle: 'Disabled',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppLockScreen()),
              );
            },
          ),
          PrivacyTile(
            icon: Icons.lock_outline,
            title: 'Chat lock',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatLockScreen()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Disappearing messages',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PrivacyTile(
            icon: Icons.timer,
            title: 'Default message timer',
            subtitle: 'Start new chats with disappearing messages set to your timer',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessageTimerScreen()),
              );
            },
          ),
          PrivacyTile(
            icon: Icons.security,
            title: 'Privacy checkup',
            subtitle: 'Control your privacy and choose the right settings for you',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyCheckupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Reusable Privacy Tile Widget
class PrivacyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const PrivacyTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}