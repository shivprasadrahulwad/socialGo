import 'package:flutter/material.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/screens/groups/group_members_card.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key});
  

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_back),
                Container(
                  height: 140,
                  width: 140,
                  decoration: const BoxDecoration(
                      color: Colors.amberAccent, shape: BoxShape.circle),
                ),
                const Icon(Icons.edit),
              ],
            ),
            const SizedBox(height: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SocialGo MITAOE Dating Group',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Group : 891 members',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Description: This is a group for MITAOE students',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Limits to two lines for the description
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: GlobalVariables.blueBackground,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_outlined),
                        SizedBox(width: 20),
                        Text('Notifications', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.image_outlined),
                        SizedBox(width: 20),
                        Text('Notifications', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: GlobalVariables.blueBackground,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.enhanced_encryption_outlined),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Encryption', style: TextStyle(fontSize: 16)),
                              Text(
                                'Messages are end-to-end encrypted. Tap to learn more.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: GlobalVariables.blueBackground,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('891 members'),
                        Spacer(),
                        Icon(Icons.search)
                      ],
                    ),
                    SizedBox(height: 30,),
                    GroupMembersCard(),
                    GroupMembersCard(),
                    GroupMembersCard(),
                    GroupMembersCard(),
                    SizedBox(height: 20),
                    Text('View all (880 more)',style: TextStyle(color: Colors.green,fontSize: 16),)
                  ],
                ),
              ),
            ),
             const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: GlobalVariables.blueBackground,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(width: 20),
                        Text('Exit Group', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.report),
                        SizedBox(width: 20),
                        Text('Report group', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
