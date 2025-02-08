// import 'package:flutter/material.dart';
// import 'package:social/model/chat.dart';
// import 'package:social/model/chatModel.dart';
// import 'package:social/screens/Home/chat_card.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({
//     Key? key,
//     // required this.chatmodels,
//     // required this.sourchat, 
//     required this.chatModells, required this.sourcechat,
//   }) : super(key: key);
//   // final List<ChatModel> chatmodels;
//   final List<Chat> chatModells;
//   final String sourcechat;
//   // final ChatModel sourchat;
  

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
  
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         ListView.builder(
//           itemCount: widget.chatModells.length,
//           itemBuilder: (contex, index) => ChatCard(
//             chatModells: widget.chatModells[index],
//             sourchat: widget.sourcechat,
//           ),
//         ),
//       ],
//     );
//   }
// }