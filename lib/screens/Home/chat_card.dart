// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:social/group/group_chat_screen.dart';
// import 'package:social/model/chat.dart';
// import 'package:social/model/chatModel.dart';
// import 'package:social/providers/user_provider.dart';
// import 'package:social/screens/chat/chat_screen.dart';

// // class ChatCard extends StatelessWidget {
// //   const ChatCard({
// //     Key? key,
// //     required this.chatModells,
// //     required this.sourchat,
// //   }) : super(key: key);

// //   final Chat chatModells;
// //   final String sourchat;

// //   @override
// //   Widget build(BuildContext context) {
// //     String displayUserId = chatModells.participants
// //         .firstWhere(
// //           (participant) =>
// //               participant.userId != sourchat, // Condition to exclude sourchat
// //           orElse: () => Participant(
// //               userId: 'No user available',
// //               joinedAt: DateTime.now()), // Fallback if no match found
// //         )
// //         .userId;
// //     String userName = chatModells.participants
// //         .firstWhere(
// //           (participant) =>
// //               participant.userId != sourchat, // Condition to exclude sourchat
// //           orElse: () =>
// //           Participant(
// //               userId: 'No user available',
// //               joinedAt: DateTime.now()), // Fallback if no match found
// //         )
// //         .userId;
// //     return InkWell(
// //       onTap: () {
// //         Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //                 builder: (contex) => ChatScreen(
// //                       reciverId: displayUserId,
// //                       sourchat: sourchat,
// //                       chatId: chatModells.id,
// //                     )));
// //       },
// //       child: Column(
// //         children: [
// //           ListTile(
// //             leading: const CircleAvatar(
// //               radius: 30,
// //               child: Icon(Icons.group),
// //               backgroundColor: Colors.blueGrey,
// //             ),
// //             title: Text(
// //               displayUserId,
// //               style: const TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             subtitle: Row(
// //               children: [
// //                 const Icon(Icons.done_all),
// //                 const SizedBox(
// //                   width: 3,
// //                 ),
// //                 Text(
// //                   'we have to show latest message',
// //                   style: const TextStyle(
// //                     fontSize: 13,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             trailing: Text(chatModells.createdAt.toString()),
// //           ),
// //           const Padding(
// //             padding: EdgeInsets.only(right: 20, left: 80),
// //             child: Divider(
// //               thickness: 1,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class ChatCard extends StatelessWidget {
//   const ChatCard({
//     Key? key,
//     required this.chatModells,
//     required this.sourchat,
//   }) : super(key: key);

//   final Chat chatModells;
//   final String sourchat;

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final userId = userProvider.user.id;
//     String displayUserId = chatModells.participants
//         .firstWhere(
//           (participant) => participant.userId != sourchat,
//           orElse: () => Participant(
//             userId: 'No user available',
//             joinedAt: DateTime.now(),
//           ),
//         )
//         .userId;

//     return InkWell(
//       onTap: () {
//         if (chatModells.type == "group") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => GroupChatScreen(
//                     name: chatModells.name ?? '',
//                     userId: userId,
//                     chatId: chatModells.id)),
//           );
//         } else {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatScreen(
//                 reciverId: displayUserId,
//                 sourchat: sourchat,
//                 chatId: chatModells.id,
//                 hide: chatModells.hide,
//               ),
//             ),
//           );
//         }
//       },
//       child: Column(
//         children: [
//           ListTile(
//             leading: const CircleAvatar(
//               radius: 30,
//               child: Icon(Icons.group),
//               backgroundColor: Colors.blueGrey,
//             ),
//             title: Text(
//               chatModells.type == "group"
//                   ? chatModells.name ?? 'groups'
//                   : displayUserId,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Row(
//               children: [
//                 const Icon(Icons.done_all),
//                 const SizedBox(
//                   width: 3,
//                 ),
//                 Text(
//                   'we have to show latest message',
//                   style: const TextStyle(
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Text(chatModells.createdAt.toString()),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(right: 20, left: 80),
//             child: Divider(
//               thickness: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
