import 'package:flutter/material.dart';

class GroupMembersCard extends StatelessWidget {
  const GroupMembersCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: const Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Icon(Icons.group),
              backgroundColor: Colors.blueGrey,
            ),
            title: Text(
              '~Shivprasad',
              style: TextStyle(
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
