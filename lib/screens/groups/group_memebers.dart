import 'package:flutter/material.dart';
import 'package:social/model/chatModel.dart';
import 'package:social/screens/Home/chat_card.dart';

// class GroupMembers extends StatefulWidget {
//   const GroupMembers({
//     Key? key,
//     required this.chatmodels,
//     required this.sourchat,
//   }) : super(key: key);
//   final List<ChatModel> chatmodels;
//   final ChatModel sourchat;
  

//   @override
//   _GroupMembersState createState() => _GroupMembersState();
// }

// class _GroupMembersState extends State<GroupMembers> {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         ListView.builder(
//           itemCount: 10,
//           itemBuilder: (contex, index) => ChatCard(
//             chatModells: widget.chatmodells[index],
//             sourchat: widget.sourchat,
//           ),
//         ),
//       ],
//     );
//   }
// }