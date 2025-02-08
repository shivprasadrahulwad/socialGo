import 'package:flutter/material.dart';

class SettingBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(
          context,
          title: 'Reset',
          icon: Icons.navigate_next,
          onTap: () {
            // Handle Reset action
            Navigator.pop(context);
          },
        ),
        const Divider(),
        _buildRow(
          context,
          title: 'Set Password',
          icon: Icons.navigate_next,
          onTap: () {
            // Handle Set Password action
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Spacer(),
            Icon(
              icon,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
