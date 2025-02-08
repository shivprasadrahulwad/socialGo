// // 1. User Model - Stores user information
// import 'package:flutter/material.dart';

// const UserSchema = new mongoose.Schema({
//   phoneNumber: {
//     type: String,
//     required: true,
//     unique: true
//   },
//   name: {
//     type: String,
//     required: true
//   },
//   profilePicture: String,
//   about: String,
//   lastSeen: Date,
//   isOnline: Boolean,
//   settings: {
//     privacy: {
//       lastSeen: {
//         type: String,
//         enum: ['everyone', 'contacts', 'nobody'],
//         default: 'everyone'
//       },
//       profilePhoto: {
//         type: String,
//         enum: ['everyone', 'contacts', 'nobody'],
//         default: 'everyone'
//       },
//       status: {
//         type: String,
//         enum: ['everyone', 'contacts', 'nobody'],
//         default: 'everyone'
//       }
//     },
//     notifications: {
//       messagePreview: Boolean,
//       messageSound: Boolean,
//       groupSound: Boolean
//     }
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   }
// });

// // 2. Chat Model - Stores chat metadata between two users
// const ChatSchema = new mongoose.Schema({
//   participants: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User',
//     required: true
//   }],
//   chatType: {
//     type: String,
//     enum: ['individual', 'group'],
//     default: 'individual'
//   },
//   lastMessage: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Message'
//   },
//   unreadCounts: {
//     type: Map,
//     of: Number,
//     default: {}  // Stores unread counts for each participant
//   },
//   meta: {
//     type: Map,
//     of: {
//       archived: Boolean,
//       muted: Boolean,
//       pinnedAt: Date,
//       customNotification: String,
//       wallpaper: String
//     },
//     default: {}  // Stores per-user chat settings
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   },
//   updatedAt: {
//     type: Date,
//     default: Date.now
//   }
// }, {
//   timestamps: true
// });

// // 3. Message Model - Stores actual messages
// const MessageSchema = new mongoose.Schema({
//   chatId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Chat',
//     required: true,
//     index: true  // For faster queries
//   },
//   sender: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User',
//     required: true
//   },
//   messageType: {
//     type: String,
//     enum: ['text', 'image', 'video', 'audio', 'document', 'location', 'contact', 'sticker'],
//     default: 'text'
//   },
//   content: {
//     text: String,
//     caption: String,
//     mediaUrl: String,
//     thumbnail: String,
//     mimeType: String,
//     fileName: String,
//     fileSize: Number,
//     duration: Number,  // For audio/video
//     location: {
//       latitude: Number,
//       longitude: Number,
//       address: String
//     },
//     contact: {
//       name: String,
//       phoneNumbers: [String],
//       email: String
//     }
//   },
//   quotedMessage: {
//     messageId: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'Message'
//     },
//     content: String,
//     type: String
//   },
//   readBy: [{
//     user: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'User'
//     },
//     readAt: Date
//   }],
//   deliveredTo: [{
//     user: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'User'
//     },
//     deliveredAt: Date
//   }],
//   status: {
//     type: String,
//     enum: ['sent', 'delivered', 'read'],
//     default: 'sent'
//   },
//   deletedFor: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   }],
//   starredBy: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   }],
//   forwarded: {
//     type: Boolean,
//     default: false
//   },
//   forwardCount: {
//     type: Number,
//     default: 0
//   },
//   reactions: [{
//     user: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'User'
//     },
//     emoji: String,
//     addedAt: {
//       type: Date,
//       default: Date.now
//     }
//   }],
//   createdAt: {
//     type: Date,
//     default: Date.now,
//     index: true  // For faster queries
//   }
// }, {
//   timestamps: true
// });

// // 4. Media Model - Stores media file references
// const MediaSchema = new mongoose.Schema({
//   messageId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Message',
//     required: true
//   },
//   chatId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Chat',
//     required: true
//   },
//   type: {
//     type: String,
//     enum: ['image', 'video', 'audio', 'document'],
//     required: true
//   },
//   url: {
//     type: String,
//     required: true
//   },
//   thumbnail: String,
//   mimeType: String,
//   fileName: String,
//   fileSize: Number,
//   duration: Number,  // For audio/video
//   dimensions: {
//     width: Number,
//     height: Number
//   },
//   uploadedBy: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   }
// });

// // Create indexes for better query performance
// ChatSchema.index({ participants: 1 });
// ChatSchema.index({ updatedAt: -1 });
// MessageSchema.index({ chatId: 1, createdAt: -1 });
// MessageSchema.index({ sender: 1 });
// MediaSchema.index({ messageId: 1 });
// MediaSchema.index({ chatId: 1, type: 1 });






// // Socket.IO handlers
// io.on('connection', (socket) => {
//     socket.on('init', async (userId) => {
//         clients[userId] = socket;
        
//         // Update user online status
//         await User.findByIdAndUpdate(userId, {
//             isOnline: true,
//             lastSeen: new Date()
//         });

//         // Notify user's contacts
//         const userChats = await Chat.find({ participants: userId });
//         userChats.forEach(chat => {
//             const otherParticipant = chat.participants.find(p => p.toString() !== userId.toString());
//             if (clients[otherParticipant]) {
//                 clients[otherParticipant].emit('user_online', userId);
//             }
//         });
//     });

//     socket.on('typing', async (data) => {
//         const { chatId, userId } = data;
//         const chat = await Chat.findById(chatId);
//         if (chat) {
//             chat.participants.forEach(participantId => {
//                 if (participantId.toString() !== userId.toString() && clients[participantId]) {
//                     clients[participantId].emit('typing_status', {
//                         chatId,
//                         userId,
//                         isTyping: true
//                     });
//                 }
//             });
//         }
//     });

//     socket.on('disconnect', async () => {
//         const userId = Object.keys(clients).find(key => clients[key] === socket);
//         if (userId) {
//             delete clients[userId];
            
//             // Update user status
//             await User.findByIdAndUpdate(userId, {
//                 isOnline: false,
//                 lastSeen: new Date()
//             });

//             // Notify user's contacts
//             const userChats = await Chat.find({ participants: userId });
//             userChats.forEach(chat => {
//                 const otherParticipant = chat.participants.find(p => p.toString() !== userId.toString());
//                 if (clients[otherParticipant]) {
//                     clients[otherParticipant].emit('user_offline', {
//                         userId,
//                         lastSeen: new Date()
//                     });
//                 }
//             });
//         }
//     });
// });









import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social/model/chatData.dart';
import 'package:social/model/message.dart';
import 'package:social/screens/chat/chat_screen.dart';

class ChatDataDisplayWidget extends StatefulWidget {
  @override
  _ChatDataDisplayWidgetState createState() => _ChatDataDisplayWidgetState();
}

class _ChatDataDisplayWidgetState extends State<ChatDataDisplayWidget> {
  List<ChatData> _chatDataList = [];

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    final box = await Hive.openBox<ChatData>('chatData');
    
    setState(() {
      // Convert all values in the box to a list
      _chatDataList = box.values.toList();
    });

    // Optional: Close the box when done
    await box.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Chat Data'),
      ),
      body: _chatDataList.isEmpty
          ? Center(child: Text('No chat data found'))
          : ListView.builder(
              itemCount: _chatDataList.length,
              itemBuilder: (context, index) {
                final chatData = _chatDataList[index];
                return ListTile(
                  title: Text('Chat ID: ${chatData.chatId}'),
                  subtitle: Text('Receiver ID: ${chatData.receiverId}'),
                );
              },
            ),
    );
  }
}





// class ChatDataScreen extends StatefulWidget {
//   final String chatId;

//   const ChatDataScreen({Key? key, required this.chatId}) : super(key: key);

//   @override
//   _ChatDataScreenState createState() => _ChatDataScreenState();
// }

// class _ChatDataScreenState extends State<ChatDataScreen> {
//   late Box<Message> messagesBox;

//   @override
//   void initState() {
//     super.initState();
//     // Open the Hive box for messages
//     messagesBox = Hive.box<Message>('messages');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat Messages'),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: messagesBox.listenable(),
//         builder: (context, Box<Message> box, _) {
//           // Filter messages for the current chat
//           final messages = box.values
//               .where((message) => message.chatId == widget.chatId)
//               .toList();

//           if (messages.isEmpty) {
//             return Center(
//               child: Text('No messages found.'),
//             );
//           }

//           return ListView.builder(
//             padding: EdgeInsets.all(8.0),
//             itemCount: messages.length,
//             itemBuilder: (context, index) {
//               final message = messages[index];
//               return MessageBubble(message: message);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final Message message;

//   const MessageBubble({Key? key, required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 4.0),
//       padding: EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: message.senderId == 'currentUserId' ? Colors.blue[100] : Colors.grey[200],
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             message.senderId,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 4.0),
//           if (message.type == MessageType.text)
//             Text(message.content.text ?? ''),
//           if (message.type == MessageType.image)
//             Image.network(message.content.mediaUrl ?? ''),
//           if (message.type == MessageType.video)
//             Text('Video: ${message.content.mediaUrl}'),
//           if (message.type == MessageType.audio)
//             Text('Audio: ${message.content.duration} seconds'),
//           SizedBox(height: 4.0),
//           Text(
//             '${message.createdAt.toLocal()}',
//             style: TextStyle(fontSize: 12.0, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }



class ChatDataScreen extends StatefulWidget {
  final String chatId;

  const ChatDataScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _ChatDataScreenState createState() => _ChatDataScreenState();
}

class _ChatDataScreenState extends State<ChatDataScreen> {
  late Box<Message> messagesBox;

  @override
  void initState() {
    super.initState();
    // Open the Hive box for messages
    messagesBox = Hive.box<Message>('messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Messages'),
      ),
      body: ValueListenableBuilder(
        valueListenable: messagesBox.listenable(),
        builder: (context, Box<Message> box, _) {
          // Filter messages for the current chat
          final messages = box.values
              .where((message) => message.chatId == widget.chatId)
              .toList();

          if (messages.isEmpty) {
            return Center(
              child: Text('No messages found.'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return MessageBubble(message: message);
            },
          );
        },
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: message.senderId == 'currentUserId' ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.senderId,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          // Display message ID
          Text(
            'Message ID: ${message.messageId}',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          SizedBox(height: 4.0),
          Text(
            'reply To: ${message.replyTo}',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          SizedBox(height: 4.0),
          if (message.type == MessageType.text)
            Text(message.content.text ?? ''),
          if (message.type == MessageType.image)
            Image.network(message.content.mediaUrl ?? ''),
          if (message.type == MessageType.video)
            Text('Video: ${message.content.mediaUrl}'),
          if (message.type == MessageType.audio)
            Text('Audio: ${message.content.duration} seconds'),
          SizedBox(height: 4.0),
          Text(
            '${message.createdAt.toLocal()}',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
