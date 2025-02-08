import 'package:flutter/material.dart';

class NotificationSettingScreen extends StatefulWidget {
  @override
  _NotificationSettingScreenState createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Notification Tone"),
            subtitle: Text("Default (Emerge)"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showNotificationToneDialog(context);
            },
          ),
          Divider(),
          ListTile(
            title: Text("Notifications"),
            subtitle: Text("Block/Don't display incoming notifications"),
            trailing: Switch(
              value: isNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  isNotificationEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void showNotificationToneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Notification Tone"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Emerge"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notification tone set to Emerge")),
                  );
                },
              ),
              ListTile(
                title: Text("Alert"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notification tone set to Alert")),
                  );
                },
              ),
              ListTile(
                title: Text("Chime"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notification tone set to Chime")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
