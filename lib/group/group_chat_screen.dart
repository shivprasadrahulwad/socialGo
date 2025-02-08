// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:social/model/message.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:social/group/groupo_messge_widget.dart';
import 'package:social/group/groupr_messge_widget.dart';
import 'package:social/model/groupMessag.dart';

// class GroupChatScreen extends StatefulWidget {
//   final String name;
//   final String userId;

//   const GroupChatScreen({
//     Key? key,
//     required this.name,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   _GroupChatScreenState createState() => _GroupChatScreenState();
// }

// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   IO.Socket? socket;
//   List<MsgModel> listMsg = [];

//   @override
//   void initState() {
//     super.initState();
//     connect();
//   }

//   void connect() {
//     socket = IO.io('http://192.168.1.237:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket!.onConnect((_) {
//       print('✅ Socket connected into frontend successfully');
//       socket!.on('sendMsgServer', (msg) {
//         print(msg);
//         if (msg["userId"] != widget.userId) {
//           setState(() {
//             listMsg.add(MsgModel(
//                 type: msg["msg"], msg: msg["type"], sender: msg["senderName"]));
//           });
//         }
//       });
//     });

//     socket!.onConnectError((err) {
//       print('❌ Connection Error: $err');
//     });

//     socket!.onError((err) {
//       print('❌ Socket Error: $err');
//     });

//     socket!.onDisconnect((_) {
//       print('❌ Socket disconnected');
//     });
//   }

//   void sendMsg(String msg, String senderName) {
//     MsgModel ownMsg = MsgModel(msg: msg, sender: senderName, type: "ownMsg");
//     listMsg.add(ownMsg);
//     setState(() {
//       listMsg;
//     });
//     socket!.emit('sendMsg', {
//       "type": "ownMsg",
//       "msg": msg,
//       "senderName": senderName,
//       "userId": widget.userId,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Memes;${widget.name}',
//               style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//               child: ListView.builder(
//             itemCount: listMsg.length,
//             itemBuilder: (context, index) {
//               // final msg = listMsg[index];
//               if (listMsg[index].type == "ownMsg") {
//                 return OwnMsgWidget(
//                     sender: listMsg[index].sender, msg: listMsg[index].msg);
//               } else {
//                 return OtherMsgWidget(
//                     sender: listMsg[index].sender, msg: listMsg[index].msg);
//               }
//             },
//           )),
          
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     print('tapped');
//                     final msg = _messageController.text;
//                     if (msg.isNotEmpty) {
//                       sendMsg(msg, widget.name);
//                       _messageController.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class GroupChatScreen extends StatefulWidget {
//   final String name;
//   final String userId;
//   final String chatId;

//   const GroupChatScreen({
//     Key? key,
//     required this.name,
//     required this.userId,
//     required this.chatId,
//   }) : super(key: key);

//   @override
//   _GroupChatScreenState createState() => _GroupChatScreenState();
// }

// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   IO.Socket? socket;
//   List<Message> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     connect();
//   }

//   void connect() {
//     socket = IO.io('http://192.168.1.108:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket!.onConnect((_) {
//       print('✅ Socket connected into frontend successfully');
//       socket!.on('sendMsgServer', (msgData) {
//         print(msgData);
//         if (msgData["senderId"] != widget.userId) {
//           final newMessage = Message(
//             messageId: msgData["messageId"],
//             chatId: widget.chatId,
//             senderId: msgData["senderId"],
//             type: MessageType.text,
//             content: MessageContent(text: msgData["text"]),
//             status: MessageStatus.delivered,
//           );

//           setState(() {
//             messages.add(newMessage);
//           });
//         }
//       });
//     });

//     socket!.onConnectError((err) => print('❌ Connection Error: $err'));
//     socket!.onError((err) => print('❌ Socket Error: $err'));
//     socket!.onDisconnect((_) => print('❌ Socket disconnected'));
//   }

//   void sendMessage(String text) {
//     if (text.isEmpty) return;

//     final newMessage = Message(
//       messageId: DateTime.now().millisecondsSinceEpoch.toString(),
//       chatId: widget.chatId,
//       senderId: widget.userId,
//       type: MessageType.text,
//       content: MessageContent(text: text),
//       status: MessageStatus.sending,
//     );

//     setState(() {
//       messages.add(newMessage);
//     });

//     socket!.emit('sendMsg', {
//       "messageId": newMessage.messageId,
//       "chatId": newMessage.chatId,
//       "senderId": newMessage.senderId,
//       "text": text,
//       "type": "text",
//       "createdAt": newMessage.createdAt.toIso8601String(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 final isOwnMessage = message.senderId == widget.userId;

//                 return GroupMessageCard(
//                   message: message.content.text ?? '',
//                   time: message.createdAt,
//                   isRead: message.status == MessageStatus.read,
//                   isSender: isOwnMessage,
//                   senderName: isOwnMessage ? 'You' : message.senderId,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message......',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     final text = _messageController.text;
//                     if (text.isNotEmpty) {
//                       sendMessage(text);
//                       _messageController.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class GroupChatScreen extends StatefulWidget {
  final String name;
  final String userId;
  final String chatId;

  const GroupChatScreen({
    Key? key,
    required this.name,
    required this.userId,
    required this.chatId,
  }) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   IO.Socket? socket;
//   List<Message> messages = [];
//   bool isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     connectAndSetupSocket();
//   }

//   void connectAndSetupSocket() {
//     socket = IO.io('http://192.168.1.108:5000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket!.onConnect((_) {
//       print('✅ Socket connected successfully');
//       setState(() => isConnected = true);
      
//       // Join the group chat room
//       socket!.emit('joinGroup', widget.chatId);

//       // Listen for group messages
//       socket!.on('groupMessage', handleGroupMessage);
      
//       // Listen for read receipts
//       socket!.on('messageReadReceipt', handleReadReceipt);
//     });

//     // Error handling
//     socket!.onConnectError((err) => print('❌ Connection Error: $err'));
//     socket!.onError((err) => print('❌ Socket Error: $err'));
//     socket!.onDisconnect((_) {
//       print('❌ Socket disconnected');
//       setState(() => isConnected = false);
//     });
//   }

//   void handleGroupMessage(dynamic msgData) {
//     if (msgData["sourceId"] != widget.userId) {
//       final newMessage = Message(
//         messageId: msgData["messageId"],
//         chatId: widget.chatId,
//         senderId: msgData["sourceId"],
//         type: MessageType.text,
//         content: MessageContent(text: msgData["message"]),
//         status: MessageStatus.delivered,
//       );

//       setState(() {
//         messages.add(newMessage);
//       });

//       // Send read receipt
//       socket!.emit('messageRead', {
//         'messageId': msgData["messageId"],
//         'groupId': widget.chatId,
//         'readBy': widget.userId,
//         'type': 'group'
//       });
//     }
//   }

//   void handleReadReceipt(dynamic receiptData) {
//     if (receiptData["type"] == "group") {
//       setState(() {
//         final messageIndex = messages.indexWhere(
//           (m) => m.messageId == receiptData["messageId"]
//         );
//         if (messageIndex != -1) {
//           messages[messageIndex] = messages[messageIndex].copyWith(
//             status: MessageStatus.read,
//             readBy: [...messages[messageIndex].readBy, receiptData["readBy"]]
//           );
//         }
//       });
//     }
//   }

//   void sendMessage(String text) {
//     if (text.isEmpty || !isConnected) return;

//     final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final newMessage = Message(
//       messageId: messageId,
//       chatId: widget.chatId,
//       senderId: widget.userId,
//       type: MessageType.text,
//       content: MessageContent(text: text),
//       status: MessageStatus.sending,
//     );

//     setState(() {
//       messages.add(newMessage);
//     });

//     // Emit group message
//     socket!.emit('groupMessage', {
//       'messageId': messageId,
//       'groupId': widget.chatId,
//       'sourceId': widget.userId,
//       'message': text,
//       'path': null,
//       'type': 'text',
//       'createdAt': DateTime.now().toIso8601String(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             if (!isConnected)
//               const Text(
//                 'Connecting...',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () {
//               // Show group info/participants
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               reverse: true,
//               itemBuilder: (context, index) {
//                 final message = messages[messages.length - 1 - index];
//                 final isOwnMessage = message.senderId == widget.userId;

//                 return GroupMessageCard(
//                   message: message.content.text ?? '',
//                   time: message.createdAt,
//                   isRead: message.readBy.isNotEmpty,
//                   isSender: isOwnMessage,
//                   senderName: isOwnMessage ? 'You' : message.senderId,
//                   // readBy: message.readBy,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: () {
//                     // Handle file attachment
//                   },
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: isConnected 
//                         ? 'Type a message...' 
//                         : 'Connecting to chat...',
//                       border: const OutlineInputBorder(),
//                       enabled: isConnected,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: isConnected ? () {
//                     final text = _messageController.text;
//                     if (text.isNotEmpty) {
//                       sendMessage(text);
//                       _messageController.clear();
//                     }
//                   } : null,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     socket?.emit('leaveGroup', widget.chatId);
//     socket?.disconnect();
//     socket?.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }
// }


class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  IO.Socket? socket;
  List<Message> messages = [];
  bool isConnected = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    connectAndSetupSocket();
    loadInitialMessages();
  }

  // Load initial messages from server
  Future<void> loadInitialMessages() async {
    try {
      // Add your API call to fetch initial messages
      // Example: messages = await ChatService.getGroupMessages(widget.chatId);
      setState(() {});
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> handleMessageSend(String text) async {
    if (text.isEmpty || isSending) return;

    setState(() => isSending = true);
    
    try {
      final Message? sentMessage = await ChatServices.sendGroupMessage(
        context: context,
        chatId: widget.chatId,
        content: text,
        senderId: widget.userId,
        type: MessageType.text,
        isGroup: true,
        socket: socket,
      );

      if (sentMessage != null) {
        setState(() {
          // Update the local message status or add new message
          final existingIndex = messages.indexWhere(
            (m) => m.messageId == sentMessage.messageId
          );
          
          if (existingIndex != -1) {
            messages[existingIndex] = sentMessage;
          } else {
            messages.add(sentMessage);
          }
        });
      }
    } catch (e) {
      // Error handling is already done in sendGroupMessage
      print('Error in handleMessageSend: $e');
    } finally {
      setState(() => isSending = false);
    }
  }

  // Modified socket connection setup
  void connectAndSetupSocket() {
    socket = IO.io('http://192.168.1.112:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      print('✅ Socket connected successfully');
      setState(() => isConnected = true);
      
      socket!.emit('joinGroup', widget.chatId);
      socket!.on('groupMessage', handleGroupMessage);
      // socket!.on('messageReadReceipt', handleReadReceipt);
    });

    socket!.onConnectError((err) => print('❌ Connection Error: $err'));
    socket!.onError((err) => print('❌ Socket Error: $err'));
    socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      setState(() => isConnected = false);
    });
  }

  void handleGroupMessage(dynamic msgData) {
    if (msgData["sourceId"] != widget.userId) {
      final newMessage = Message(
        messageId: msgData["messageId"],
        chatId: widget.chatId,
        senderId: msgData["sourceId"],
        type: MessageType.values.firstWhere(
          (e) => e.toString() == 'MessageType.${msgData["messageType"]}',
          orElse: () => MessageType.text,
        ),
        content: MessageContent(
          text: msgData["message"],
          mediaUrl: msgData["path"],
          fileName: msgData["fileName"],
          fileSize: msgData["fileSize"],
          duration: msgData["duration"],
          thumbnail: msgData["thumbnail"],
        ),
        status: MessageStatus.delivered,
      );

      setState(() {
        messages.add(newMessage);
      });

      // Send read receipt
      socket!.emit('messageRead', {
        'messageId': msgData["messageId"],
        'groupId': widget.chatId,
        'readBy': widget.userId,
        'type': 'group'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!isConnected)
              const Text(
                'Connecting...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show group info/participants
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isOwnMessage = message.senderId == widget.userId;

                return GroupMessageCard(
                  message: message.content.text ?? '',
                  time: message.createdAt,
                  isRead: message.readBy.isNotEmpty,
                  isSender: isOwnMessage,
                  senderName: isOwnMessage ? 'You' : message.senderId,
                  // status: message.status,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: isConnected ? () async {
                    // Handle file attachment
                    // Example: await handleFileAttachment();
                  } : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: isConnected 
                        ? 'Type a message...' 
                        : 'Connecting to chat...',
                      border: const OutlineInputBorder(),
                      enabled: isConnected && !isSending,
                    ),
                  ),
                ),
                IconButton(
                  icon: isSending 
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
                  onPressed: (isConnected && !isSending) ? () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      handleMessageSend(text);
                      _messageController.clear();
                    }
                  } : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket?.emit('leaveGroup', widget.chatId);
    socket?.disconnect();
    socket?.dispose();
    _messageController.dispose();
    super.dispose();
  }
}