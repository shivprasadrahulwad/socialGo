import 'dart:convert';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social/call/own_video_call_chat_widget.dart';
import 'package:social/call/own_voice_call_chat_widget.dart';
import 'package:social/call/reply_video_call_chat_widget.dart';
import 'package:social/call/reply_voice_call_chat_widget.dart';
import 'package:social/call/video_call_screen.dart';
import 'package:social/call/voice_call_screen.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/constants/utils.dart';
import 'package:social/home/home_screen.dart';
import 'package:social/model/chatData.dart';
import 'package:social/model/message.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/Home/login_screen.dart';
import 'package:social/screens/chat/chat_input_widget.dart';
import 'package:social/screens/chat/attachment_menu_widget.dart';
import 'package:social/screens/chat/chat_profile_screen.dart';
import 'package:social/screens/chat/chat_screen_action_widget.dart';
import 'package:social/screens/chat/message_cache.dart';
import 'package:social/screens/chat/own_image_card.dart';
import 'package:social/screens/chat/own_video_widget.dart';
import 'package:social/screens/chat/reply_image_card.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:social/screens/chat/own_messge_card.dart';
import 'package:social/screens/chat/reply_message_card.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String reciverId;
  final String sourchat;
  final String chatId;
  final bool hide;
  final String password;
  final bool isUserBlocked;

  ChatScreen({
    Key? key,
    required this.reciverId,
    required this.sourchat,
    required this.chatId,
    required this.hide,
    required this.password,
    required this.isUserBlocked,
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
  String BASE_URL = "http://192.168.1.112:5000";
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
  String? _replyingMessageId;
  String? _replyingMessageContent;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    connect();
    final participantId = widget.reciverId;
    bool hide = true;
    _createOrGetChat(participantId, hide);
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

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); // Format it like: 2025-01-15
  }

  String _truncateMessage(String message, {int maxLength = 20}) {
    return message.length > maxLength
        ? '${message.substring(0, maxLength)}...'
        : message;
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

  // void connect() {
  //   socket = IO.io(BASE_URL, <String, dynamic>{
  //     "transports": ["websocket"],
  //     "autoConnect": false,
  //   });
  //   socket.connect();
  //   socket.onConnect((data) => print('connected'));
  //   socket.emit("signin", widget.sourchat);

  //   socket.onConnect((data) {
  //     print("Connected");

  //     // Listen for new messages
  //     socket.on("message", (msg) {
  //       print(msg);
  //       setMessage("destination", msg["message"], msg['path']);
  //       _scrollController.animateTo(_scrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  //     });

  //     // Listen for read receipts
  //     socket.on("message_read_receipt", (data) {
  //       // _updateMessageReadStatus(data['messageId'], data['readAt']);
  //     });
  //   });
  //   print(socket.connected);
  // }

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

      // Updated message listener to handle ID reconciliation
      // socket.on("message", (msg) async {
      //   print(msg);
      //   final tempMessageId = msg['tempMessageId'];
      //   final permanentMessageId = msg['messageId'];

      //   if (tempMessageId != null) {
      //     final messagesBox = await Hive.openBox<Message>('messages');
      //     final existingMessage = messagesBox.get(tempMessageId);

      //     if (existingMessage != null) {
      //       // Update the message with the permanent ID if different
      //       if (permanentMessageId != null && permanentMessageId != tempMessageId) {
      //         final updatedMessage = existingMessage.copyWith(messageId: permanentMessageId);
      //         await messagesBox.delete(tempMessageId);
      //         await messagesBox.put(permanentMessageId, updatedMessage);
      //       }
      //     }
      //     await messagesBox.close();
      //   }

      //   setMessage("destination", msg["message"], msg['path']);
      //   // scrollController.animateTo(
      //   //   scrollController.position.maxScrollExtent,
      //   //   duration: const Duration(milliseconds: 300),
      //   //   curve: Curves.easeOut
      //   // );
      // });

      socket.on("message", (msg) async {
        print('📨 RECEIVED: New message from socket');
      print('   Message data: $msg');
        final messageId = msg['messageId'];
        if (messageId != null) {
          final messagesBox = await Hive.openBox<Message>('messages');
          final existingMessage = messagesBox.get(messageId);

          if (existingMessage != null) {
            // Update only server-provided fields while keeping the same ID
            final updatedMessage = existingMessage.copyWith(
              status: MessageStatus.delivered,
              // Update any other server-provided fields
            );
            await messagesBox.put(messageId, updatedMessage);
          }
          await messagesBox.close();
        }
        socket.on("messageError", (error) async {
          final messageId = error['messageId'];
          if (messageId != null) {
            final messagesBox = await Hive.openBox<Message>('messages');
            final existingMessage = messagesBox.get(messageId);

            if (existingMessage != null) {
              final failedMessage =
                  existingMessage.copyWith(status: MessageStatus.failed);
              await messagesBox.put(messageId, failedMessage);
            }
            await messagesBox.close();
          }
        });

        setMessage("destination", msg["message"], msg['path']);
      });
    });
    print(socket.connected);
  }

  Future<void> _createOrGetChat(String participantId, bool hide) async {
    try {
      final chat = await chatService.createOrGetChat(
          context: context, participantId: participantId, hide: hide);

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

  // Future<void> _loadInitialMessages() async {
  //   if (_isLoading) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     final messages = await chatService.getChatMessages(
  //       context: context,
  //       chatId: widget.chatId,
  //       page: 1,
  //       limit: _messagesPerPage,
  //     );

  //     setState(() {
  //       _messageCache.cacheMessages(
  //         widget.chatId,
  //         messages,
  //         messages.length == _messagesPerPage,
  //       );
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error loading messages: $e')),
  //       );
  //     }
  //   }
  // }

//   Future<void> _loadInitialMessages() async {
//   if (_isLoading) return;

//   setState(() => _isLoading = true);

//   try {
//     // Get the messages box
//     final messagesBox = Hive.box<Message>('messages');

//     // Check for cached messages for this chat and remove duplicates
//     final Map<String, Message> uniqueMessages = {};

//     // First pass: get all messages for this chat
//     for (var message in messagesBox.values) {
//       if (message.chatId == widget.chatId) {
//         // If message already exists, keep the one with non-sending status
//         if (uniqueMessages.containsKey(message.messageId)) {
//           final existingMessage = uniqueMessages[message.messageId]!;
//           if (existingMessage.status == MessageStatus.sending &&
//               message.status != MessageStatus.sending) {
//             uniqueMessages[message.messageId] = message;
//           }
//         } else {
//           uniqueMessages[message.messageId] = message;
//         }
//       }
//     }

//     // Convert to list and sort
//     final cachedMessages = uniqueMessages.values.toList()
//       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

//     // If we have cached messages, use them
//     if (cachedMessages.isNotEmpty) {
//       // Clean up duplicates in Hive
//       final duplicateKeys = messagesBox.values
//           .where((msg) => msg.chatId == widget.chatId)
//           .where((msg) =>
//               !uniqueMessages.containsKey(msg.messageId) ||
//               uniqueMessages[msg.messageId] != msg)
//           .map((msg) => msg.key)
//           .toList();

//       await messagesBox.deleteAll(duplicateKeys);

//       setState(() {
//         _messageCache.cacheMessages(
//           widget.chatId,
//           cachedMessages,
//           cachedMessages.length == _messagesPerPage,
//         );
//         _isLoading = false;
//       });
//       return;
//     }

//     // If no cached messages, fetch from network
//     final messages = await chatService.getChatMessages(
//       context: context,
//       chatId: widget.chatId,
//       page: 1,
//       limit: _messagesPerPage,
//     );

//     // Sort messages before caching
//     messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//     // Clear any existing messages for this chat
//     await messagesBox.deleteAll(
//       messagesBox.values
//           .where((msg) => msg.chatId == widget.chatId)
//           .map((msg) => msg.key)
//           .toList()
//     );

//     // Cache the fetched messages in Hive
//     await Future.wait(
//       messages.map((message) => messagesBox.put(message.messageId, message))
//     );

//     setState(() {
//       _messageCache.cacheMessages(
//         widget.chatId,
//         messages,
//         messages.length == _messagesPerPage,
//       );
//       _isLoading = false;
//     });
//   } catch (e) {
//     setState(() => _isLoading = false);
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading messages: $e')),
//       );
//     }
//   }
// }

  Future<void> _loadInitialMessages() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final messagesBox = Hive.box<Message>('messages');
      final Map<String, Message> uniqueMessages = {};

      // First pass: get all messages for this chat
      for (var entry in messagesBox.toMap().entries) {
        final message = entry.value;
        if (message.chatId == widget.chatId) {
          // If message already exists, keep the one with non-sending status
          if (uniqueMessages.containsKey(message.messageId)) {
            final existingMessage = uniqueMessages[message.messageId]!;
            if (existingMessage.status == MessageStatus.sending &&
                message.status != MessageStatus.sending) {
              uniqueMessages[message.messageId] = message;
            }
          } else {
            uniqueMessages[message.messageId] = message;
          }
        }
      }

      // Convert to list and sort
      final cachedMessages = uniqueMessages.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // If we have cached messages, use them
      if (cachedMessages.isNotEmpty) {
        // Clean up duplicates in Hive
        final duplicateKeys = messagesBox
            .toMap()
            .entries
            .where((entry) => entry.value.chatId == widget.chatId)
            .where((entry) =>
                !uniqueMessages.containsKey(entry.value.messageId) ||
                uniqueMessages[entry.value.messageId] != entry.value)
            .map((entry) => entry.key)
            .toList();

        await messagesBox.deleteAll(duplicateKeys);

        setState(() {
          _messageCache.cacheMessages(
            widget.chatId,
            cachedMessages,
            cachedMessages.length == _messagesPerPage,
          );
          _isLoading = false;
        });
        return;
      }

      // If no cached messages, fetch from network
      final messages = await chatService.getChatMessages(
        context: context,
        chatId: widget.chatId,
        page: 1,
        limit: _messagesPerPage,
      );

      // Sort messages before caching
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Clear any existing messages for this chat
      await messagesBox.deleteAll(messagesBox
          .toMap()
          .entries
          .where((entry) => entry.value.chatId == widget.chatId)
          .map((entry) => entry.key)
          .toList());

      // Cache the fetched messages in Hive
      await Future.wait(messages
          .map((message) => messagesBox.put(message.messageId, message)));

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

  void onImageSend(String path) async {
    print('Sending image with path: $path');

    for (int i = 0; i < popTime; i++) {
      Navigator.pop(context);
    }

    setState(() {
      popTime = 0;
    });

    try {
      var request =
          http.MultipartRequest("POST", Uri.parse('$BASE_URL/routes/addimage'));
      request.files.add(await http.MultipartFile.fromPath('img', path));
      request.headers.addAll({
        "Content-type": "multipart/form-data",
      });

      http.StreamedResponse response = await request.send();
      var httpResponse = await http.Response.fromStream(response);

      if (httpResponse.statusCode == 200) {
        var data = json.decode(httpResponse.body);
        String filename = data['path'];

        print('Server returned filename: $filename');

        // Send just the filename in the socket message
        setMessage("source", "", filename);
        socket.emit("message", {
          "sourceId": widget.sourchat,
          "targetId": widget.reciverId,
          "message": "",
          "path": filename,
        });
      } else {
        print('Failed to upload image: ${httpResponse.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading image')),
      );
    }
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

  // Future<void> sendMessage(
  //     String message, String sourceId, String targetId, String path,
  //     {int? voiceDuration}) async {
  //   if (message.trim().isEmpty && path.isEmpty) return;

  //   try {
  //     final box = await Hive.openBox<ChatData>('chatData');
  //     ChatData? matchingChatData;
  //     for (var chatData in box.values) {
  //       if (chatData.receiverId == widget.reciverId) {
  //         matchingChatData = chatData;
  //         break;
  //       }
  //     }

  //     await box.close();

  //     MessageType messageType =
  //         path.isNotEmpty ? MessageType.image : MessageType.text;
  //     String content = path.isNotEmpty ? path : message;
  //     print('hive chat id -- ${matchingChatData!.receiverId}');
  //     print('password of hide-----: ${widget.password}');

  //     if (path.isEmpty &&
  //         messageType == MessageType.text &&
  //         message == widget.password) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ChatScreen(
  //             sourchat: userId,
  //             chatId: matchingChatData!.chatId,
  //             password: widget.password,
  //             hide: true,
  //             reciverId: widget.reciverId,
  //           ),
  //         ),
  //       );
  //       return;
  //     }

  //     // Prepare media-related data if needed
  //     String? fileName;
  //     int? fileSize;
  //     String? thumbnail;
  //     int? duration;

  //     if (path.isNotEmpty) {
  //       bool isUrl = path.startsWith('http://') || path.startsWith('https://');

  //       if (isUrl) {
  //         fileName = path.split('/').last;
  //         fileSize = null;
  //       } else {
  //         File mediaFile = File(path);
  //         fileName = path.split('/').last;
  //         fileSize = await mediaFile.length();
  //       }

  //       if (messageType == MessageType.video) {
  //         duration = 0;
  //         thumbnail = '';
  //       }
  //     }
  //     print('content --- ${content}');

  //     if (message == "vce*@*#1" || message == "vce*@*#3") {
  //       try {
  //         final callStatus =
  //             message == "vce*@*#1" ? "Voice call started" : "Voice call ended";

  //         // Emit the voice call message through socket
  //         socket.emit("message", {
  //           "message": message,
  //           "sourceId": sourceId,
  //           "targetId": targetId,
  //           "path": "",
  //           "duration": voiceDuration,
  //         });

  //         print('voice content status: ${callStatus}');

  //         // Create and save the voice call message
  //         final Message? savedMessage = await chatServices.sendMessages(
  //           context: context,
  //           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
  //           content: callStatus,
  //           messageType: MessageType.audio,
  //           fileName: fileName,
  //           fileSize: fileSize,
  //           duration: voiceDuration,
  //           thumbnail: thumbnail,
  //           senderId: sourceId,
  //           messageId: '',
  //         );

  //         if (savedMessage != null) {
  //           setState(() {
  //             messages.add(savedMessage);
  //           });

  //           // Scroll to bottom
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             _scrollToBottom();
  //           });
  //         }
  //       } catch (e) {
  //         print('Error sending voice call message: $e');
  //         CustomSnackBar.show(context, 'Failed to send voice call message');
  //       }
  //       return;
  //     }

  //     if (message == "v-dc*@*#1" || message == "v-dc*@*#3") {
  //       try {
  //         final callStatus = message == "v-dc*@*#1"
  //             ? "Video call started"
  //             : "Video call ended";

  //         // Emit the voice call message through socket
  //         socket.emit("message", {
  //           "message": message,
  //           "sourceId": sourceId,
  //           "targetId": targetId,
  //           "path": "",
  //           "duration": voiceDuration,
  //         });

  //         print('voice content status: ${callStatus}');

  //         // Create and save the voice call message
  //         final Message? savedMessage = await chatServices.sendMessages(
  //           context: context,
  //           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
  //           content: callStatus,
  //           messageType: MessageType.video,
  //           fileName: fileName,
  //           fileSize: fileSize,
  //           duration: voiceDuration,
  //           thumbnail: thumbnail,
  //           senderId: sourceId,
  //           messageId: '',
  //         );

  //         if (savedMessage != null) {
  //           setState(() {
  //             messages.add(savedMessage);
  //           });

  //           // Scroll to bottom
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             _scrollToBottom();
  //           });
  //         }
  //       } catch (e) {
  //         print('Error sending voice call message: $e');
  //         CustomSnackBar.show(context, 'Failed to send voice call message');
  //       }
  //       return;
  //     }

  //     // Send message to database
  //     final Message? savedMessage = await chatServices.sendMessages(
  //       context: context,
  //       chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
  //       content: content,
  //       messageType: messageType,
  //       fileName: fileName,
  //       fileSize: fileSize,
  //       duration: duration,
  //       thumbnail: thumbnail,
  //       senderId: sourceId,
  //       messageId: '',
  //     );

  //     if (savedMessage != null) {
  //       // Emit message through socket for real-time communication
  //       socket.emit("message", {
  //         "message": message,
  //         "sourceId": sourceId,
  //         "targetId": targetId,
  //         "path": path,
  //         "messageId": savedMessage.chatId,
  //       });

  //       // Update local state
  //       setState(() {
  //         messages.add(savedMessage);
  //         sendButton = false;
  //       });

  //       _messageController.clear();
  //       _scrollToBottom();
  //     }
  //   } catch (e) {
  //     print('Error sending message: $e');
  //     CustomSnackBar.show(context, 'Failed to send message');
  //   }
  // }

//   Future<void> sendMessage(
//     String message,
//     String sourceId,
//     String targetId,
//     String path,
//     {int? voiceDuration}
// ) async {
//   if (message.trim().isEmpty && path.isEmpty) return;

//   try {
//     final chatBox = await Hive.openBox<ChatData>('chatData');
//     final messagesBox = await Hive.openBox<Message>('messages');

//     ChatData? matchingChatData;
//     for (var chatData in chatBox.values) {
//       if (chatData.receiverId == widget.reciverId) {
//         matchingChatData = chatData;
//         break;
//       }
//     }

//     await chatBox.close();

//     MessageType messageType = path.isNotEmpty ? MessageType.image : MessageType.text;
//     String content = path.isNotEmpty ? path : message;

//     // Handle password check
//     if (path.isEmpty &&
//         messageType == MessageType.text &&
//         message == widget.password) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatScreen(
//             sourchat: userId,
//             chatId: matchingChatData!.chatId,
//             password: widget.password,
//             hide: true,
//             reciverId: widget.reciverId,
//           ),
//         ),
//       );
//       return;
//     }

//     // Prepare media-related data
//     String? fileName;
//     int? fileSize;
//     String? thumbnail;
//     int? duration;

//     if (path.isNotEmpty) {
//       bool isUrl = path.startsWith('http://') || path.startsWith('https://');
//       if (isUrl) {
//         fileName = path.split('/').last;
//       } else {
//         File mediaFile = File(path);
//         fileName = path.split('/').last;
//         fileSize = await mediaFile.length();
//       }

//       if (messageType == MessageType.video) {
//         duration = 0;
//         thumbnail = '';
//       }
//     }

//     // Handle voice call messages
//     if (message == "vce*@*#1" || message == "vce*@*#3") {
//       final callStatus = message == "vce*@*#1" ? "Voice call started" : "Voice call ended";

//       // Create message object for voice call
//       final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//       final voiceMessage = Message(
//         messageId: tempMessageId,
//         chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//         senderId: sourceId,
//         type: MessageType.audio,
//         content: MessageContent(
//           text: callStatus,
//           duration: voiceDuration,
//           fileName: fileName,
//           fileSize: fileSize,
//           thumbnail: thumbnail,
//         ),
//         status: MessageStatus.sending,
//       );

//       // Store in Hive
//       await messagesBox.put(tempMessageId, voiceMessage);

//       // Emit through socket
//       socket.emit("message", {
//         "message": message,
//         "sourceId": sourceId,
//         "targetId": targetId,
//         "path": "",
//         "duration": voiceDuration,
//       });

//       try {
//         // Send to backend
//         final Message? savedMessage = await chatServices.sendMessages(
//           context: context,
//           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//           content: callStatus,
//           messageType: MessageType.audio,
//           fileName: fileName,
//           fileSize: fileSize,
//           duration: voiceDuration,
//           thumbnail: thumbnail,
//           senderId: sourceId,
//           messageId: tempMessageId,
//         );

//         if (savedMessage != null) {
//           // Update message in Hive with server response
//           await messagesBox.put(savedMessage.messageId, savedMessage);

//           setState(() {
//             messages.add(savedMessage);
//           });
//           _scrollToBottom();
//         }
//       } catch (e) {
//         print('Error sending voice call message: $e');
//         CustomSnackBar.show(context, 'Failed to send voice call message');
//       }
//       return;
//     }

//     // Handle video call messages
//     if (message == "v-dc*@*#1" || message == "v-dc*@*#3") {
//       final callStatus = message == "v-dc*@*#1" ? "Video call started" : "Video call ended";

//       // Create message object for video call
//       final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//       final videoMessage = Message(
//         messageId: tempMessageId,
//         chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//         senderId: sourceId,
//         type: MessageType.video,
//         content: MessageContent(
//           text: callStatus,
//           duration: voiceDuration,
//           fileName: fileName,
//           fileSize: fileSize,
//           thumbnail: thumbnail,
//         ),
//         status: MessageStatus.sending,
//       );

//       // Store in Hive
//       await messagesBox.put(tempMessageId, videoMessage);

//       // Emit through socket
//       socket.emit("message", {
//         "message": message,
//         "sourceId": sourceId,
//         "targetId": targetId,
//         "path": "",
//         "duration": voiceDuration,
//       });

//       try {
//         final Message? savedMessage = await chatServices.sendMessages(
//           context: context,
//           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//           content: callStatus,
//           messageType: MessageType.video,
//           fileName: fileName,
//           fileSize: fileSize,
//           duration: voiceDuration,
//           thumbnail: thumbnail,
//           senderId: sourceId,
//           messageId: tempMessageId,
//         );

//         if (savedMessage != null) {
//           // Update message in Hive with server response
//           await messagesBox.put(savedMessage.messageId, savedMessage);

//           setState(() {
//             messages.add(savedMessage);
//           });
//           _scrollToBottom();
//         }
//       } catch (e) {
//         print('Error sending video call message: $e');
//         CustomSnackBar.show(context, 'Failed to send video call message');
//       }
//       return;
//     }

//     // Handle regular messages
//     final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final newMessage = Message(
//       messageId: tempMessageId,
//       chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//       senderId: sourceId,
//       type: messageType,
//       content: MessageContent(
//         text: messageType == MessageType.text ? content : null,
//         mediaUrl: messageType != MessageType.text ? content : null,
//         fileName: fileName,
//         fileSize: fileSize,
//         duration: duration,
//         thumbnail: thumbnail,
//       ),
//       status: MessageStatus.sending,
//     );

//     // Store in Hive first
//     await messagesBox.put(tempMessageId, newMessage);

//     // Update UI immediately
//     setState(() {
//       messages.add(newMessage);
//       sendButton = false;
//     });

//     // Send to backend
//     try {
//       final Message? savedMessage = await chatServices.sendMessages(
//         context: context,
//         chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//         content: content,
//         messageType: messageType,
//         fileName: fileName,
//         fileSize: fileSize,
//         duration: duration,
//         thumbnail: thumbnail,
//         senderId: sourceId,
//         messageId: tempMessageId,
//       );

//       if (savedMessage != null) {
//         // Update message in Hive with server response
//         await messagesBox.put(savedMessage.messageId, savedMessage);

//         // Emit through socket
//         socket.emit("message", {
//           "message": message,
//           "sourceId": sourceId,
//           "targetId": targetId,
//           "path": path,
//           "messageId": savedMessage.chatId,
//         });

//         // Update UI with confirmed message
//         setState(() {
//           final index = messages.indexWhere((m) => m.messageId == tempMessageId);
//           if (index != -1) {
//             messages[index] = savedMessage;
//           }
//         });
//       }
//     } catch (e) {
//       // Update message status to failed in Hive
//       final failedMessage = newMessage.copyWith(status: MessageStatus.failed);
//       await messagesBox.put(tempMessageId, failedMessage);

//       print('Error sending message: $e');
//       CustomSnackBar.show(context, 'Failed to send message');

//       // Update UI to show failed status
//       setState(() {
//         final index = messages.indexWhere((m) => m.messageId == tempMessageId);
//         if (index != -1) {
//           messages[index] = failedMessage;
//         }
//       });
//     }

//     _messageController.clear();
//     _scrollToBottom();

//   } catch (e) {
//     print('Error in message handling: $e');
//     CustomSnackBar.show(context, 'Error processing message');
//   }
// }

  Future<void> sendMessage(
      String message, String sourceId, String targetId, String path,
      {int? voiceDuration}) async {
    if (message.trim().isEmpty && path.isEmpty) return;
    print('Replay message before sending : -- ${_replyingMessageId}');

    try {
      final chatBox = await Hive.openBox<ChatData>('chatData');
      final messagesBox = await Hive.openBox<Message>('messages');
      final messageId = const Uuid().v4();
      print('🚀 SEND_START: Initiating message send process');
  print('📤 Message Details:');
  print('   ID: $messageId');
  print('   Content: $message');
  print('   From: $sourceId');
  print('   To: $targetId');
  print('   Has Media: ${path.isNotEmpty}');
  print(' send message id from senn: ${messageId}');
      setMessage("source", message, path,
          messageId: messageId, voiceDuration: voiceDuration);
      print('📱 UI_UPDATE: Local message displayed');    

      ChatData? matchingChatData;
      for (var chatData in chatBox.values) {
        if (chatData.receiverId == widget.reciverId) {
          matchingChatData = chatData;
          break;
        }
      }

      // await chatBox.close();

      // MessageType messageType =
      //     path.isNotEmpty ? MessageType.image : MessageType.text;
      // String content = path.isNotEmpty ? path : message;
      MessageType messageType;
      if (path.isNotEmpty) {
        if (path.endsWith('.mp4')) {
          messageType = MessageType.video;
        } else if (path.endsWith('.jpg') ||
            path.endsWith('.jpeg') ||
            path.endsWith('.png')) {
          messageType = MessageType.image;
        } else {
          messageType = MessageType.text;
        }
      } else {
        messageType = MessageType.text;
      }

      String content = path.isNotEmpty ? path : message;

      // Handle password check
      if (path.isEmpty &&
          messageType == MessageType.text &&
          message == widget.password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              sourchat: userId,
              chatId: matchingChatData!.chatId,
              password: widget.password,
              hide: true,
              reciverId: widget.reciverId,
              isUserBlocked: widget.isUserBlocked,
            ),
          ),
        );
        return;
      }

      // Prepare media-related data
      String? fileName;
      int? fileSize;
      String? thumbnail;
      int? duration;

      if (path.isNotEmpty) {
        bool isUrl = path.startsWith('http://') || path.startsWith('https://');
        if (isUrl) {
          fileName = path.split('/').last;
        } else {
          File mediaFile = File(path);
          fileName = path.split('/').last;
          fileSize = await mediaFile.length();
        }

        if (messageType == MessageType.video) {
          duration = 0;
          thumbnail = '';
        }
      }

      // Generate a message ID that will be used throughout the process
      // final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final chatId = widget.chatId.isEmpty ? fetchedChatId : widget.chatId;

      // Handle voice call messages
      if (message == "vce*@*#1" || message == "vce*@*#3") {
        final callStatus =
            message == "vce*@*#1" ? "Voice call started" : "Voice call ended";

        final voiceMessage = Message(
          messageId: messageId,
          chatId: chatId,
          senderId: sourceId,
          type: MessageType.audio,
          content: MessageContent(
            text: callStatus,
            duration: voiceDuration,
            fileName: fileName,
            fileSize: fileSize,
            thumbnail: thumbnail,
          ),
          status: MessageStatus.sending,
        );

        // Store initial message
        await messagesBox.put(messageId, voiceMessage);
        setState(() => messages.add(voiceMessage));

        socket.emit("message", {
          "message": message,
          "sourceId": sourceId,
          "targetId": targetId,
          "path": "",
          "duration": voiceDuration,
        });

        try {
          final Message? savedMessage = await chatServices.sendMessages(
            context: context,
            chatId: chatId,
            content: callStatus,
            messageType: MessageType.audio,
            fileName: fileName,
            fileSize: fileSize,
            duration: voiceDuration,
            thumbnail: thumbnail,
            senderId: sourceId,
            messageId: messageId,
            replyTo: _replyingMessageId,
          );

          if (savedMessage != null) {
            // Update existing message
            await messagesBox.put(messageId, savedMessage);
            setState(() {
              final index =
                  messages.indexWhere((m) => m.messageId == messageId);
              if (index != -1) {
                messages[index] = savedMessage;
              }
            });
          }
        } catch (e) {
          print('Error sending voice call message: $e');
          final failedMessage =
              voiceMessage.copyWith(status: MessageStatus.failed);
          await messagesBox.put(messageId, failedMessage);
          CustomSnackBar.show(context, 'Failed to send voice call message');
        }
        _scrollToBottom();
        return;
      }

      // Handle video call messages
      if (message == "v-dc*@*#1" || message == "v-dc*@*#3") {
        final callStatus =
            message == "v-dc*@*#1" ? "Video call started" : "Video call ended";

        final videoMessage = Message(
          messageId: messageId,
          chatId: chatId,
          senderId: sourceId,
          type: MessageType.video,
          content: MessageContent(
            text: callStatus,
            duration: voiceDuration,
            fileName: fileName,
            fileSize: fileSize,
            thumbnail: thumbnail,
          ),
          status: MessageStatus.sending,
        );

        // Store initial message
        await messagesBox.put(messageId, videoMessage);
        setState(() => messages.add(videoMessage));

        socket.emit("message", {
          "message": message,
          "sourceId": sourceId,
          "targetId": targetId,
          "path": "",
          "duration": voiceDuration,
          "messageId": messageId,
  "chatId": widget.chatId.isEmpty ? fetchedChatId : widget.chatId,  // Add this
  "type": path.isNotEmpty ? 
    (path.endsWith('.mp4') ? 'video' : 
     path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') ? 'image' : 'text') 
    : 'text',  // Add this
  "voiceDuration": voiceDuration,
        });

        try {
          final Message? savedMessage = await chatServices.sendMessages(
            context: context,
            chatId: chatId,
            content: callStatus,
            messageType: MessageType.video,
            fileName: fileName,
            fileSize: fileSize,
            duration: voiceDuration,
            thumbnail: thumbnail,
            senderId: sourceId,
            messageId: messageId,
            replyTo: _replyingMessageId,
          );

          if (savedMessage != null) {
            // Update existing message
            await messagesBox.put(messageId, savedMessage);
            setState(() {
              final index =
                  messages.indexWhere((m) => m.messageId == messageId);
              if (index != -1) {
                messages[index] = savedMessage;
              }
            });
          }
        } catch (e) {
          print('Error sending video call message: $e');
          final failedMessage =
              videoMessage.copyWith(status: MessageStatus.failed);
          await messagesBox.put(messageId, failedMessage);
          CustomSnackBar.show(context, 'Failed to send video call message');
        }
        _scrollToBottom();
        return;
      }

      void sendReplyMessage(BuildContext context) async {
        final chatService = ChatServices();
        final String newMessageId = Uuid().v4();

        Message? message = await chatService.replyMessages(
            context: context,
            messageId: newMessageId,
            chatId: '6780a6a7e058f492419e0092',
            content: 'Hello, this is a test reply message!',
            senderId: '677fd21f5a9def773966c904',
            messageType: MessageType.text,
            quotedMessageId: 'b255ba64-2cfe-4408-8780-a3211ed887ab');

        if (message != null) {
          print('Message sent successfully: ${message.toJson()}');
        } else {
          print('Failed to send message.');
        }
      }

      // Handle regular messages
      final newMessage = Message(
        messageId: messageId,
        chatId: chatId,
        senderId: sourceId,
        type: messageType,
        content: MessageContent(
          text: messageType == MessageType.text ? content : null,
          mediaUrl: messageType != MessageType.text ? content : null,
          fileName: fileName,
          fileSize: fileSize,
          duration: duration,
          thumbnail: thumbnail,
        ),
        status: MessageStatus.sending,
        replyTo: _replyingMessageId,
      );

      // Store initial message
      await messagesBox.put(messageId, newMessage);
      setState(() {
        messages.add(newMessage);
        sendButton = false;
      });

      socket.emit("message", {
        "message": message,
        "sourceId": sourceId,
        "targetId": targetId,
        "path": path,
        "tempMessageId": messageId, // Send the pre-generated ID
        "chatId": widget.chatId.isEmpty ? fetchedChatId : widget.chatId,  // Add this
  "content": path.isNotEmpty ? 
    (path.endsWith('.mp4') ? 'video' : 
     path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') ? 'image' : 'text') 
    : 'text',  // Add this
  "voiceDuration": voiceDuration,
      });
      

      try {
        final Message? savedMessage = await chatServices.sendMessages(
          context: context,
          chatId: chatId,
          content: content,
          messageType: messageType,
          fileName: fileName,
          fileSize: fileSize,
          duration: duration,
          thumbnail: thumbnail,
          senderId: sourceId,
          messageId: messageId,
          replyTo: _replyingMessageId,
        );

        if (savedMessage != null) {
          // Update the message in Hive with any additional server data
          await messagesBox.put(messageId, savedMessage);
          setState(() {
            final index = messages.indexWhere((m) => m.messageId == messageId);
            if (index != -1) {
              messages[index] = savedMessage;
            }
          });
        }
      } catch (e) {
        final failedMessage = newMessage.copyWith(status: MessageStatus.failed);
        await messagesBox.put(messageId, failedMessage);

        print('Error sending message: $e');
        CustomSnackBar.show(context, 'Failed to send message');
      }

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error in message handling: $e');
      CustomSnackBar.show(context, 'Error processing message');
    }
  }

  void setMessage(String type, String message, String path,
      {String? messageId, int? voiceDuration}) {
    String fullPath = '';
    if (path.isNotEmpty) {
      // Only set fullPath if it starts with Cloudinary URL or has http prefix
      fullPath = path.startsWith('http://res.cloudinary.com') ||
              path.startsWith('http')
          ? path
          : '$BASE_URL/uploads/$path';
    }

    MessageType messageType;
    String displayText;

    if (message == 'vce*@*#1') {
      messageType = MessageType.audio;
      displayText = 'Voice call started';
    } else if (message == 'vce*@*#3') {
      messageType = MessageType.audio;
      displayText = 'Voice call ended';
    } else if (message == 'v-dc*@*#1') {
      messageType = MessageType.video;
      displayText = 'Video call started';
    } else if (message == 'v-dc*@*#3') {
      messageType = MessageType.video;
      displayText = 'Video call ended';
    } else {
      if (path.isNotEmpty) {
        if (path.endsWith('.mp4')) {
          messageType = MessageType.video;
        } else if (path.endsWith('.mp4')) {
          messageType = MessageType.video;
        } else if (path.endsWith('.jpg') ||
            path.endsWith('.jpeg') ||
            path.endsWith('.png')) {
          messageType = MessageType.image;
        } else {
          messageType = MessageType.text;
        }
        displayText = path; // Use path if it's not empty
      } else {
        messageType = MessageType.text;
        displayText = message; // Default to message if no file path
      }
    }

    // Determine the correct sender ID based on the message type
    String senderId;
    if (type == "source") {
      print('if type: source ${widget.sourchat}');
      senderId = widget.sourchat; // Current user is sender
    } else if (type == "destination") {
      print('if type: destination ${widget.reciverId}');
      senderId = widget.reciverId; // Other user is sender
    } else {
      throw ArgumentError('Invalid message type');
    }

    // print('reciver id  --- ${messageType}  sender if  ${widge}');
    print('media url --- ${messageType}  and  ${displayText}');
 print('Message ---I-qD: ${messageId}');
     print('Sender ID: $senderId');
     print('type i--: $type');
  print('Receiver ID: ${widget.reciverId}');
  print('Message Content: $message');
  print('Message Type: $messageType');
  print('Full Path (media URL): $fullPath');
  print('Display Text: $displayText');


    Message newMessage = Message(
      chatId: widget.chatId,
      senderId: senderId,
      type: messageType,
      content: MessageContent(
        text: displayText,
        mediaUrl:
            path.startsWith('http://res.cloudinary.com') ? fullPath : null,
        fileName: path.isNotEmpty ? path.split('/').last : null,
        fileSize: null,
        duration: voiceDuration,
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

     print('New Message: ${newMessage.content.text}');
  print('Message Status: ${newMessage.status}');
  print('Message ---ID: ${newMessage.messageId}');

    // setState(() {
    //   messages.add(newMessage);
    // });

    setState(() {
      // Insert at beginning since ListView is reversed
      messages.insert(0, newMessage);
    });

    // Auto-scroll to bottom when new message is added
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.animateTo(
    //     _scrollController.position.maxScrollExtent,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeOut,
    //   );
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final messages = _messageCache.getCachedMessages(
      widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
    );
    String? previousMessageDate;
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAttachments = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.push<int>(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatProfileScreen(
                          chatId: widget.chatId,
                          isUserBlocked: widget.isUserBlocked,
                          targetUserId: widget.reciverId,
                        )),
              );
            },
            child: Row(
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
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  await sendMessage(
                      "vce*@*#1", widget.sourchat, widget.reciverId, "");

                  setMessage("source", "vce*@*#1", "");
                  const Text('Boice call started-- ');

                  socket.emit("message", {
                    "sourceId": widget.sourchat,
                    "targetId": widget.reciverId,
                    "message": "vce*@*#1",
                    "path": "",
                  });
                  print('Boice emitted-- ');
                  final int? duration = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoiceCallScreen(
                        channelName: widget.chatId,
                        appId: '20810c5544884126b8ffbbe4e0453736',
                        callerName: widget.sourchat,
                        callerAvatar: 'assets/images/shrutika.png',
                      ),
                    ),
                  );

                  print("Call duration: $duration seconds");

                  setMessage("source", "vce*@*#3", "");
                  await sendMessage(
                      "vce*@*#3", widget.sourchat, widget.reciverId, "",
                      voiceDuration: duration);
                } catch (e) {
                  print('Error handling voice call: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error occurred during voice call')),
                  );
                }
              },
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () async {
                try {
                  await sendMessage(
                      "v-dc*@*#1", widget.sourchat, widget.reciverId, "");
                  setMessage("source", "v-dc*@*#1", "");

                  socket.emit("message", {
                    "sourceId": widget.sourchat,
                    "targetId": widget.reciverId,
                    "message": "v-dc*@*#1",
                    "path": "",
                  });

                  int? duration = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCallScreen(
                        channelName: widget.chatId,
                        callerName: userId,
                        callerAvatar: 'assets/images/shrutika.png',
                      ),
                    ),
                  );
                  print("Call duration: $duration seconds");
                  setMessage("source", "v-dc*@*#3", "");
                  await sendMessage(
                      "v-dc*@*#3", widget.sourchat, widget.reciverId, "",
                      voiceDuration: 0);
                } catch (e) {
                  print('Error handling video call: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error occurred during video call')),
                  );
                }
              },
              icon: const Icon(Icons.video_call),
            ),
            // Builder(
            //   builder: (context) => IconButton(
            //     icon: const Icon(Icons.more_vert),
            //     onPressed: () {
            //       final RenderBox button =
            //           context.findRenderObject() as RenderBox;
            //       final RenderBox overlay = Overlay.of(context)
            //           .context
            //           .findRenderObject() as RenderBox;
            //       final Offset buttonPosition =
            //           button.localToGlobal(Offset.zero, ancestor: overlay);
            //       final double screenWidth = overlay.size.width;
            //       const double widgetWidth = 236.0;
            //       final double xOffset = screenWidth - widgetWidth - 2;

            //       ChatScreenActionWidget.show(
            //         context,
            //         position: Offset(xOffset, buttonPosition.dy + 35),
            //         chatId: widget.chatId,
            //         hide: widget.hide,
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: _refreshMessages,
            child: Stack(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      color: GlobalVariables.backgroundColor,
                      child: Column(children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            reverse: true,
                            controller: _scrollController,
                            itemCount: messages.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
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
                              final messageDate = DateFormat('yyyy-MM-dd')
                                  .format(message.createdAt);

                              // Fetch replied message if it exists
                              Message? repliedMessage;
                              if (message.replyTo != null) {
                                final messageBox =
                                    Hive.box<Message>('messages');
                                repliedMessage = messageBox
                                    .get(message.replyTo); // Store it here
                              }

                              bool showDateHeader = false;
                              if (previousMessageDate == null ||
                                  previousMessageDate != messageDate) {
                                showDateHeader = true;
                                previousMessageDate = messageDate;
                              }

                              return Column(
                                children: [
                                  const SizedBox(height: 20),
                                  if (showDateHeader)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(message.createdAt),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),

                                  // Check message type and render appropriate widget
                                  if (isCurrentUser) ...[
                                    if (message.type == MessageType.text)
                                      OwnMessageCard(
                                        message: message.content.text ?? '',
                                        time: message.createdAt,
                                        isRead: message.status ==
                                            MessageStatus.read,
                                        messageId: message.messageId,
                                        replyToId: message.replyTo,
                                        // replyToContent:
                                        //     repliedMessage?.content.text ?? repliedMessage?.content.mediaUrl,
                                        replyToContent: (repliedMessage?.content
                                                    .text?.isNotEmpty ??
                                                false)
                                            ? repliedMessage?.content.text
                                            : repliedMessage
                                                    ?.content.mediaUrl ??
                                                '',

                                        onReply: (messageId, message) {
                                          setState(() {
                                            _replyingMessageId = messageId;
                                            _replyingMessageContent = message;
                                          });
                                        },
                                      )
                                    else if (message.type == MessageType.image)
                                      OwnImageCard(
                                        path: message.content.mediaUrl ?? '',
                                        time: message.createdAt,
                                        messageId: message.messageId,
                                        replyToId: message.replyTo,
                                        replyToContent:
                                            repliedMessage?.content.mediaUrl ??
                                                '',
                                        onReply: (messageId, message) {
                                          setState(() {
                                            _replyingMessageId = messageId;
                                            _replyingMessageContent = message;
                                          });
                                        },
                                        isRead: message.status ==
                                            MessageStatus.read,
                                      )
                                    else if (message.type == MessageType.audio)
                                      OwnVoiceCallChatWidget(
                                        duration: message.content.duration ?? 0,
                                        message: message.content.mediaUrl ?? '',
                                        messageId: message.messageId,
                                        time: DateFormat('hh:mm a')
                                            .format(message.createdAt),
                                        chatId: widget.chatId,
                                      )
                                    else if (message.type ==
                                            MessageType.video &&
                                        message.content.mediaUrl != null &&
                                        message.content.mediaUrl!
                                            .endsWith('.mp4'))
                                      OwnVideoCard(
                                        videoUrl:
                                            message.content.mediaUrl ?? '',
                                        messageId: message.messageId,
                                        time: message.createdAt,
                                        replyToId: message.replyTo,
                                        replyToContent:
                                            repliedMessage?.content.mediaUrl ??
                                                '',
                                        onReply: (messageId, message) {
                                          setState(() {
                                            _replyingMessageId = messageId;
                                            _replyingMessageContent = message;
                                          });
                                        },
                                        isRead: message.status ==
                                            MessageStatus.read,
                                      )
                                    else if (message.type == MessageType.video)
                                      OwnVideoCallChatWidget(
                                        message: message.content.mediaUrl ?? '',
                                        chatId: widget.chatId,
                                        messageId: message.messageId,
                                        time: DateFormat('hh:mm a')
                                            .format(message.createdAt),
                                        duration: message.content.duration ?? 0,
                                      )
                                  ] else ...[
                                    if (message.type == MessageType.text)
                                      ReplyMessageCard(
                                        message: message.content.text ?? '',
                                        time: message.createdAt,
                                        messageId: message.messageId,
                                        replyToId: message.replyTo,
                                        replyToContent:
                                            repliedMessage?.content.text ?? '',
                                      )
                                    else if (message.type == MessageType.image)
                                      ReplyImageCard(
                                        path: message.content.mediaUrl ?? '',
                                        messageId: message.messageId,
                                        time: message.createdAt,
                                      )
                                    else if (message.type == MessageType.audio)
                                      ReplyVoiceCallChatWidget(
                                        duration: message.content.duration ?? 0,
                                        messageId: message.messageId,
                                        time: DateFormat('hh:mm a')
                                            .format(message.createdAt),
                                        message: message.content.mediaUrl ?? '',
                                        chatId: widget.chatId,
                                      )
                                    else if (message.type == MessageType.video)
                                      ReplyVideoCallChatWidget(
                                        message: message.content.mediaUrl ?? '',
                                        messageId: message.messageId,
                                        chatId: widget.chatId,
                                        time: DateFormat('hh:mm a')
                                            .format(message.createdAt),
                                        duration: message.content.duration ?? 0,
                                      )
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_replyingMessageContent != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Replying to:',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              Text(
                                                _replyingMessageId != null
                                                    ? _replyingMessageContent ??
                                                        ''
                                                    : 'Replying to yourself...',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (_replyingMessageId != null)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _replyingMessageId = null;
                                              _replyingMessageContent = null;
                                            });
                                          },
                                          child:
                                              const Icon(Icons.close, size: 20),
                                        )
                                    ],
                                  ),
                                ),
                              ChatInputWidget(
                                onSendMessage: sendMessage,
                                onImageSend: onImageSend,
                                sourchat: widget.sourchat,
                                receiverId: widget.reciverId,
                                scrollController: _scrollController,
                                replyingMessageId: _replyingMessageId,
                                replyingMessageContent: _replyingMessageContent,
                                onAttachmentPressed: () {
                                  setState(() {
                                    _showAttachments = true;
                                  });
                                },
                                onVideoSend: onImageSend,
                              ),
                            ],
                          ),
                        )
                      ]),
                    )),
                if (_showAttachments)
                  Positioned(
                    bottom:
                        80, // Adjust this value based on your ChatInputWidget height
                    child: ChatAttachmentMenuWidget(
                      onClose: () {
                        setState(() {
                          _showAttachments = false;
                        });
                      },
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}











// class ChatScreen extends StatefulWidget {
//   final String reciverId;
//   final String sourchat;
//   final String chatId;
//   final bool hide;
//   final String password;

//   ChatScreen({
//     Key? key,
//     required this.reciverId,
//     required this.sourchat,
//     required this.chatId,
//     required this.hide,
//     required this.password,
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
//   String BASE_URL = "http://192.168.1.104:5000";
//   String? result;
//   final ChatServices chatServices = ChatServices();
//   late String userId;
//   bool _isLoading = false;
//   bool hasMore = true;
//   bool _showAttachments = false;
//   int currentPage = 1;
//   final MessageCache _messageCache = MessageCache();
//   static const int _messagesPerPage = 30;
//   final chatService = ChatServices();
//   late String fetchedChatId;

//   @override
//   void initState() {
//     super.initState();
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     userId = userProvider.user.id;
//     connect();
//     final participantId = widget.reciverId;
//     bool hide = true;
//     _createOrGetChat(participantId, hide);
//     _loadInitialMessages();
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     _messageController.dispose();
//     socket.disconnect();
//     super.dispose();
//   }

//   String formatDate(DateTime date) {
//     return DateFormat('yyyy-MM-dd').format(date); // Format it like: 2025-01-15
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       _loadMoreMessages();
//     }
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

//   // void connect() {
//   //   socket = IO.io(BASE_URL, <String, dynamic>{
//   //     "transports": ["websocket"],
//   //     "autoConnect": false,
//   //   });
//   //   socket.connect();
//   //   socket.onConnect((data) => print('connected'));
//   //   socket.emit("signin", widget.sourchat);

//   //   socket.onConnect((data) {
//   //     print("Connected");

//   //     // Listen for new messages
//   //     socket.on("message", (msg) {
//   //       print(msg);
//   //       setMessage("destination", msg["message"], msg['path']);
//   //       _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//   //           duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//   //     });

//   //     // Listen for read receipts
//   //     socket.on("message_read_receipt", (data) {
//   //       // _updateMessageReadStatus(data['messageId'], data['readAt']);
//   //     });
//   //   });
//   //   print(socket.connected);
//   // }

//   void connect() {
//   socket = IO.io(BASE_URL, <String, dynamic>{
//     "transports": ["websocket"],
//     "autoConnect": false,
//   });
//   socket.connect();
//   socket.onConnect((data) => print('connected'));
//   socket.emit("signin", widget.sourchat);
  
//   socket.onConnect((data) {
//     print("Connected");
    
//     // Updated message listener to handle ID reconciliation
//     // socket.on("message", (msg) async {
//     //   print(msg);
//     //   final tempMessageId = msg['tempMessageId'];
//     //   final permanentMessageId = msg['messageId'];
      
//     //   if (tempMessageId != null) {
//     //     final messagesBox = await Hive.openBox<Message>('messages');
//     //     final existingMessage = messagesBox.get(tempMessageId);
        
//     //     if (existingMessage != null) {
//     //       // Update the message with the permanent ID if different
//     //       if (permanentMessageId != null && permanentMessageId != tempMessageId) {
//     //         final updatedMessage = existingMessage.copyWith(messageId: permanentMessageId);
//     //         await messagesBox.delete(tempMessageId);
//     //         await messagesBox.put(permanentMessageId, updatedMessage);
//     //       }
//     //     }
//     //     await messagesBox.close();
//     //   }
      
//     //   setMessage("destination", msg["message"], msg['path']);
//     //   // scrollController.animateTo(
//     //   //   scrollController.position.maxScrollExtent,
//     //   //   duration: const Duration(milliseconds: 300), 
//     //   //   curve: Curves.easeOut
//     //   // );
//     // });

//     socket.on("message", (msg) async {
//   final messageId = msg['messageId'];
//   if (messageId != null) {
//     final messagesBox = await Hive.openBox<Message>('messages');
//     final existingMessage = messagesBox.get(messageId);
    
//     if (existingMessage != null) {
//       // Update only server-provided fields while keeping the same ID
//       final updatedMessage = existingMessage.copyWith(
//         status: MessageStatus.delivered,
//         // Update any other server-provided fields
//       );
//       await messagesBox.put(messageId, updatedMessage);
//     }
//     await messagesBox.close();
//   }

//   socket.on("messageError", (error) async {
//   final messageId = error['messageId'];
//   if (messageId != null) {
//     final messagesBox = await Hive.openBox<Message>('messages');
//     final existingMessage = messagesBox.get(messageId);
    
//     if (existingMessage != null) {
//       final failedMessage = existingMessage.copyWith(
//         status: MessageStatus.failed
//       );
//       await messagesBox.put(messageId, failedMessage);
//     }
//     await messagesBox.close();
//   }
// });
  
//   setMessage("destination", msg["message"], msg['path']);
// });
//   });
//   print(socket.connected);
// }

//   Future<void> _createOrGetChat(String participantId, bool hide) async {
//     try {
//       final chat = await chatService.createOrGetChat(
//           context: context, participantId: participantId, hide: hide);

//       setState(() {
//         // Handle chat (e.g., navigate to chat screen or update UI)
//         fetchedChatId = chat!.id;
//         print('Chat ID: ${chat?.id}');
//       });
//     } catch (e) {
//       // Handle error appropriately
//       print("Error: $e");
//     }
//   }

//   // Future<void> _loadInitialMessages() async {
//   //   if (_isLoading) return;

//   //   setState(() => _isLoading = true);

//   //   try {
//   //     final messages = await chatService.getChatMessages(
//   //       context: context,
//   //       chatId: widget.chatId,
//   //       page: 1,
//   //       limit: _messagesPerPage,
//   //     );

//   //     setState(() {
//   //       _messageCache.cacheMessages(
//   //         widget.chatId,
//   //         messages,
//   //         messages.length == _messagesPerPage,
//   //       );
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     setState(() => _isLoading = false);
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error loading messages: $e')),
//   //       );
//   //     }
//   //   }
//   // }
  
// //   Future<void> _loadInitialMessages() async {
// //   if (_isLoading) return;
  
// //   setState(() => _isLoading = true);
  
// //   try {
// //     // Get the messages box
// //     final messagesBox = Hive.box<Message>('messages');
    
// //     // Check for cached messages for this chat and remove duplicates
// //     final Map<String, Message> uniqueMessages = {};
    
// //     // First pass: get all messages for this chat
// //     for (var message in messagesBox.values) {
// //       if (message.chatId == widget.chatId) {
// //         // If message already exists, keep the one with non-sending status
// //         if (uniqueMessages.containsKey(message.messageId)) {
// //           final existingMessage = uniqueMessages[message.messageId]!;
// //           if (existingMessage.status == MessageStatus.sending && 
// //               message.status != MessageStatus.sending) {
// //             uniqueMessages[message.messageId] = message;
// //           }
// //         } else {
// //           uniqueMessages[message.messageId] = message;
// //         }
// //       }
// //     }
    
// //     // Convert to list and sort
// //     final cachedMessages = uniqueMessages.values.toList()
// //       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
// //     // If we have cached messages, use them
// //     if (cachedMessages.isNotEmpty) {
// //       // Clean up duplicates in Hive
// //       final duplicateKeys = messagesBox.values
// //           .where((msg) => msg.chatId == widget.chatId)
// //           .where((msg) => 
// //               !uniqueMessages.containsKey(msg.messageId) || 
// //               uniqueMessages[msg.messageId] != msg)
// //           .map((msg) => msg.key)
// //           .toList();
      
// //       await messagesBox.deleteAll(duplicateKeys);
      
// //       setState(() {
// //         _messageCache.cacheMessages(
// //           widget.chatId,
// //           cachedMessages,
// //           cachedMessages.length == _messagesPerPage,
// //         );
// //         _isLoading = false;
// //       });
// //       return;
// //     }
    
// //     // If no cached messages, fetch from network
// //     final messages = await chatService.getChatMessages(
// //       context: context,
// //       chatId: widget.chatId,
// //       page: 1,
// //       limit: _messagesPerPage,
// //     );
    
// //     // Sort messages before caching
// //     messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
// //     // Clear any existing messages for this chat
// //     await messagesBox.deleteAll(
// //       messagesBox.values
// //           .where((msg) => msg.chatId == widget.chatId)
// //           .map((msg) => msg.key)
// //           .toList()
// //     );
    
// //     // Cache the fetched messages in Hive
// //     await Future.wait(
// //       messages.map((message) => messagesBox.put(message.messageId, message))
// //     );
    
// //     setState(() {
// //       _messageCache.cacheMessages(
// //         widget.chatId,
// //         messages,
// //         messages.length == _messagesPerPage,
// //       );
// //       _isLoading = false;
// //     });
// //   } catch (e) {
// //     setState(() => _isLoading = false);
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading messages: $e')),
// //       );
// //     }
// //   }
// // }


// Future<void> _loadInitialMessages() async {
//   if (_isLoading) return;
  
//   setState(() => _isLoading = true);
  
//   try {
//     final messagesBox = Hive.box<Message>('messages');
//     final Map<String, Message> uniqueMessages = {};
    
//     // First pass: get all messages for this chat
//     for (var entry in messagesBox.toMap().entries) {
//       final message = entry.value;
//       if (message.chatId == widget.chatId) {
//         // If message already exists, keep the one with non-sending status
//         if (uniqueMessages.containsKey(message.messageId)) {
//           final existingMessage = uniqueMessages[message.messageId]!;
//           if (existingMessage.status == MessageStatus.sending &&
//               message.status != MessageStatus.sending) {
//             uniqueMessages[message.messageId] = message;
//           }
//         } else {
//           uniqueMessages[message.messageId] = message;
//         }
//       }
//     }
    
//     // Convert to list and sort
//     final cachedMessages = uniqueMessages.values.toList()
//       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
//     // If we have cached messages, use them
//     if (cachedMessages.isNotEmpty) {
//       // Clean up duplicates in Hive
//       final duplicateKeys = messagesBox.toMap().entries
//           .where((entry) => entry.value.chatId == widget.chatId)
//           .where((entry) => 
//               !uniqueMessages.containsKey(entry.value.messageId) ||
//               uniqueMessages[entry.value.messageId] != entry.value)
//           .map((entry) => entry.key)
//           .toList();
      
//       await messagesBox.deleteAll(duplicateKeys);
      
//       setState(() {
//         _messageCache.cacheMessages(
//           widget.chatId,
//           cachedMessages,
//           cachedMessages.length == _messagesPerPage,
//         );
//         _isLoading = false;
//       });
//       return;
//     }
    
//     // If no cached messages, fetch from network
//     final messages = await chatService.getChatMessages(
//       context: context,
//       chatId: widget.chatId,
//       page: 1,
//       limit: _messagesPerPage,
//     );
    
//     // Sort messages before caching
//     messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
//     // Clear any existing messages for this chat
//     await messagesBox.deleteAll(
//       messagesBox.toMap().entries
//           .where((entry) => entry.value.chatId == widget.chatId)
//           .map((entry) => entry.key)
//           .toList()
//     );
    
//     // Cache the fetched messages in Hive
//     await Future.wait(
//       messages.map((message) => messagesBox.put(message.messageId, message))
//     );
    
//     setState(() {
//       _messageCache.cacheMessages(
//         widget.chatId,
//         messages,
//         messages.length == _messagesPerPage,
//       );
//       _isLoading = false;
//     });
//   } catch (e) {
//     setState(() => _isLoading = false);
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading messages: $e')),
//       );
//     }
//   }
// }

//   Future<void> _loadMoreMessages() async {
//     if (_isLoading || !_messageCache.hasMore(widget.chatId)) return;

//     setState(() => _isLoading = true);
//     _messageCache.incrementPage(widget.chatId);

//     try {
//       final messages = await chatService.getChatMessages(
//         context: context,
//         chatId: widget.chatId,
//         page: _messageCache.getCurrentPage(widget.chatId),
//         limit: _messagesPerPage,
//       );

//       setState(() {
//         _messageCache.cacheMessages(
//           widget.chatId,
//           messages,
//           messages.length == _messagesPerPage,
//         );
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading more messages: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _refreshMessages() async {
//     _messageCache.clear(widget.chatId);
//     await _loadInitialMessages();
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
//           "sourceId": widget.sourchat,
//           "targetId": widget.reciverId,
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

//   // Future<void> sendMessage(
//   //     String message, String sourceId, String targetId, String path,
//   //     {int? voiceDuration}) async {
//   //   if (message.trim().isEmpty && path.isEmpty) return;

//   //   try {
//   //     final box = await Hive.openBox<ChatData>('chatData');
//   //     ChatData? matchingChatData;
//   //     for (var chatData in box.values) {
//   //       if (chatData.receiverId == widget.reciverId) {
//   //         matchingChatData = chatData;
//   //         break;
//   //       }
//   //     }

//   //     await box.close();

//   //     MessageType messageType =
//   //         path.isNotEmpty ? MessageType.image : MessageType.text;
//   //     String content = path.isNotEmpty ? path : message;
//   //     print('hive chat id -- ${matchingChatData!.receiverId}');
//   //     print('password of hide-----: ${widget.password}');

//   //     if (path.isEmpty &&
//   //         messageType == MessageType.text &&
//   //         message == widget.password) {
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => ChatScreen(
//   //             sourchat: userId,
//   //             chatId: matchingChatData!.chatId,
//   //             password: widget.password,
//   //             hide: true,
//   //             reciverId: widget.reciverId,
//   //           ),
//   //         ),
//   //       );
//   //       return;
//   //     }

//   //     // Prepare media-related data if needed
//   //     String? fileName;
//   //     int? fileSize;
//   //     String? thumbnail;
//   //     int? duration;

//   //     if (path.isNotEmpty) {
//   //       bool isUrl = path.startsWith('http://') || path.startsWith('https://');

//   //       if (isUrl) {
//   //         fileName = path.split('/').last;
//   //         fileSize = null;
//   //       } else {
//   //         File mediaFile = File(path);
//   //         fileName = path.split('/').last;
//   //         fileSize = await mediaFile.length();
//   //       }

//   //       if (messageType == MessageType.video) {
//   //         duration = 0;
//   //         thumbnail = '';
//   //       }
//   //     }
//   //     print('content --- ${content}');

//   //     if (message == "vce*@*#1" || message == "vce*@*#3") {
//   //       try {
//   //         final callStatus =
//   //             message == "vce*@*#1" ? "Voice call started" : "Voice call ended";

//   //         // Emit the voice call message through socket
//   //         socket.emit("message", {
//   //           "message": message,
//   //           "sourceId": sourceId,
//   //           "targetId": targetId,
//   //           "path": "",
//   //           "duration": voiceDuration,
//   //         });

//   //         print('voice content status: ${callStatus}');

//   //         // Create and save the voice call message
//   //         final Message? savedMessage = await chatServices.sendMessages(
//   //           context: context,
//   //           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//   //           content: callStatus,
//   //           messageType: MessageType.audio,
//   //           fileName: fileName,
//   //           fileSize: fileSize,
//   //           duration: voiceDuration,
//   //           thumbnail: thumbnail,
//   //           senderId: sourceId,
//   //           messageId: '',
//   //         );

//   //         if (savedMessage != null) {
//   //           setState(() {
//   //             messages.add(savedMessage);
//   //           });

//   //           // Scroll to bottom
//   //           WidgetsBinding.instance.addPostFrameCallback((_) {
//   //             _scrollToBottom();
//   //           });
//   //         }
//   //       } catch (e) {
//   //         print('Error sending voice call message: $e');
//   //         CustomSnackBar.show(context, 'Failed to send voice call message');
//   //       }
//   //       return;
//   //     }

//   //     if (message == "v-dc*@*#1" || message == "v-dc*@*#3") {
//   //       try {
//   //         final callStatus = message == "v-dc*@*#1"
//   //             ? "Video call started"
//   //             : "Video call ended";

//   //         // Emit the voice call message through socket
//   //         socket.emit("message", {
//   //           "message": message,
//   //           "sourceId": sourceId,
//   //           "targetId": targetId,
//   //           "path": "",
//   //           "duration": voiceDuration,
//   //         });

//   //         print('voice content status: ${callStatus}');

//   //         // Create and save the voice call message
//   //         final Message? savedMessage = await chatServices.sendMessages(
//   //           context: context,
//   //           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//   //           content: callStatus,
//   //           messageType: MessageType.video,
//   //           fileName: fileName,
//   //           fileSize: fileSize,
//   //           duration: voiceDuration,
//   //           thumbnail: thumbnail,
//   //           senderId: sourceId,
//   //           messageId: '',
//   //         );

//   //         if (savedMessage != null) {
//   //           setState(() {
//   //             messages.add(savedMessage);
//   //           });

//   //           // Scroll to bottom
//   //           WidgetsBinding.instance.addPostFrameCallback((_) {
//   //             _scrollToBottom();
//   //           });
//   //         }
//   //       } catch (e) {
//   //         print('Error sending voice call message: $e');
//   //         CustomSnackBar.show(context, 'Failed to send voice call message');
//   //       }
//   //       return;
//   //     }

//   //     // Send message to database
//   //     final Message? savedMessage = await chatServices.sendMessages(
//   //       context: context,
//   //       chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//   //       content: content,
//   //       messageType: messageType,
//   //       fileName: fileName,
//   //       fileSize: fileSize,
//   //       duration: duration,
//   //       thumbnail: thumbnail,
//   //       senderId: sourceId,
//   //       messageId: '',
//   //     );

//   //     if (savedMessage != null) {
//   //       // Emit message through socket for real-time communication
//   //       socket.emit("message", {
//   //         "message": message,
//   //         "sourceId": sourceId,
//   //         "targetId": targetId,
//   //         "path": path,
//   //         "messageId": savedMessage.chatId,
//   //       });

//   //       // Update local state
//   //       setState(() {
//   //         messages.add(savedMessage);
//   //         sendButton = false;
//   //       });

//   //       _messageController.clear();
//   //       _scrollToBottom();
//   //     }
//   //   } catch (e) {
//   //     print('Error sending message: $e');
//   //     CustomSnackBar.show(context, 'Failed to send message');
//   //   }
//   // }


// //   Future<void> sendMessage(
// //     String message, 
// //     String sourceId, 
// //     String targetId, 
// //     String path,
// //     {int? voiceDuration}
// // ) async {
// //   if (message.trim().isEmpty && path.isEmpty) return;

// //   try {
// //     final chatBox = await Hive.openBox<ChatData>('chatData');
// //     final messagesBox = await Hive.openBox<Message>('messages');
    
// //     ChatData? matchingChatData;
// //     for (var chatData in chatBox.values) {
// //       if (chatData.receiverId == widget.reciverId) {
// //         matchingChatData = chatData;
// //         break;
// //       }
// //     }

// //     await chatBox.close();

// //     MessageType messageType = path.isNotEmpty ? MessageType.image : MessageType.text;
// //     String content = path.isNotEmpty ? path : message;

// //     // Handle password check
// //     if (path.isEmpty && 
// //         messageType == MessageType.text && 
// //         message == widget.password) {
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => ChatScreen(
// //             sourchat: userId,
// //             chatId: matchingChatData!.chatId,
// //             password: widget.password,
// //             hide: true,
// //             reciverId: widget.reciverId,
// //           ),
// //         ),
// //       );
// //       return;
// //     }

// //     // Prepare media-related data
// //     String? fileName;
// //     int? fileSize;
// //     String? thumbnail;
// //     int? duration;

// //     if (path.isNotEmpty) {
// //       bool isUrl = path.startsWith('http://') || path.startsWith('https://');
// //       if (isUrl) {
// //         fileName = path.split('/').last;
// //       } else {
// //         File mediaFile = File(path);
// //         fileName = path.split('/').last;
// //         fileSize = await mediaFile.length();
// //       }

// //       if (messageType == MessageType.video) {
// //         duration = 0;
// //         thumbnail = '';
// //       }
// //     }

// //     // Handle voice call messages
// //     if (message == "vce*@*#1" || message == "vce*@*#3") {
// //       final callStatus = message == "vce*@*#1" ? "Voice call started" : "Voice call ended";
      
// //       // Create message object for voice call
// //       final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
// //       final voiceMessage = Message(
// //         messageId: tempMessageId,
// //         chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
// //         senderId: sourceId,
// //         type: MessageType.audio,
// //         content: MessageContent(
// //           text: callStatus,
// //           duration: voiceDuration,
// //           fileName: fileName,
// //           fileSize: fileSize,
// //           thumbnail: thumbnail,
// //         ),
// //         status: MessageStatus.sending,
// //       );

// //       // Store in Hive
// //       await messagesBox.put(tempMessageId, voiceMessage);

// //       // Emit through socket
// //       socket.emit("message", {
// //         "message": message,
// //         "sourceId": sourceId,
// //         "targetId": targetId,
// //         "path": "",
// //         "duration": voiceDuration,
// //       });

// //       try {
// //         // Send to backend
// //         final Message? savedMessage = await chatServices.sendMessages(
// //           context: context,
// //           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
// //           content: callStatus,
// //           messageType: MessageType.audio,
// //           fileName: fileName,
// //           fileSize: fileSize,
// //           duration: voiceDuration,
// //           thumbnail: thumbnail,
// //           senderId: sourceId,
// //           messageId: tempMessageId,
// //         );

// //         if (savedMessage != null) {
// //           // Update message in Hive with server response
// //           await messagesBox.put(savedMessage.messageId, savedMessage);
          
// //           setState(() {
// //             messages.add(savedMessage);
// //           });
// //           _scrollToBottom();
// //         }
// //       } catch (e) {
// //         print('Error sending voice call message: $e');
// //         CustomSnackBar.show(context, 'Failed to send voice call message');
// //       }
// //       return;
// //     }

// //     // Handle video call messages
// //     if (message == "v-dc*@*#1" || message == "v-dc*@*#3") {
// //       final callStatus = message == "v-dc*@*#1" ? "Video call started" : "Video call ended";
      
// //       // Create message object for video call
// //       final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
// //       final videoMessage = Message(
// //         messageId: tempMessageId,
// //         chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
// //         senderId: sourceId,
// //         type: MessageType.video,
// //         content: MessageContent(
// //           text: callStatus,
// //           duration: voiceDuration,
// //           fileName: fileName,
// //           fileSize: fileSize,
// //           thumbnail: thumbnail,
// //         ),
// //         status: MessageStatus.sending,
// //       );

// //       // Store in Hive
// //       await messagesBox.put(tempMessageId, videoMessage);

// //       // Emit through socket
// //       socket.emit("message", {
// //         "message": message,
// //         "sourceId": sourceId,
// //         "targetId": targetId,
// //         "path": "",
// //         "duration": voiceDuration,
// //       });

// //       try {
// //         final Message? savedMessage = await chatServices.sendMessages(
// //           context: context,
// //           chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
// //           content: callStatus,
// //           messageType: MessageType.video,
// //           fileName: fileName,
// //           fileSize: fileSize,
// //           duration: voiceDuration,
// //           thumbnail: thumbnail,
// //           senderId: sourceId,
// //           messageId: tempMessageId,
// //         );

// //         if (savedMessage != null) {
// //           // Update message in Hive with server response
// //           await messagesBox.put(savedMessage.messageId, savedMessage);
          
// //           setState(() {
// //             messages.add(savedMessage);
// //           });
// //           _scrollToBottom();
// //         }
// //       } catch (e) {
// //         print('Error sending video call message: $e');
// //         CustomSnackBar.show(context, 'Failed to send video call message');
// //       }
// //       return;
// //     }

// //     // Handle regular messages
// //     final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
// //     final newMessage = Message(
// //       messageId: tempMessageId,
// //       chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
// //       senderId: sourceId,
// //       type: messageType,
// //       content: MessageContent(
// //         text: messageType == MessageType.text ? content : null,
// //         mediaUrl: messageType != MessageType.text ? content : null,
// //         fileName: fileName,
// //         fileSize: fileSize,
// //         duration: duration,
// //         thumbnail: thumbnail,
// //       ),
// //       status: MessageStatus.sending,
// //     );

// //     // Store in Hive first
// //     await messagesBox.put(tempMessageId, newMessage);

// //     // Update UI immediately
// //     setState(() {
// //       messages.add(newMessage);
// //       sendButton = false;
// //     });

// //     // Send to backend
// //     try {
// //       final Message? savedMessage = await chatServices.sendMessages(
// //         context: context,
// //         chatId: widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
// //         content: content,
// //         messageType: messageType,
// //         fileName: fileName,
// //         fileSize: fileSize,
// //         duration: duration,
// //         thumbnail: thumbnail,
// //         senderId: sourceId,
// //         messageId: tempMessageId,
// //       );

// //       if (savedMessage != null) {
// //         // Update message in Hive with server response
// //         await messagesBox.put(savedMessage.messageId, savedMessage);

// //         // Emit through socket
// //         socket.emit("message", {
// //           "message": message,
// //           "sourceId": sourceId,
// //           "targetId": targetId,
// //           "path": path,
// //           "messageId": savedMessage.chatId,
// //         });

// //         // Update UI with confirmed message
// //         setState(() {
// //           final index = messages.indexWhere((m) => m.messageId == tempMessageId);
// //           if (index != -1) {
// //             messages[index] = savedMessage;
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       // Update message status to failed in Hive
// //       final failedMessage = newMessage.copyWith(status: MessageStatus.failed);
// //       await messagesBox.put(tempMessageId, failedMessage);
      
// //       print('Error sending message: $e');
// //       CustomSnackBar.show(context, 'Failed to send message');
      
// //       // Update UI to show failed status
// //       setState(() {
// //         final index = messages.indexWhere((m) => m.messageId == tempMessageId);
// //         if (index != -1) {
// //           messages[index] = failedMessage;
// //         }
// //       });
// //     }

// //     _messageController.clear();
// //     _scrollToBottom();
    
// //   } catch (e) {
// //     print('Error in message handling: $e');
// //     CustomSnackBar.show(context, 'Error processing message');
// //   }
// // }

// Future<void> sendMessage(
//     String message, 
//     String sourceId, 
//     String targetId, 
//     String path,
//     {int? voiceDuration}
// ) async {
//   if (message.trim().isEmpty && path.isEmpty) return;

//   try {
//     final chatBox = await Hive.openBox<ChatData>('chatData');
//     final messagesBox = await Hive.openBox<Message>('messages');
//     final messageId = const Uuid().v4();;
    
//     ChatData? matchingChatData;
//     for (var chatData in chatBox.values) {
//       if (chatData.receiverId == widget.reciverId) {
//         matchingChatData = chatData;
//         break;
//       }
//     }

//     await chatBox.close();

//     MessageType messageType = path.isNotEmpty ? MessageType.image : MessageType.text;
//     String content = path.isNotEmpty ? path : message;

//     // Handle password check
//     if (path.isEmpty && 
//         messageType == MessageType.text && 
//         message == widget.password) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatScreen(
//             sourchat: userId,
//             chatId: matchingChatData!.chatId,
//             password: widget.password,
//             hide: true,
//             reciverId: widget.reciverId,
//           ),
//         ),
//       );
//       return;
//     }

//     // Prepare media-related data
//     String? fileName;
//     int? fileSize;
//     String? thumbnail;
//     int? duration;

//     if (path.isNotEmpty) {
//       bool isUrl = path.startsWith('http://') || path.startsWith('https://');
//       if (isUrl) {
//         fileName = path.split('/').last;
//       } else {
//         File mediaFile = File(path);
//         fileName = path.split('/').last;
//         fileSize = await mediaFile.length();
//       }

//       if (messageType == MessageType.video) {
//         duration = 0;
//         thumbnail = '';
//       }
//     }

//     // Generate a message ID that will be used throughout the process
//     // final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//     final chatId = widget.chatId.isEmpty ? fetchedChatId : widget.chatId;

//     // Handle voice call messages
//     if (message == "vce*@*#1" || message == "vce*@*#3") {
//       final callStatus = message == "vce*@*#1" ? "Voice call started" : "Voice call ended";
      
//       final voiceMessage = Message(
//         messageId: messageId,
//         chatId: chatId,
//         senderId: sourceId,
//         type: MessageType.audio,
//         content: MessageContent(
//           text: callStatus,
//           duration: voiceDuration,
//           fileName: fileName,
//           fileSize: fileSize,
//           thumbnail: thumbnail,
//         ),
//         status: MessageStatus.sending,
//       );

//       // Store initial message
//       await messagesBox.put(messageId, voiceMessage);
//       setState(() => messages.add(voiceMessage));

//       socket.emit("message", {
//         "message": message,
//         "sourceId": sourceId,
//         "targetId": targetId,
//         "path": "",
//         "duration": voiceDuration,
//       });

//       try {
//         final Message? savedMessage = await chatServices.sendMessages(
//           context: context,
//           chatId: chatId,
//           content: callStatus,
//           messageType: MessageType.audio,
//           fileName: fileName,
//           fileSize: fileSize,
//           duration: voiceDuration,
//           thumbnail: thumbnail,
//           senderId: sourceId,
//           messageId: messageId,
//         );

//         if (savedMessage != null) {
//           // Update existing message
//           await messagesBox.put(messageId, savedMessage);
//           setState(() {
//             final index = messages.indexWhere((m) => m.messageId == messageId);
//             if (index != -1) {
//               messages[index] = savedMessage;
//             }
//           });
//         }
//       } catch (e) {
//         print('Error sending voice call message: $e');
//         final failedMessage = voiceMessage.copyWith(status: MessageStatus.failed);
//         await messagesBox.put(messageId, failedMessage);
//         CustomSnackBar.show(context, 'Failed to send voice call message');
//       }
//       _scrollToBottom();
//       return;
//     }

//     // Handle video call messages
//     if (message == "v-dc*@*#1" || message == "v-dc*@*#3") {
//       final callStatus = message == "v-dc*@*#1" ? "Video call started" : "Video call ended";
      
//       final videoMessage = Message(
//         messageId: messageId,
//         chatId: chatId,
//         senderId: sourceId,
//         type: MessageType.video,
//         content: MessageContent(
//           text: callStatus,
//           duration: voiceDuration,
//           fileName: fileName,
//           fileSize: fileSize,
//           thumbnail: thumbnail,
//         ),
//         status: MessageStatus.sending,
//       );

//       // Store initial message
//       await messagesBox.put(messageId, videoMessage);
//       setState(() => messages.add(videoMessage));

//       socket.emit("message", {
//         "message": message,
//         "sourceId": sourceId,
//         "targetId": targetId,
//         "path": "",
//         "duration": voiceDuration,
//       });

//       try {
//         final Message? savedMessage = await chatServices.sendMessages(
//           context: context,
//           chatId: chatId,
//           content: callStatus,
//           messageType: MessageType.video,
//           fileName: fileName,
//           fileSize: fileSize,
//           duration: voiceDuration,
//           thumbnail: thumbnail,
//           senderId: sourceId,
//           messageId: messageId,
//         );

//         if (savedMessage != null) {
//           // Update existing message
//           await messagesBox.put(messageId, savedMessage);
//           setState(() {
//             final index = messages.indexWhere((m) => m.messageId == messageId);
//             if (index != -1) {
//               messages[index] = savedMessage;
//             }
//           });
//         }
//       } catch (e) {
//         print('Error sending video call message: $e');
//         final failedMessage = videoMessage.copyWith(status: MessageStatus.failed);
//         await messagesBox.put(messageId, failedMessage);
//         CustomSnackBar.show(context, 'Failed to send video call message');
//       }
//       _scrollToBottom();
//       return;
//     }

//     // Handle regular messages
//     final newMessage = Message(
//       messageId: messageId,
//       chatId: chatId,
//       senderId: sourceId,
//       type: messageType,
//       content: MessageContent(
//         text: messageType == MessageType.text ? content : null,
//         mediaUrl: messageType != MessageType.text ? content : null,
//         fileName: fileName,
//         fileSize: fileSize,
//         duration: duration,
//         thumbnail: thumbnail,
//       ),
//       status: MessageStatus.sending,
//     );

//     // Store initial message
//     await messagesBox.put(messageId, newMessage);
//     setState(() {
//       messages.add(newMessage);
//       sendButton = false;
//     });

//     socket.emit("message", {
//       "message": message,
//       "sourceId": sourceId,
//       "targetId": targetId,
//       "path": path,
//       "tempMessageId": messageId, // Send the pre-generated ID
//     });

//     try {
//       final Message? savedMessage = await chatServices.sendMessages(
//         context: context,
//         chatId: chatId,
//         content: content,
//         messageType: messageType,
//         fileName: fileName,
//         fileSize: fileSize,
//         duration: duration,
//         thumbnail: thumbnail,
//         senderId: sourceId,
//         messageId: messageId,
//       );

//       if (savedMessage != null) {
//         // Update the message in Hive with any additional server data
//         await messagesBox.put(messageId, savedMessage);
//         setState(() {
//           final index = messages.indexWhere((m) => m.messageId == messageId);
//           if (index != -1) {
//             messages[index] = savedMessage;
//           }
//         });
//       }
//     } catch (e) {
//       final failedMessage = newMessage.copyWith(status: MessageStatus.failed);
//       await messagesBox.put(messageId, failedMessage);
      
//       print('Error sending message: $e');
//       CustomSnackBar.show(context, 'Failed to send message');
      
//       // setState(() {
//       //   final index = messages.indexWhere((m) => m.messageId == messageId);
//       //   if (index != -1) {
//       //     messages[index] = failedMessage;
//       //   }
//       // });
//     }

//     _messageController.clear();
//     _scrollToBottom();
    
//   } catch (e) {
//     print('Error in message handling: $e');
//     CustomSnackBar.show(context, 'Error processing message');
//   }
// }


//   void setMessage(String type, String message, String path,
//       {String? messageId, int? voiceDuration}) {
//     String fullPath = '';
//     if (path.isNotEmpty) {
//       // Only set fullPath if it starts with Cloudinary URL or has http prefix
//       fullPath = path.startsWith('http://res.cloudinary.com') ||
//               path.startsWith('http')
//           ? path
//           : '$BASE_URL/uploads/$path';
//     }
//     // MessageType messageType =
//     //     path.isNotEmpty ? MessageType.image : MessageType.text;
//     MessageType messageType;
//     String displayText;

//     if (message == 'vce*@*#1') {
//       messageType = MessageType.audio;
//       displayText = 'Voice call started';
//     } else if (message == 'vce*@*#3') {
//       messageType = MessageType.audio;
//       displayText = 'Voice call ended';
//     } else if (message == 'v-dc*@*#1') {
//       messageType = MessageType.video;
//       displayText = 'Video call started';
//     } else if (message == 'v-dc*@*#3') {
//       messageType = MessageType.video;
//       displayText = 'Video call ended';
//     } else {
//       messageType = path.isNotEmpty ? MessageType.image : MessageType.text;
//       displayText = message;
//     }

//     // Determine the correct sender ID based on the message type
//     String senderId;
//     if (type == "source") {
//       senderId = widget.sourchat; // Current user is sender
//     } else if (type == "destination") {
//       senderId = widget.reciverId; // Other user is sender
//     } else {
//       throw ArgumentError('Invalid message type');
//     }

//     print('media url --- ${messageType}  and  ${displayText}');
//     Message newMessage = Message(
//       chatId: widget.chatId,
//       senderId: senderId,
//       type: messageType,
//       content: MessageContent(
//         text: displayText,
//         mediaUrl:
//             path.startsWith('http://res.cloudinary.com') ? fullPath : null,
//         fileName: path.isNotEmpty ? path.split('/').last : null,
//         fileSize: null,
//         duration: voiceDuration,
//         contactInfo: null,
//       ),
//       replyTo: null,
//       forwardedFrom: null,
//       readBy: [],
//       deliveredTo: [],
//       status:
//           type == "source" ? MessageStatus.sending : MessageStatus.delivered,
//       createdAt: DateTime.now(),
//       reactions: [],
//       isDeleted: false,
//       deletedFor: [],
//       messageId: messageId ?? '',
//     );

//     setState(() {
//       messages.add(newMessage);
//     });

//     // Auto-scroll to bottom when new message is added
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final user = userProvider.user;
//     final messages = _messageCache.getCachedMessages(
//       widget.chatId.isEmpty ? fetchedChatId : widget.chatId,
//     );
//     String? previousMessageDate;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _showAttachments = false;
//         });
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginScreen()),
//               );
//             },
//           ),
//           title: Row(
//             children: [
//               Container(
//                 height: 35,
//                 width: 35,
//                 decoration: const BoxDecoration(
//                     color: Colors.amberAccent, shape: BoxShape.circle),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${widget.reciverId}',
//                         style: const TextStyle(
//                             fontFamily: 'Medium',
//                             fontSize: 14,
//                             color: Colors.black),
//                       ),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 15,
//                         color: Colors.grey,
//                       )
//                     ],
//                   ),
//                   const Text(
//                     'shivprasad_rahulwad',
//                     style: TextStyle(
//                         fontFamily: 'Medium',
//                         fontSize: 12,
//                         color: Colors.black),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               onPressed: () async {
//                 try {
//                   await sendMessage(
//                       "vce*@*#1", widget.sourchat, widget.reciverId, "");

//                   setMessage("source", "vce*@*#1", "");
//                   const Text('Boice call started-- ');

//                   socket.emit("message", {
//                     "sourceId": widget.sourchat,
//                     "targetId": widget.reciverId,
//                     "message": "vce*@*#1",
//                     "path": "",
//                   });
//                   print('Boice emitted-- ');
//                   final int? duration = await Navigator.push<int>(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VoiceCallScreen(
//                         channelName: widget.chatId,
//                         appId: '20810c5544884126b8ffbbe4e0453736',
//                         callerName: widget.sourchat,
//                         callerAvatar: 'assets/images/shrutika.png',
//                       ),
//                     ),
//                   );

//                   print("Call duration: $duration seconds");

//                   setMessage("source", "vce*@*#3", "");
//                   await sendMessage(
//                       "vce*@*#3", widget.sourchat, widget.reciverId, "",
//                       voiceDuration: duration);
//                 } catch (e) {
//                   print('Error handling voice call: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Error occurred during voice call')),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.call),
//             ),
//             IconButton(
//               onPressed: () async {
//                 try {
//                   await sendMessage(
//                       "v-dc*@*#1", widget.sourchat, widget.reciverId, "");
//                   setMessage("source", "v-dc*@*#1", "");

//                   socket.emit("message", {
//                     "sourceId": widget.sourchat,
//                     "targetId": widget.reciverId,
//                     "message": "v-dc*@*#1",
//                     "path": "",
//                   });

//                   int? duration = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VideoCallScreen(
//                         channelName: widget.chatId,
//                         callerName: userId,
//                         callerAvatar: 'assets/images/shrutika.png',
//                       ),
//                     ),
//                   );
//                   print("Call duration: $duration seconds");
//                   setMessage("source", "v-dc*@*#3", "");
//                   await sendMessage(
//                       "v-dc*@*#3", widget.sourchat, widget.reciverId, "",
//                       voiceDuration: 0);
//                 } catch (e) {
//                   print('Error handling video call: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Error occurred during video call')),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.video_call),
//             ),
//             Builder(
//               builder: (context) => IconButton(
//                 icon: const Icon(Icons.more_vert),
//                 onPressed: () {
//                   final RenderBox button =
//                       context.findRenderObject() as RenderBox;
//                   final RenderBox overlay = Overlay.of(context)
//                       .context
//                       .findRenderObject() as RenderBox;
//                   final Offset buttonPosition =
//                       button.localToGlobal(Offset.zero, ancestor: overlay);
//                   final double screenWidth = overlay.size.width;
//                   const double widgetWidth = 236.0;
//                   final double xOffset = screenWidth - widgetWidth - 2;

//                   ChatScreenActionWidget.show(
//                     context,
//                     position: Offset(xOffset, buttonPosition.dy + 35),
//                     chatId: widget.chatId,  
//                     hide: widget.hide,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         body: RefreshIndicator(
//             onRefresh: _refreshMessages,
//             child: Stack(
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height,
//                   width: MediaQuery.of(context).size.width,
//                   child: Container(
//                     color: GlobalVariables.backgroundColor,
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             reverse: true,
//                             controller: _scrollController,
//                             itemCount: messages.length + (_isLoading ? 1 : 0),
//                             itemBuilder: (context, index) {
//                               if (index == messages.length) {
//                                 return const Center(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: CircularProgressIndicator(),
//                                   ),
//                                 );
//                               }

//                               final message = messages[index];
//                               final isCurrentUser =
//                                   message.senderId == widget.sourchat;
//                               final messageDate = DateFormat('yyyy-MM-dd')
//                                   .format(message.createdAt);

//                               bool showDateHeader = false;
//                               if (previousMessageDate == null ||
//                                   previousMessageDate != messageDate) {
//                                 showDateHeader = true;
//                                 previousMessageDate = messageDate;
//                               }

//                               return Column(
//                                 children: [
//                                   const SizedBox(height: 20),
//                                   if (showDateHeader)
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 8.0),
//                                       child: Text(
//                                         DateFormat('MMM dd, yyyy')
//                                             .format(message.createdAt),
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                     ),
//                                   // Check message type and render appropriate widget
//                                   if (isCurrentUser) ...[
//                                     // Current user's messages
//                                     if (message.type == MessageType.text)
//                                       OwnMessageCard(
//                                         message: message.content.text ?? '',
//                                         time: message.createdAt,
//                                         isRead: message.status ==
//                                             MessageStatus.read,
//                                         messageId: message.messageId,    
//                                       )
//                                     else if (message.type == MessageType.image)
//                                       OwnImageCard(
//                                         path: message.content.mediaUrl ?? '',
//                                         time: message.createdAt,
//                                         isRead: message.status ==
//                                             MessageStatus.read,
//                                       )
//                                     else if (message.type == MessageType.audio)
//                                       OwnVoiceCallChatWidget(
//                                         duration: message.content.duration ?? 0,
//                                         message: message.content.mediaUrl ?? '',
//                                         time: DateFormat('hh:mm a')
//                                             .format(message.createdAt),
//                                         chatId: widget.chatId,
//                                       )
//                                     else if (message.type == MessageType.video)
//                                       OwnVideoCallChatWidget(
//                                         message: message.content.mediaUrl ?? '',
//                                         chatId: widget.chatId,
//                                         time: DateFormat('hh:mm a')
//                                             .format(message.createdAt),
//                                         duration: message.content.duration ?? 0,
//                                       )
//                                   ] else ...[
//                                     // Other user's messages
//                                     if (message.type == MessageType.text)
//                                       ReplyMessageCard(
//                                         message: message.content.text ?? '',
//                                         time: message.createdAt,
//                                       )
//                                     else if (message.type == MessageType.image)
//                                       ReplyImageCard(
//                                         path: message.content.mediaUrl ?? '',
//                                         time: message.createdAt,
//                                       )
//                                     else if (message.type == MessageType.audio)
//                                       ReplyVoiceCallChatWidget(
//                                         duration: message.content.duration ?? 0,
//                                         time: DateFormat('hh:mm a')
//                                             .format(message.createdAt),
//                                         message: message.content.mediaUrl ?? '',
//                                         chatId: widget.chatId,
//                                       )
//                                     else if (message.type == MessageType.video)
//                                       ReplyVideoCallChatWidget(
//                                         message: message.content.mediaUrl ?? '',
//                                         chatId: widget.chatId,
//                                         time: DateFormat('hh:mm a')
//                                             .format(message.createdAt),
//                                         duration: message.content.duration ?? 0,
//                                       )
//                                   ],
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                         ChatInputWidget(
//                           onSendMessage: sendMessage,
//                           sourchat: widget.sourchat,
//                           receiverId: widget.reciverId,
//                           scrollController: _scrollController,
//                           onAttachmentPressed: () {
//                             setState(() {
//                               _showAttachments = true;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (_showAttachments)
//                   Positioned(
//                     bottom:
//                         80, // Adjust this value based on your ChatInputWidget height
//                     child: ChatAttachmentMenuWidget(
//                       onClose: () {
//                         setState(() {
//                           _showAttachments = false;
//                         });
//                       },
//                     ),
//                   ),
//               ],
//             )),
//       ),
//     );
//   }
// }

















 // Expanded(
                        //   child: ListView.builder(
                        //     shrinkWrap: true,
                        //     reverse: true,
                        //     controller: _scrollController,
                        //     itemCount: messages.length + (_isLoading ? 1 : 0),
                        //     itemBuilder: (context, index) {
                        //       if (index == messages.length) {
                        //         // return Container(height: 70);
                        //         return const Center(
                        //           child: Padding(
                        //             padding: EdgeInsets.all(8.0),
                        //             child: CircularProgressIndicator(),
                        //           ),
                        //         );
                        //       }

                        //       final message = messages[index];
                        //       final isCurrentUser =
                        //           message.senderId == widget.sourchat;
                        //       final messageDate = DateFormat('yyyy-MM-dd')
                        //           .format(message.createdAt);

                        //       bool showDateHeader = false;
                        //       if (previousMessageDate == null ||
                        //           previousMessageDate != messageDate) {
                        //         showDateHeader = true;
                        //         previousMessageDate = messageDate;
                        //       }

                        //       return Column(
                        //         children: [
                        //           SizedBox(height: 20),
                        //           if (showDateHeader)
                        //             Padding(
                        //               padding: const EdgeInsets.symmetric(
                        //                   vertical: 8.0),
                        //               child: Text(
                        //                 DateFormat('MMM dd, yyyy')
                        //                     .format(message.createdAt),
                        //                 style: TextStyle(
                        //                   fontSize: 14,
                        //                   fontWeight: FontWeight.bold,
                        //                   color: Colors.grey[600],
                        //                 ),
                        //               ),
                        //             ),
                        //           if (isCurrentUser)
                        //             OwnMessageCard(
                        //               message: message.content.text ?? '',
                        //               time: message.createdAt,
                        //               isRead:
                        //                   message.status == MessageStatus.read,
                        //             ),
                        //     if (isCurrentUser)
                        //     OwnImageCard(
                        //       path: message.content.mediaUrl ?? '',
                        //       time: message.createdAt,
                        //     )
                        //           else
                        //             ReplyMessageCard(
                        //               message: message.content.text ?? '',
                        //               time: message.createdAt,
                        //             ),
                        //         ],
                        //       );
                        //     },
                        //   ),
                        // ),














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



