import 'package:flutter/material.dart';
import 'package:social/model/chatModel.dart';
import 'package:social/screens/chat/chat_screen.dart';

class GroupMembersCard extends StatelessWidget {
  const GroupMembersCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              radius: 30,
              child: Icon(Icons.group),
              backgroundColor: Colors.blueGrey,
            ),
            title: Text(
              '~Shivprasad',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text('+91 8830031264'),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
