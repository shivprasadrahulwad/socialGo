import 'dart:convert';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social/call/voice_call_screen.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/constants/utils.dart';
import 'package:social/model/chat.dart';
import 'package:social/model/message.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/chat/camera_view_screen.dart';
import 'package:social/call/video_call_screen.dart';
import 'package:social/screens/chat/chatInputField_widget.dart';
import 'package:social/screens/chat/chat_attachment_menu_widget.dart';
import 'package:social/screens/chat/message_cache.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:social/model/chatModel.dart';
import 'package:social/screens/chat/camera_screen.dart';
import 'package:social/screens/chat/own_messge_card.dart';
import 'package:social/screens/chat/reply_message_card.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String reciverId;
  final String sourchat;
  final String chatId;

  ChatScreen({
    Key? key,
    required this.reciverId,
    required this.sourchat,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  late IO.Socket socket;
  ImagePicker _picker = ImagePicker();
  late XFile file;
  bool sendButton = false;
  List<Message> messages = [];
  int popTime = 0;
  String BASE_URL = "http://192.168.2.140:5000";
  String? result;
  final ChatServices chatServices = ChatServices();
  late String userId;
  bool _isLoading = false;
  bool hasMore = true;
  bool _showAttachments = false;
  int currentPage = 1;
  final MessageCache _messageCache = MessageCache();
  static const int _messagesPerPage = 30;
  final chatService = ChatServices();
  late String fetchedChatId;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    connect();
    final participantId = widget.reciverId;
    _createOrGetChat(participantId);
    _loadInitialMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _messageController.dispose();
    socket.disconnect();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      FocusScope.of(context).requestFocus(FocusNode());
    } else {
      FocusScope.of(context).unfocus();
    }

    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  void connect() {
    socket = IO.io(BASE_URL, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.onConnect((data) => print('connected'));
    socket.emit("signin", widget.sourchat);

    socket.onConnect((data) {
      print("Connected");

      // Listen for new messages
      socket.on("message", (msg) {
        print(msg);
        setMessage("destination", msg["message"], msg['path']);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });

      // Listen for read receipts
      socket.on("message_read_receipt", (data) {
        // _updateMessageReadStatus(data['messageId'], data['readAt']);
      });
    });
    print(socket.connected);
  }

  Future<void> _createOrGetChat(String participantId) async {
    try {
      final chat = await chatService.createOrGetChat(
        context: context,
        participantId: participantId,
      );

      setState(() {
        // Handle chat (e.g., navigate to chat screen or update UI)
        fetchedChatId = chat!.id;
        print('Chat ID: ${chat?.id}');
      });
    } catch (e) {
      // Handle error appropriately
      print("Error: $e");
    }
  }

  Future<void> _loadInitialMessages() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final messages = await chatService.getChatMessages(
        context: context,
        chatId: widget.chatId,
        page: 1,
        limit: _messagesPerPage,
      );

      setState(() {
        _messageCache.cacheMessages(
          widget.chatId,
          messages,
          messages.length == _messagesPerPage,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || !_messageCache.hasMore(widget.chatId)) return;

    setState(() => _isLoading = true);
    _messageCache.incrementPage(widget.chatId);

    try {
      final messages = await chatService.getChatMessages(
        context: context,
        chatId: widget.chatId,
        page: _messageCache.getCurrentPage(widget.chatId),
        limit: _messagesPerPage,
      );

      setState(() {
        _messageCache.cacheMessages(
          widget.chatId,
          messages,
          messages.length == _messagesPerPage,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more messages: $e')),
        );
      }
    }
  }

  Future<void> _refreshMessages() async {
    _messageCache.clear(widget.chatId);
    await _loadInitialMessages();
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final currentText = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;

    if (cursorPosition >= 0) {
      final newText = currentText.substring(0, cursorPosition) +
          emoji.emoji +
          currentText.substring(cursorPosition);
      _messageController.text = newText;
      _messageController.selection = TextSelection.collapsed(
        offset: cursorPosition + emoji.emoji.length,
      );
    } else {
      _messageController.text = currentText + emoji.emoji;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage(
      String message, String sourceId, String targetId, String path) async {
    if (message.trim().isEmpty && path.isEmpty) return;

    try {
      MessageType messageType =
          path.isNotEmpty ? MessageType.image : MessageType.text;
      String content = path.isNotEmpty ? path : message;

      // Prepare media-related data if needed
      String? fileName;
      int? fileSize;
      String? thumbnail;
      int? duration;

      if (path.isNotEmpty) {
        File mediaFile = File(path);
        fileName = path.split('/').last;
        fileSize = await mediaFile.length();

        if (messageType == MessageType.video) {
          // Get video duration if it's a video file
          // You'll need to implement this based on your video handling logic
          duration = 0; // Replace with actual duration
          // Generate thumbnail for video
          thumbnail = ''; // Replace with actual thumbnail generation
        }
      }

      // Send message to database
      final Message? savedMessage = await chatServices.sendMessages(
        context: context,
        chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
        content: content,
        messageType: messageType,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
        thumbnail: thumbnail,
        senderId: sourceId,
        messageId: '',
      );

      if (savedMessage != null) {
        // Emit message through socket for real-time communication
        socket.emit("message", {
          "message": message,
          "sourceId": sourceId,
          "targetId": targetId,
          "path": path,
          "messageId": savedMessage.chatId,
        });

        // Update local state
        setState(() {
          messages.add(savedMessage);
          sendButton = false;
        });

        _messageController.clear();
        // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      CustomSnackBar.show(context, 'Failed to send message');
    }
  }

  void setMessage(String type, String message, String path,
      {String? messageId}) {
    String fullPath = '';
    if (path.isNotEmpty) {
      fullPath = path.startsWith('http') ? path : '$BASE_URL/uploads/$path';
    }

    MessageType messageType =
        path.isNotEmpty ? MessageType.image : MessageType.text;

    // Determine the correct sender ID based on the message type
    String senderId;
    if (type == "source") {
      senderId = widget.sourchat; // Current user is sender
    } else if (type == "destination") {
      senderId = widget.reciverId; // Other user is sender
    } else {
      throw ArgumentError('Invalid message type');
    }

    Message newMessage = Message(
      chatId: widget.chatId,
      senderId: senderId,
      type: messageType,
      content: MessageContent(
        text: messageType == MessageType.text ? message : null,
        mediaUrl: messageType != MessageType.text ? fullPath : null,
        fileName: path.isNotEmpty ? path.split('/').last : null,
        fileSize: null,
        duration: null,
        contactInfo: null,
      ),
      replyTo: null,
      forwardedFrom: null,
      readBy: [],
      deliveredTo: [],
      status:
          type == "source" ? MessageStatus.sending : MessageStatus.delivered,
      createdAt: DateTime.now(),
      reactions: [],
      isDeleted: false,
      deletedFor: [],
      messageId: messageId ?? '',
    );

    setState(() {
      messages.add(newMessage);
    });

    // Auto-scroll to bottom when new message is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final messages = _messageCache.getCachedMessages(
      widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
    );
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAttachments = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: const BoxDecoration(
                    color: Colors.amberAccent, shape: BoxShape.circle),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.reciverId}',
                        style: const TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 14,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  const Text(
                    'shivprasad_rahulwad',
                    style: TextStyle(
                        fontFamily: 'Medium',
                        fontSize: 12,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshMessages,
          child: 
          Stack(
            children: [
              SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: GlobalVariables.backgroundColor,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      controller: _scrollController,
                      itemCount: messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          // return Container(height: 70);
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final message = messages[index];
                        final isCurrentUser =
                            message.senderId == widget.sourchat;

                        return Column(
                          children: [
                            SizedBox(height: 20),
                            if (isCurrentUser)
                              OwnMessageCard(
                                message: message.content.text ?? '',
                                time: message.createdAt.toString(),
                                isRead: message.status == MessageStatus.read,
                              )
                            else
                              ReplyMessageCard(
                                message: message.content.text ?? '',
                                time: message.createdAt.toString(),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // In your chat screen
                  //     if (_showAttachments)
                  // Positioned(
                  //   bottom: 80, // Adjust this value based on your ChatInputWidget height
                  //   child: ChatAttachmentMenuWidget(
                  //     onClose: () {
                  //       setState(() {
                  //         _showAttachments = false;
                  //       });
                  //     },
                  //   ),
                  // ),

                  ChatInputWidget(
                    onSendMessage: sendMessage,
                    sourchat: widget.sourchat,
                    receiverId: widget.reciverId,
                    scrollController: _scrollController,
                    onAttachmentPressed: () {
                      setState(() {
                        _showAttachments = true;
                      });
                    },
                  ),

                  // Emoji picker section (conditionally visible)
                  // if (_showEmojiPicker)
                  //   SizedBox(
                  //     height: 300,
                  //     child: EmojiPicker(
                  //       onEmojiSelected: (Category? category, Emoji emoji) {
                  //         _onEmojiSelected(category, emoji);
                  //       },
                  //       config: Config(
                  //         columns: 7,
                  //         emojiSizeMax: 32 *
                  //             (foundation.defaultTargetPlatform ==
                  //                     TargetPlatform.iOS
                  //                 ? 1.30
                  //                 : 1.0),
                  //         verticalSpacing: 0,
                  //         horizontalSpacing: 0,
                  //         gridPadding: EdgeInsets.zero,
                  //         initCategory: Category.SMILEYS,
                  //         bgColor: Colors.white,
                  //         indicatorColor: Colors.blue,
                  //         iconColor: Colors.grey,
                  //         iconColorSelected: Colors.blue,
                  //         backspaceColor: Colors.blue,
                  //         // showRecentsTab: true,
                  //         recentsLimit: 28,
                  //         replaceEmojiOnLimitExceed: false,
                  //         noRecents: const Text(
                  //           'No Recent Emojis',
                  //           style:
                  //               TextStyle(fontSize: 20, color: Colors.black26),
                  //           textAlign: TextAlign.center,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
                                if (_showAttachments)
                  Positioned(
                    bottom: 80, // Adjust this value based on your ChatInputWidget height
                    child: ChatAttachmentMenuWidget(
                      onClose: () {
                        setState(() {
                          _showAttachments = false;
                        });
                      },
                    ),
                  ),
            ],
          )
        ),
      ),
    );
  }
}
































// class ChatScreen extends StatefulWidget {
//   final ChatModel chatModel;
//   final ChatModel sourchat;

//   ChatScreen({
//     Key? key,
//     required this.chatModel,
//     required this.sourchat,
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//   bool _showEmojiPicker = false;
//   late IO.Socket socket;
//   ImagePicker _picker = ImagePicker();
//   late XFile file;
//   bool sendButton = false;
//   List<Message> messages = [];
//   int popTime = 0;
//   String BASE_URL = "http://192.168.1.200:5000";
//   String? result;
//   final ChatServices chatServices = ChatServices();

//   @override
//   void initState() {
//     super.initState();
//     connect();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _markMessagesAsRead();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageController.dispose();
//     socket.disconnect();
//     super.dispose();
//   }

//   void _toggleEmojiPicker() {
//     if (_showEmojiPicker) {
//       FocusScope.of(context).requestFocus(FocusNode());
//     } else {
//       FocusScope.of(context).unfocus();
//     }

//     setState(() {
//       _showEmojiPicker = !_showEmojiPicker;
//     });
//   }

//   void connect() {
//     socket = IO.io(BASE_URL, <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });
//     socket.connect();
//     socket.onConnect((data) => print('connected'));
//     socket.emit("signin", widget.sourchat.id);
    
//     socket.onConnect((data) {
//       print("Connected");
      
//       // Listen for new messages
//       socket.on("message", (msg) {
//         print(msg);
//         setMessage("destination", msg["message"], msg['path']);
//         _markMessageAsRead(msg['messageId']);
//         _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//       });
      
//       // Listen for read receipts
//       socket.on("message_read_receipt", (data) {
//         // _updateMessageReadStatus(data['messageId'], data['readAt']);
//       });
//     });
//     print(socket.connected);
//   }



//   void _markMessageAsRead(String messageId) {
//     socket.emit("message_read", {
//       "messageId": messageId,
//       "sourceId": widget.chatModel.id,  // Original sender
//       "targetId": widget.sourchat.id,   // Current user (reader)
//     });
//   }

//  void _markMessagesAsRead() {
//     // Mark all unread received messages as read
//     for (var message in messages) {
//       if (message.messageType == "destination" && message.status != 'read') {
//         _markMessageAsRead(message.messageId);
//       }
//     }
//   }



//   void _onEmojiSelected(Category? category, Emoji emoji) {
//     final currentText = _messageController.text;
//     final cursorPosition = _messageController.selection.baseOffset;

//     if (cursorPosition >= 0) {
//       final newText = currentText.substring(0, cursorPosition) +
//           emoji.emoji +
//           currentText.substring(cursorPosition);
//       _messageController.text = newText;
//       _messageController.selection = TextSelection.collapsed(
//         offset: cursorPosition + emoji.emoji.length,
//       );
//     } else {
//       _messageController.text = currentText + emoji.emoji;
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   void sendMessage(String message, int sourceId, int targetId, String path) {
//     if (message.trim().isEmpty) return;

//     String messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
//     setMessage("source", message, path, messageId: messageId);
//     socket.emit("message", {
//       "message": message,
//       "sourceId": sourceId,
//       "targetId": targetId,
//       "path": path,
//       "messageId": messageId,
//     });

//     chatServices.sendMessages(
//     context,
//     '1234',
//     message,
//     messageType: path.isNotEmpty ? 'image' : 'text',
//   );
//     _messageController.clear();
//     setState(() {
//       sendButton = false;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//   }


//   void setMessage(String type, String message, String path, {String? messageId}) {
//     String fullPath = '';
//     if (path.isNotEmpty) {
//       fullPath = path.startsWith('http') ? path : '$BASE_URL/uploads/$path';
//     }

//      Message newMessage = Message(
//       chatId: widget.chatModel.id.toString(),
//       sender: type == 'source' ? widget.sourchat.id.toString() : widget.chatModel.id.toString(),
//       messageId: messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       messageType: type,
//       content: MessageContent(text: message, mediaUrl: '', fileName: '', fileSize: 0, duration: 0),  // Example of using content, adapt as needed
//       quotedMessage: QuotedMessage(),
//       readBy: [],
//       deliveredTo: [],
//       status: 'sent',  // Initially, status is 'sent'
//       deletedFor: [],
//       reactions: [],
//       createdAt: DateTime.now(),
//     );

//     setState(() {
//       messages.add(newMessage);
//     });
//   }

//   void onImageSend(String path) async {
//     print('Sending image with path: $path');

//     for (int i = 0; i < popTime; i++) {
//       Navigator.pop(context);
//     }

//     setState(() {
//       popTime = 0;
//     });

//     try {
//       var request =
//           http.MultipartRequest("POST", Uri.parse('$BASE_URL/routes/addimage'));
//       request.files.add(await http.MultipartFile.fromPath('img', path));
//       request.headers.addAll({
//         "Content-type": "multipart/form-data",
//       });

//       http.StreamedResponse response = await request.send();
//       var httpResponse = await http.Response.fromStream(response);

//       if (httpResponse.statusCode == 200) {
//         var data = json.decode(httpResponse.body);
//         String filename = data['path'];

//         print('Server returned filename: $filename');

//         // Send just the filename in the socket message
//         setMessage("source", "", filename);
//         socket.emit("message", {
//           "sourceId": widget.sourchat.id,
//           "targetId": widget.chatModel.id,
//           "message": "",
//           "path": filename,
//         });
//       } else {
//         print('Failed to upload image: ${httpResponse.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload image')),
//         );
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error uploading image')),
//       );
//     }
//   }

//   Widget _buildMessageStatus(Message message) {
//     if (message.messageType != "source") return Container();
    
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           message.createdAt.toString(),
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         SizedBox(width: 4),
//         // Icon(
//         //   message.isRead ? Icons.done_all : Icons.done,
//         //   size: 16,
//         //   color: message.isRead ? Colors.blue : Colors.grey[600],
//         // ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Container(
//               height: 35,
//               width: 35,
//               decoration: const BoxDecoration(
//                   color: Colors.amberAccent, shape: BoxShape.circle),
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${widget.chatModel.name}',
//                       style: const TextStyle(
//                           fontFamily: 'Medium',
//                           fontSize: 14,
//                           color: Colors.black),
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 15,
//                       color: Colors.grey,
//                     )
//                   ],
//                 ),
//                 const Text(
//                   'shivprasad_rahulwad',
//                   style: TextStyle(
//                       fontFamily: 'Medium', fontSize: 12, color: Colors.black),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               try {
//                 setMessage("source", "Voice call started", "");

//                 socket.emit("message", {
//                   "sourceId": widget.sourchat.id,
//                   "targetId": widget.chatModel.id,
//                   "message": "Voice call started",
//                   "path": "",
//                 });

//                 final duration = await Navigator.push<String>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VoiceCallScreen(
//                       channelName: '1234',
//                       appId: '20810c5544884126b8ffbbe4e0453736',
//                       callerName: widget.chatModel.name,
//                       callerAvatar: 'assets/images/shrutika.png',
//                     ),
//                   ),
//                 );
//               } catch (e) {
//                 print('Error handling voice call: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Error occurred during voice call')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.call),
//           ),
//           IconButton(
//             onPressed: () async {
//               try {
//                 // Send initial video call message
//                 setMessage("source", "Video call started", "");

//                 socket.emit("message", {
//                   "sourceId": widget.sourchat.id,
//                   "targetId": widget.chatModel.id,
//                   "message": "Video call started",
//                   "path": "",
//                 });

//                 final duration = await Navigator.push<String>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VideoCallScreen(
//                       channelName: '1234',
//                       callerName: widget.chatModel.name,
//                     ),
//                   ),
//                 );
//               } catch (e) {
//                 print('Error handling video call: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Error occurred during video call')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.video_call),
//           ),
//         ],
//       ),
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Container(
//           color: GlobalVariables.backgroundColor,
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   controller: _scrollController,
//                   itemCount: messages.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == messages.length) {
//                       return Container(
//                         height: 70,
//                       );
//                     }
//                     return Column(
//                       children: [
//                         SizedBox(height: 20),

//                         // Source section
//                         if (messages[index].messageType == "source") ...[
//                             OwnMessageCard(
//                               message: messages[index].content.text,
//                               time: messages[index].createdAt.toString(), isRead: messages[index].status == 'read',
//                             ),
//                         ],

//                         // Replay section
//                         if (messages[index].messageType != "source") ...[
                      
//                             ReplyMessageCard(
//                               message: messages[index].content.text,
//                               time: messages[index].createdAt.toString(),
//                             ),
//                         ],
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: Colors.amberAccent,
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _messageController,
//                         maxLines: 5,
//                         textAlignVertical: TextAlignVertical.center,
//                         keyboardType: TextInputType.multiline,
//                         minLines: 1,
//                         focusNode: FocusNode()
//                           ..addListener(() {
//                             if (FocusScope.of(context).hasFocus) {
//                               setState(() {
//                                 _showEmojiPicker = false;
//                               });
//                             }
//                           }),
//                         onChanged: (value) {
//                           if (value.length > 0) {
//                             setState(() {
//                               sendButton = true;
//                             });
//                           } else {
//                             setState(() {
//                               sendButton = false;
//                             });
//                           }
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Message...',
//                           border: InputBorder.none,
//                           prefixIcon: IconButton(
//                             onPressed: _toggleEmojiPicker,
//                             icon: Icon(
//                               _showEmojiPicker
//                                   ? Icons.keyboard
//                                   : Icons.emoji_emotions,
//                             ),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     popTime = 2;
//                                   });
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => CameraScreen(
//                                         onImageSend: onImageSend,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 icon: const Icon(Icons.camera),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   if (sendButton) {
//                                     _scrollController.animateTo(
//                                         _scrollController
//                                             .position.maxScrollExtent,
//                                         duration:
//                                             const Duration(milliseconds: 300),
//                                         curve: Curves.easeOut);
//                                     sendMessage(
//                                         _messageController.text,
//                                         widget.sourchat.id,
//                                         widget.chatModel.id,
//                                         "");
//                                     _messageController.clear();
//                                     setState(() {
//                                       sendButton = false;
//                                     });
//                                   }
//                                 },
//                                 icon: const Icon(Icons.attach_file),
//                               ),
//                               IconButton(
//                                 onPressed: () async {
//                                   setState(() {
//                                     popTime = 1;
//                                   });
//                                   file = (await _picker.pickImage(
//                                       source: ImageSource.gallery))!;
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (builder) => CameraViewPage(
//                                                 path: file.path,
//                                                 onImageSend: onImageSend,
//                                               )));
//                                 },
//                                 icon: const Icon(Icons.browse_gallery),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         bottom: 8,
//                         right: 2,
//                         left: 2,
//                       ),
//                       child: CircleAvatar(
//                         radius: 25,
//                         backgroundColor: const Color(0xFF128C7E),
//                         child: IconButton(
//                           icon: Icon(
//                             sendButton ? Icons.send : Icons.mic,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             print('send message button');
//                             if (sendButton) {
//                               _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOut);
//                               sendMessage(_messageController.text,
//                                   widget.sourchat.id, widget.chatModel.id, "");
//                               _messageController.clear();
//                               setState(() {
//                                 sendButton = false;
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Emoji picker section (conditionally visible)
//               if (_showEmojiPicker)
//                 SizedBox(
//                   height: 300,
//                   child: EmojiPicker(
//                     onEmojiSelected: (Category? category, Emoji emoji) {
//                       _onEmojiSelected(category, emoji);
//                     },
//                     config: Config(
//                       columns: 7,
//                       emojiSizeMax: 32 *
//                           (foundation.defaultTargetPlatform ==
//                                   TargetPlatform.iOS
//                               ? 1.30
//                               : 1.0),
//                       verticalSpacing: 0,
//                       horizontalSpacing: 0,
//                       gridPadding: EdgeInsets.zero,
//                       initCategory: Category.SMILEYS,
//                       bgColor: Colors.white,
//                       indicatorColor: Colors.blue,
//                       iconColor: Colors.grey,
//                       iconColorSelected: Colors.blue,
//                       backspaceColor: Colors.blue,
//                       // showRecentsTab: true,
//                       recentsLimit: 28,
//                       replaceEmojiOnLimitExceed: false,
//                       noRecents: const Text(
//                         'No Recent Emojis',
//                         style: TextStyle(fontSize: 20, color: Colors.black26),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












// class ChatScreen extends StatefulWidget {
//   final ChatModel chatModel;
//   final ChatModel sourchat;

//   ChatScreen({
//     Key? key,
//     required this.chatModel,
//     required this.sourchat,
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//   bool _showEmojiPicker = false;
//   late IO.Socket socket;
//   ImagePicker _picker = ImagePicker();
//   late XFile file;
//   bool sendButton = false;
//   List<Message> messages = [];
//   int popTime = 0;
//   String BASE_URL = "http://192.168.1.109:5000";
//   String? result;
//   final ChatServices chatServices = ChatServices();

//   @override
//   void initState() {
//     super.initState();
//     connect();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _markMessagesAsRead();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageController.dispose();
//     socket.disconnect();
//     super.dispose();
//   }

//   void _toggleEmojiPicker() {
//     if (_showEmojiPicker) {
//       FocusScope.of(context).requestFocus(FocusNode());
//     } else {
//       FocusScope.of(context).unfocus();
//     }

//     setState(() {
//       _showEmojiPicker = !_showEmojiPicker;
//     });
//   }

//   void connect() {
//     socket = IO.io(BASE_URL, <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });
//     socket.connect();
//     socket.onConnect((data) => print('connected'));
//     socket.emit("signin", widget.sourchat.id);
    
//     socket.onConnect((data) {
//       print("Connected");
      
//       // Listen for new messages
//       socket.on("message", (msg) {
//         print(msg);
//         setMessage("destination", msg["message"], msg['path']);
//         _markMessageAsRead(msg['messageId']);
//         _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//       });
      
//       // Listen for read receipts
//       socket.on("message_read_receipt", (data) {
//         // _updateMessageReadStatus(data['messageId'], data['readAt']);
//       });
//     });
//     print(socket.connected);
//   }



//   void _markMessageAsRead(String messageId) {
//     socket.emit("message_read", {
//       "messageId": messageId,
//       "sourceId": widget.chatModel.id,  // Original sender
//       "targetId": widget.sourchat.id,   // Current user (reader)
//     });
//   }

//  void _markMessagesAsRead() {
//     // Mark all unread received messages as read
//     for (var message in messages) {
//       if (message.messageType == "destination" && message.status != 'read') {
//         _markMessageAsRead(message.messageId);
//       }
//     }
//   }



//   void _onEmojiSelected(Category? category, Emoji emoji) {
//     final currentText = _messageController.text;
//     final cursorPosition = _messageController.selection.baseOffset;

//     if (cursorPosition >= 0) {
//       final newText = currentText.substring(0, cursorPosition) +
//           emoji.emoji +
//           currentText.substring(cursorPosition);
//       _messageController.text = newText;
//       _messageController.selection = TextSelection.collapsed(
//         offset: cursorPosition + emoji.emoji.length,
//       );
//     } else {
//       _messageController.text = currentText + emoji.emoji;
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   void sendMessage(String message, int sourceId, int targetId, String path) {
//     if (message.trim().isEmpty) return;

//     String messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
//     setMessage("source", message, path, messageId: messageId);
//     socket.emit("message", {
//       "message": message,
//       "sourceId": sourceId,
//       "targetId": targetId,
//       "path": path,
//       "messageId": messageId,
//     });

//     chatServices.sendMessages(
//     context,
//     '1234',
//     message,
//     messageType: path.isNotEmpty ? 'image' : 'text',
//   );
//     _messageController.clear();
//     setState(() {
//       sendButton = false;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//   }


//   void setMessage(String type, String message, String path, {String? messageId}) {
//     String fullPath = '';
//     if (path.isNotEmpty) {
//       fullPath = path.startsWith('http') ? path : '$BASE_URL/uploads/$path';
//     }

//      Message newMessage = Message(
//       chatId: widget.chatModel.id.toString(),
//       sender: type == 'source' ? widget.sourchat.id.toString() : widget.chatModel.id.toString(),
//       messageId: messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       messageType: type,
//       content: MessageContent(text: message, mediaUrl: '', fileName: '', fileSize: 0, duration: 0),  // Example of using content, adapt as needed
//       quotedMessage: QuotedMessage(),
//       readBy: [],
//       deliveredTo: [],
//       status: 'sent',  // Initially, status is 'sent'
//       deletedFor: [],
//       reactions: [],
//       createdAt: DateTime.now(),
//     );

//     setState(() {
//       messages.add(newMessage);
//     });
//   }

//   void onImageSend(String path) async {
//     print('Sending image with path: $path');

//     for (int i = 0; i < popTime; i++) {
//       Navigator.pop(context);
//     }

//     setState(() {
//       popTime = 0;
//     });

//     try {
//       var request =
//           http.MultipartRequest("POST", Uri.parse('$BASE_URL/routes/addimage'));
//       request.files.add(await http.MultipartFile.fromPath('img', path));
//       request.headers.addAll({
//         "Content-type": "multipart/form-data",
//       });

//       http.StreamedResponse response = await request.send();
//       var httpResponse = await http.Response.fromStream(response);

//       if (httpResponse.statusCode == 200) {
//         var data = json.decode(httpResponse.body);
//         String filename = data['path'];

//         print('Server returned filename: $filename');

//         // Send just the filename in the socket message
//         setMessage("source", "", filename);
//         socket.emit("message", {
//           "sourceId": widget.sourchat.id,
//           "targetId": widget.chatModel.id,
//           "message": "",
//           "path": filename,
//         });
//       } else {
//         print('Failed to upload image: ${httpResponse.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload image')),
//         );
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error uploading image')),
//       );
//     }
//   }

//   Widget _buildMessageStatus(Message message) {
//     if (message.messageType != "source") return Container();
    
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           message.createdAt.toString(),
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         SizedBox(width: 4),
//         // Icon(
//         //   message.isRead ? Icons.done_all : Icons.done,
//         //   size: 16,
//         //   color: message.isRead ? Colors.blue : Colors.grey[600],
//         // ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Container(
//               height: 35,
//               width: 35,
//               decoration: const BoxDecoration(
//                   color: Colors.amberAccent, shape: BoxShape.circle),
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${widget.chatModel.name}',
//                       style: const TextStyle(
//                           fontFamily: 'Medium',
//                           fontSize: 14,
//                           color: Colors.black),
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 15,
//                       color: Colors.grey,
//                     )
//                   ],
//                 ),
//                 const Text(
//                   'shivprasad_rahulwad',
//                   style: TextStyle(
//                       fontFamily: 'Medium', fontSize: 12, color: Colors.black),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               try {
//                 setMessage("source", "Voice call started", "");

//                 socket.emit("message", {
//                   "sourceId": widget.sourchat.id,
//                   "targetId": widget.chatModel.id,
//                   "message": "Voice call started",
//                   "path": "",
//                 });

//                 final duration = await Navigator.push<String>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VoiceCallScreen(
//                       channelName: '1234',
//                       appId: '20810c5544884126b8ffbbe4e0453736',
//                       callerName: widget.chatModel.name,
//                       callerAvatar: 'assets/images/shrutika.png',
//                     ),
//                   ),
//                 );
//               } catch (e) {
//                 print('Error handling voice call: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Error occurred during voice call')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.call),
//           ),
//           IconButton(
//             onPressed: () async {
//               try {
//                 // Send initial video call message
//                 setMessage("source", "Video call started", "");

//                 socket.emit("message", {
//                   "sourceId": widget.sourchat.id,
//                   "targetId": widget.chatModel.id,
//                   "message": "Video call started",
//                   "path": "",
//                 });

//                 final duration = await Navigator.push<String>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VideoCallScreen(
//                       channelName: '1234',
//                       callerName: widget.chatModel.name,
//                     ),
//                   ),
//                 );
//               } catch (e) {
//                 print('Error handling video call: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Error occurred during video call')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.video_call),
//           ),
//         ],
//       ),
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Container(
//           color: GlobalVariables.backgroundColor,
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   controller: _scrollController,
//                   itemCount: messages.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == messages.length) {
//                       return Container(
//                         height: 70,
//                       );
//                     }
//                     return Column(
//                       children: [
//                         SizedBox(height: 20),

//                         // Source section
//                         if (messages[index].messageType == "source") ...[
//                             OwnMessageCard(
//                               message: messages[index].content.text,
//                               time: messages[index].createdAt.toString(), isRead: messages[index].status == 'read',
//                             ),
//                         ],

//                         // Replay section
//                         if (messages[index].messageType != "source") ...[
                      
//                             ReplyMessageCard(
//                               message: messages[index].content.text,
//                               time: messages[index].createdAt.toString(),
//                             ),
//                         ],
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: Colors.amberAccent,
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _messageController,
//                         maxLines: 5,
//                         textAlignVertical: TextAlignVertical.center,
//                         keyboardType: TextInputType.multiline,
//                         minLines: 1,
//                         focusNode: FocusNode()
//                           ..addListener(() {
//                             if (FocusScope.of(context).hasFocus) {
//                               setState(() {
//                                 _showEmojiPicker = false;
//                               });
//                             }
//                           }),
//                         onChanged: (value) {
//                           if (value.length > 0) {
//                             setState(() {
//                               sendButton = true;
//                             });
//                           } else {
//                             setState(() {
//                               sendButton = false;
//                             });
//                           }
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Message...',
//                           border: InputBorder.none,
//                           prefixIcon: IconButton(
//                             onPressed: _toggleEmojiPicker,
//                             icon: Icon(
//                               _showEmojiPicker
//                                   ? Icons.keyboard
//                                   : Icons.emoji_emotions,
//                             ),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     popTime = 2;
//                                   });
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => CameraScreen(
//                                         onImageSend: onImageSend,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 icon: const Icon(Icons.camera),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   if (sendButton) {
//                                     _scrollController.animateTo(
//                                         _scrollController
//                                             .position.maxScrollExtent,
//                                         duration:
//                                             const Duration(milliseconds: 300),
//                                         curve: Curves.easeOut);
//                                     sendMessage(
//                                         _messageController.text,
//                                         widget.sourchat.id,
//                                         widget.chatModel.id,
//                                         "");
//                                     _messageController.clear();
//                                     setState(() {
//                                       sendButton = false;
//                                     });
//                                   }
//                                 },
//                                 icon: const Icon(Icons.attach_file),
//                               ),
//                               IconButton(
//                                 onPressed: () async {
//                                   setState(() {
//                                     popTime = 1;
//                                   });
//                                   file = (await _picker.pickImage(
//                                       source: ImageSource.gallery))!;
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (builder) => CameraViewPage(
//                                                 path: file.path,
//                                                 onImageSend: onImageSend,
//                                               )));
//                                 },
//                                 icon: const Icon(Icons.browse_gallery),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         bottom: 8,
//                         right: 2,
//                         left: 2,
//                       ),
//                       child: CircleAvatar(
//                         radius: 25,
//                         backgroundColor: const Color(0xFF128C7E),
//                         child: IconButton(
//                           icon: Icon(
//                             sendButton ? Icons.send : Icons.mic,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             print('send message button');
//                             if (sendButton) {
//                               _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOut);
//                               sendMessage(_messageController.text,
//                                   widget.sourchat.id, widget.chatModel.id, "");
//                               _messageController.clear();
//                               setState(() {
//                                 sendButton = false;
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Emoji picker section (conditionally visible)
//               if (_showEmojiPicker)
//                 SizedBox(
//                   height: 300,
//                   child: EmojiPicker(
//                     onEmojiSelected: (Category? category, Emoji emoji) {
//                       _onEmojiSelected(category, emoji);
//                     },
//                     config: Config(
//                       columns: 7,
//                       emojiSizeMax: 32 *
//                           (foundation.defaultTargetPlatform ==
//                                   TargetPlatform.iOS
//                               ? 1.30
//                               : 1.0),
//                       verticalSpacing: 0,
//                       horizontalSpacing: 0,
//                       gridPadding: EdgeInsets.zero,
//                       initCategory: Category.SMILEYS,
//                       bgColor: Colors.white,
//                       indicatorColor: Colors.blue,
//                       iconColor: Colors.grey,
//                       iconColorSelected: Colors.blue,
//                       backspaceColor: Colors.blue,
//                       // showRecentsTab: true,
//                       recentsLimit: 28,
//                       replaceEmojiOnLimitExceed: false,
//                       noRecents: const Text(
//                         'No Recent Emojis',
//                         style: TextStyle(fontSize: 20, color: Colors.black26),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












// class ChatScreen extends StatefulWidget {
//   final ChatModel chatModel;
//   final ChatModel sourchat;

//   ChatScreen({
//     Key? key,
//     required this.chatModel,
//     required this.sourchat,
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//   bool _showEmojiPicker = false;
//   late IO.Socket socket;
//   ImagePicker _picker = ImagePicker();
//   late XFile file;
//   bool sendButton = false;
//   List<MessageModel> messages = [];
//   int popTime = 0;
//   String BASE_URL = "http://192.168.2.194:5000";
//   String? result;

//   @override
//   void initState() {
//     super.initState();
//     connect();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _markMessagesAsRead();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageController.dispose();
//     socket.disconnect();
//     super.dispose();
//   }

//   void _toggleEmojiPicker() {
//     if (_showEmojiPicker) {
//       // Hide emoji picker and show keyboard
//       FocusScope.of(context).requestFocus(FocusNode());
//     } else {
//       // Hide keyboard and show emoji picker
//       FocusScope.of(context).unfocus();
//     }

//     setState(() {
//       _showEmojiPicker = !_showEmojiPicker;
//     });
//   }

//   // void connect() {
//   //   socket = IO.io(BASE_URL, <String, dynamic>{
//   //     "transports": ["websocket"],
//   //     "autoConnect": false,
//   //   });
//   //   socket.connect();
//   //   socket.onConnect((data) => print('connected'));
//   //   socket.emit("signin", widget.sourchat.id);
//   //   socket.onConnect((data) {
//   //     print("Connected");
//   //     socket.on("message", (msg) {
//   //       print(msg);
//   //       setMessage("destination", msg["message"], msg['path']);
//   //       _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//   //           duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//   //     });
//   //   });
//   //   print(socket.connected);
//   // }

//   void connect() {
//     socket = IO.io(BASE_URL, <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });
//     socket.connect();
//     socket.onConnect((data) => print('connected'));
//     socket.emit("signin", widget.sourchat.id);
    
//     socket.onConnect((data) {
//       print("Connected");
      
//       // Listen for new messages
//       socket.on("message", (msg) {
//         print(msg);
//         setMessage("destination", msg["message"], msg['path']);
//         _markMessageAsRead(msg['messageId']);
//         _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//       });
      
//       // Listen for read receipts
//       socket.on("message_read_receipt", (data) {
//         _updateMessageReadStatus(data['messageId'], data['readAt']);
//       });
//     });
//     print(socket.connected);
//   }



//   void _markMessageAsRead(String messageId) {
//     socket.emit("message_read", {
//       "messageId": messageId,
//       "sourceId": widget.chatModel.id,  // Original sender
//       "targetId": widget.sourchat.id,   // Current user (reader)
//     });
//   }

//   void _markMessagesAsRead() {
//     // Mark all unread received messages as read
//     for (var message in messages) {
//       if (message.type == "destination" && !message.isRead) {
//         _markMessageAsRead(message.messageId);
//       }
//     }
//   }

//   void _updateMessageReadStatus(String messageId, String readAt) {
//     setState(() {
//       for (var message in messages) {
//         if (message.messageId == messageId) {
//           message.isRead = true;
//           message.readAt = readAt;
//           break;
//         }
//       }
//     });
//   }



//   void _onEmojiSelected(Category? category, Emoji emoji) {
//     final currentText = _messageController.text;
//     final cursorPosition = _messageController.selection.baseOffset;

//     if (cursorPosition >= 0) {
//       final newText = currentText.substring(0, cursorPosition) +
//           emoji.emoji +
//           currentText.substring(cursorPosition);
//       _messageController.text = newText;
//       _messageController.selection = TextSelection.collapsed(
//         offset: cursorPosition + emoji.emoji.length,
//       );
//     } else {
//       _messageController.text = currentText + emoji.emoji;
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // void sendMessage(String message, int sourceId, int targetId, String path) {
//   //   if (message.trim().isEmpty) return;

//   //   setMessage("source", message, path);
//   //   socket.emit("message", {
//   //     "message": message,
//   //     "sourceId": sourceId,
//   //     "targetId": targetId,
//   //     "path": path
//   //   });

//   //   _messageController.clear();
//   //   setState(() {
//   //     sendButton = false;
//   //   });

//   //   // Scroll to bottom after message is added
//   //   WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//   // }

//   void sendMessage(String message, int sourceId, int targetId, String path) {
//     if (message.trim().isEmpty) return;

//     String messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
//     setMessage("source", message, path, messageId: messageId);
//     socket.emit("message", {
//       "message": message,
//       "sourceId": sourceId,
//       "targetId": targetId,
//       "path": path,
//       "messageId": messageId,
//     });

//     _messageController.clear();
//     setState(() {
//       sendButton = false;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//   }


//   // void setMessage(String type, String message, String path) {
//   //   // Construct the full image URL
//   //   String fullPath = '';
//   //   if (path.isNotEmpty) {
//   //     if (path.startsWith('http')) {
//   //       fullPath = path;
//   //     } else {
//   //       // Add /uploads/ to the path since that's how the server serves images
//   //       fullPath = '$BASE_URL/uploads/$path';
//   //     }
//   //   }

//   //   MessageModel messageModel = MessageModel(
//   //     type: type,
//   //     message: message,
//   //     time: DateTime.now().toString().substring(10, 16),
//   //     path: fullPath,
//   //   );

//   //   print('Setting message with path: $fullPath'); // Debug print

//   //   setState(() {
//   //     messages.add(messageModel);
//   //   });
//   // }

//   void setMessage(String type, String message, String path, {String? messageId}) {
//     String fullPath = '';
//     if (path.isNotEmpty) {
//       fullPath = path.startsWith('http') ? path : '$BASE_URL/uploads/$path';
//     }

//     MessageModel messageModel = MessageModel(
//       type: type,
//       message: message,
//       time: DateTime.now().toString().substring(10, 16),
//       path: fullPath,
//       messageId: messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//     );

//     setState(() {
//       messages.add(messageModel);
//     });
//   }

//   void onImageSend(String path) async {
//     print('Sending image with path: $path');

//     for (int i = 0; i < popTime; i++) {
//       Navigator.pop(context);
//     }

//     setState(() {
//       popTime = 0;
//     });

//     try {
//       var request =
//           http.MultipartRequest("POST", Uri.parse('$BASE_URL/routes/addimage'));
//       request.files.add(await http.MultipartFile.fromPath('img', path));
//       request.headers.addAll({
//         "Content-type": "multipart/form-data",
//       });

//       http.StreamedResponse response = await request.send();
//       var httpResponse = await http.Response.fromStream(response);

//       if (httpResponse.statusCode == 200) {
//         var data = json.decode(httpResponse.body);
//         String filename = data['path'];

//         print('Server returned filename: $filename');

//         // Send just the filename in the socket message
//         setMessage("source", "", filename);
//         socket.emit("message", {
//           "sourceId": widget.sourchat.id,
//           "targetId": widget.chatModel.id,
//           "message": "",
//           "path": filename,
//         });
//       } else {
//         print('Failed to upload image: ${httpResponse.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload image')),
//         );
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error uploading image')),
//       );
//     }
//   }

//   Widget _buildMessageStatus(MessageModel message) {
//     if (message.type != "source") return Container();
    
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           message.time,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         SizedBox(width: 4),
//         Icon(
//           message.isRead ? Icons.done_all : Icons.done,
//           size: 16,
//           color: message.isRead ? Colors.blue : Colors.grey[600],
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Container(
//               height: 35,
//               width: 35,
//               decoration: const BoxDecoration(
//                   color: Colors.amberAccent, shape: BoxShape.circle),
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${widget.chatModel.name}',
//                       style: const TextStyle(
//                           fontFamily: 'Medium',
//                           fontSize: 14,
//                           color: Colors.black),
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 15,
//                       color: Colors.grey,
//                     )
//                   ],
//                 ),
//                 const Text(
//                   'shivprasad_rahulwad',
//                   style: TextStyle(
//                       fontFamily: 'Medium', fontSize: 12, color: Colors.black),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               try {
//                 setMessage("source", "Voice call started", "");

//                 socket.emit("message", {
//                   "sourceId": widget.sourchat.id,
//                   "targetId": widget.chatModel.id,
//                   "message": "Voice call started",
//                   "path": "",
//                 });

//                 final duration = await Navigator.push<String>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VoiceCallScreen(
//                       channelName: '1234',
//                       appId: '20810c5544884126b8ffbbe4e0453736',
//                       callerName: widget.chatModel.name,
//                       callerAvatar: 'assets/images/shrutika.png',
//                     ),
//                   ),
//                 );

//                 if (duration != null && duration.isNotEmpty) {
//                   setState(() {
//                     MessageModel voiceCallMessage = MessageModel(
//                       type: "source",
//                       message: "Voice call ended",
//                       time: DateTime.now().toString().substring(10, 16),
//                       path: "",
//                       duration: duration, messageId: '1234',
//                     );
//                     messages.add(voiceCallMessage);

//                     socket.emit("message", {
//                       "sourceId": widget.sourchat.id,
//                       "targetId": widget.chatModel.id,
//                       "message": "Voice call ended",
//                       "path": "",
//                       "duration": duration,
//                     });
//                   });
//                 }
//               } catch (e) {
//                 print('Error handling voice call: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Error occurred during voice call')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.call),
//           ),
//           IconButton(
//             onPressed: () async {
//               try {
//                 // Send initial video call message
//                 setMessage("source", "Video call started", "");

//                 socket.emit("message", {
//                   "sourceId": widget.sourchat.id,
//                   "targetId": widget.chatModel.id,
//                   "message": "Video call started",
//                   "path": "",
//                 });

//                 final duration = await Navigator.push<String>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VideoCallScreen(
//                       channelName: '1234',
//                       callerName: widget.chatModel.name,
//                     ),
//                   ),
//                 );

//                 // Only add the end message if we got a valid duration
//                 if (duration != null && duration.isNotEmpty) {
//                   setState(() {
//                     MessageModel videoCallMessage = MessageModel(
//                       type: "source",
//                       message: "Video call ended",
//                       time: DateTime.now().toString().substring(10, 16),
//                       path: "",
//                       duration: duration, messageId: '1234',
//                     );
//                     messages.add(videoCallMessage);

//                     // Also emit the end message to other users
//                     socket.emit("message", {
//                       "sourceId": widget.sourchat.id,
//                       "targetId": widget.chatModel.id,
//                       "message": "Video call ended",
//                       "path": "",
//                       "duration": duration,
//                     });
//                   });
//                 }
//               } catch (e) {
//                 print('Error handling video call: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Error occurred during video call')),
//                 );
//               }
//             },
//             icon: const Icon(Icons.video_call),
//           ),
//         ],
//       ),
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Container(
//           color: GlobalVariables.backgroundColor,
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   controller: _scrollController,
//                   itemCount: messages.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == messages.length) {
//                       return Container(
//                         height: 70,
//                       );
//                     }
//                     return Column(
//                       children: [
//                         SizedBox(height: 20),

//                         // Source section
//                         if (messages[index].type == "source") ...[
//                           if (messages[index].message == "Video call started")
//                             OwnVideoCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Ongoing call',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].message == "Video call ended")
//                             OwnVideoCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Call ended',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].message == "Voice call started")
//                             OwnVoiceCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Ongoing call',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].message == "Voice call ended")
//                             OwnVoiceCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Call ended',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].path.isNotEmpty)
//                             OwnImageCard(
//                               path: messages[index].path,
//                               time: messages[index].time,
//                             )
//                           else
//                             OwnMessageCard(
//                               message: messages[index].message,
//                               time: messages[index].time, isRead: messages[index].isRead,
//                             ),
//                         ],

//                         // Replay section
//                         if (messages[index].type != "source") ...[
//                           if (messages[index].message == "Video call started")
//                             ReplyVideoCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Ongoing call',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].message == "Video call ended")
//                             ReplyVideoCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Call ended',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].message == "Voice call started")
//                             ReplyVoiceCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Ongoing call',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].message == "Voice call ended")
//                             ReplyVoiceCallChatWidget(
//                               duration:
//                                   messages[index].duration ?? 'Call ended',
//                               time: messages[index].time,
//                             ),
//                           if (messages[index].path.isNotEmpty)
//                             ReplyImageCard(
//                               path: messages[index].path,
//                               time: messages[index].time,
//                             )
//                           else
//                             ReplyMessageCard(
//                               message: messages[index].message,
//                               time: messages[index].time,
//                             ),
//                         ],
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: Colors.amberAccent,
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _messageController,
//                         maxLines: 5,
//                         textAlignVertical: TextAlignVertical.center,
//                         keyboardType: TextInputType.multiline,
//                         minLines: 1,
//                         focusNode: FocusNode()
//                           ..addListener(() {
//                             if (FocusScope.of(context).hasFocus) {
//                               setState(() {
//                                 _showEmojiPicker = false;
//                               });
//                             }
//                           }),
//                         onChanged: (value) {
//                           if (value.length > 0) {
//                             setState(() {
//                               sendButton = true;
//                             });
//                           } else {
//                             setState(() {
//                               sendButton = false;
//                             });
//                           }
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Message...',
//                           border: InputBorder.none,
//                           prefixIcon: IconButton(
//                             onPressed: _toggleEmojiPicker,
//                             icon: Icon(
//                               _showEmojiPicker
//                                   ? Icons.keyboard
//                                   : Icons.emoji_emotions,
//                             ),
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     popTime = 2;
//                                   });
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => CameraScreen(
//                                         onImageSend: onImageSend,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 icon: const Icon(Icons.camera),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   if (sendButton) {
//                                     _scrollController.animateTo(
//                                         _scrollController
//                                             .position.maxScrollExtent,
//                                         duration:
//                                             const Duration(milliseconds: 300),
//                                         curve: Curves.easeOut);
//                                     sendMessage(
//                                         _messageController.text,
//                                         widget.sourchat.id,
//                                         widget.chatModel.id,
//                                         "");
//                                     _messageController.clear();
//                                     setState(() {
//                                       sendButton = false;
//                                     });
//                                   }
//                                 },
//                                 icon: const Icon(Icons.attach_file),
//                               ),
//                               IconButton(
//                                 onPressed: () async {
//                                   setState(() {
//                                     popTime = 1;
//                                   });
//                                   file = (await _picker.pickImage(
//                                       source: ImageSource.gallery))!;
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (builder) => CameraViewPage(
//                                                 path: file.path,
//                                                 onImageSend: onImageSend,
//                                               )));
//                                 },
//                                 icon: const Icon(Icons.browse_gallery),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         bottom: 8,
//                         right: 2,
//                         left: 2,
//                       ),
//                       child: CircleAvatar(
//                         radius: 25,
//                         backgroundColor: const Color(0xFF128C7E),
//                         child: IconButton(
//                           icon: Icon(
//                             sendButton ? Icons.send : Icons.mic,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             print('send message button');
//                             if (sendButton) {
//                               _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOut);
//                               sendMessage(_messageController.text,
//                                   widget.sourchat.id, widget.chatModel.id, "");
//                               _messageController.clear();
//                               setState(() {
//                                 sendButton = false;
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Emoji picker section (conditionally visible)
//               if (_showEmojiPicker)
//                 SizedBox(
//                   height: 300,
//                   child: EmojiPicker(
//                     onEmojiSelected: (Category? category, Emoji emoji) {
//                       _onEmojiSelected(category, emoji);
//                     },
//                     config: Config(
//                       columns: 7,
//                       emojiSizeMax: 32 *
//                           (foundation.defaultTargetPlatform ==
//                                   TargetPlatform.iOS
//                               ? 1.30
//                               : 1.0),
//                       verticalSpacing: 0,
//                       horizontalSpacing: 0,
//                       gridPadding: EdgeInsets.zero,
//                       initCategory: Category.SMILEYS,
//                       bgColor: Colors.white,
//                       indicatorColor: Colors.blue,
//                       iconColor: Colors.grey,
//                       iconColorSelected: Colors.blue,
//                       backspaceColor: Colors.blue,
//                       // showRecentsTab: true,
//                       recentsLimit: 28,
//                       replaceEmojiOnLimitExceed: false,
//                       noRecents: const Text(
//                         'No Recent Emojis',
//                         style: TextStyle(fontSize: 20, color: Colors.black26),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
