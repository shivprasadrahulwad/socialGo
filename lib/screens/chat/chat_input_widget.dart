import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:social/model/message.dart';
import 'package:social/screens/chat/camera_screen.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:uuid/uuid.dart';

// class ChatInputWidget extends StatefulWidget {
//   final Function(String message, String sourchat, String receiverId, String attachmentPath) onSendMessage;
//   final String sourchat;
//   final String receiverId;
//   final ScrollController scrollController;
//   final VoidCallback onAttachmentPressed; // Added this line

//   const ChatInputWidget({
//     Key? key,
//     required this.onSendMessage,
//     required this.sourchat,
//     required this.receiverId,
//     required this.scrollController,
//     required this.onAttachmentPressed, // Added this line
//   }) : super(key: key);

//   @override
//   State<ChatInputWidget> createState() => _ChatInputWidgetState();
// }

// class _ChatInputWidgetState extends State<ChatInputWidget> {
//   final TextEditingController _messageController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   bool sendButton = false;
//   bool _showEmojiPicker = false;
//   int popTime = 0;
//   XFile? file;

//   void _toggleEmojiPicker() {
//     setState(() {
//       _showEmojiPicker = !_showEmojiPicker;
//     });
//   }

//   void _scrollToBottom() {
//     widget.scrollController.animateTo(
//       widget.scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//     void _onEmojiSelected(Category? category, Emoji emoji) {
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

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (_showEmojiPicker)
//           SizedBox(
//             height: 300,
//             child: EmojiPicker(
//               onEmojiSelected: (Category? category, Emoji emoji) {
//                 _onEmojiSelected(category, emoji);
//               },
//               config: Config(
//                 columns: 7,
//                 emojiSizeMax: 32 *
//                     (foundation.defaultTargetPlatform == TargetPlatform.iOS
//                         ? 1.30
//                         : 1.0),
//                 verticalSpacing: 0,
//                 horizontalSpacing: 0,
//                 gridPadding: EdgeInsets.zero,
//                 initCategory: Category.SMILEYS,
//                 bgColor: Colors.white,
//                 indicatorColor: Colors.blue,
//                 iconColor: Colors.grey,
//                 iconColorSelected: Colors.blue,
//                 backspaceColor: Colors.blue,
//                 recentsLimit: 28,
//                 replaceEmojiOnLimitExceed: false,
//                 noRecents: const Text(
//                   'No Recent Emojis',
//                   style: TextStyle(fontSize: 20, color: Colors.black26),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//         Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: Colors.amberAccent,
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 20),
//           Expanded(
//             child: TextFormField(
//               controller: _messageController,
//               maxLines: 5,
//               minLines: 1,
//               textAlignVertical: TextAlignVertical.center,
//               keyboardType: TextInputType.multiline,
//               focusNode: FocusNode()
//                 ..addListener(() {
//                   if (FocusScope.of(context).hasFocus) {
//                     setState(() {
//                       _showEmojiPicker = false;
//                     });
//                   }
//                 }),
//               onChanged: (value) {
//                 setState(() {
//                   sendButton = value.isNotEmpty;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Message...',
//                 border: InputBorder.none,
//                 prefixIcon: IconButton(
//                   onPressed: _toggleEmojiPicker,
//                   icon: Icon(
//                     _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
//                   ),
//                 ),
//                 suffixIcon: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           popTime = 2;
//                         });
//                       },
//                       icon: const Icon(Icons.camera),
//                     ),
//                     IconButton(
//                       onPressed: widget.onAttachmentPressed, // Updated this line
//                       icon: const Icon(Icons.attach_file),
//                     ),
//                     IconButton(
//                       onPressed: () async {
//                         setState(() {
//                           popTime = 1;
//                         });
//                         file = await _picker.pickImage(source: ImageSource.gallery);
//                       },
//                       icon: const Icon(Icons.browse_gallery),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//               bottom: 8,
//               right: 2,
//               left: 2,
//             ),
//             child: CircleAvatar(
//               radius: 25,
//               backgroundColor: const Color(0xFF128C7E),
//               child: IconButton(
//                 icon: Icon(
//                   sendButton ? Icons.send : Icons.mic,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   if (sendButton) {
//                     _scrollToBottom();
//                     widget.onSendMessage(
//                       _messageController.text,
//                       widget.sourchat,
//                       widget.receiverId,
//                       "",
//                     );
//                     _messageController.clear();
//                     setState(() {
//                       sendButton = false;
//                     });
//                   }
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     )
//       ],
//     );
//   }
// }

class ChatInputWidget extends StatefulWidget {
  final Function(String message, String sourchat, String receiverId,
      String attachmentPath) onSendMessage;
  final String sourchat;
  final String receiverId;
  final String? replyingMessageId;
  final String? replyingMessageContent;
  final ScrollController scrollController;
  final VoidCallback onAttachmentPressed;
  final Function(String) onImageSend; 
  final Function(String) onVideoSend;
  

  const ChatInputWidget({
    Key? key,
    required this.onSendMessage,
    required this.onImageSend,
    required this.sourchat,
    required this.receiverId,
    required this.scrollController,
    required this.onAttachmentPressed,
    this.replyingMessageContent,
    this.replyingMessageId,
    required this.onVideoSend,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool sendButton = false;
  bool _showEmojiPicker = false;
  int popTime = 0;
  XFile? file;

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
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

  void _scrollToBottom() {
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleImagePick() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image quality
      );

      if (pickedFile != null) {
        final cloudinaryUrl = await _uploadToCloudinary(pickedFile.path);
        print('cloudinary url ----: ${cloudinaryUrl}');
        // Send the image message directly
        widget.onSendMessage(
          "", // Empty message text since we're sending an image
          widget.sourchat,
          widget.receiverId,
          cloudinaryUrl!,
        );

        _scrollToBottom();
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error picking image')),
        );
      }
    }
  }

  // In _ChatInputWidgetState class, add this function:
  Future<String?> _uploadToCloudinary(String imagePath) async {
    try {
      final cloudinary = CloudinaryPublic('denfgaxvg', 'uszbstnu');

      CloudinaryResponse res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath, folder: 'chat_images'),
      );

      return res.secureUrl;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading image')),
        );
      }
      return null;
    }
  }


void _handleCameraImageVideo() async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CameraScreen(
        onImageSend: (String path) async {
          final cloudinaryUrl = await _uploadToCloudinary(path);
          if (cloudinaryUrl != null) {
            widget.onSendMessage(
              "",
              widget.sourchat,
              widget.receiverId,
              cloudinaryUrl,
            );
            _scrollToBottom();
          }
        },
        onVideoSend: (String path) async {
          final cloudinaryUrl = await _uploadToCloudinary(path);
          if (cloudinaryUrl != null) {
            widget.onSendMessage(
              "",
              widget.sourchat,
              widget.receiverId,
              cloudinaryUrl,
            );
            _scrollToBottom();
          }
        },
      ),
    ),
  );
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showEmojiPicker)
          SizedBox(
            height: 300,
            child: EmojiPicker(
              onEmojiSelected: _onEmojiSelected,
              config: Config(
                columns: 7,
                emojiSizeMax: 32 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.30
                        : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                initCategory: Category.SMILEYS,
                bgColor: Colors.white,
                indicatorColor: Colors.blue,
                iconColor: Colors.grey,
                iconColorSelected: Colors.blue,
                backspaceColor: Colors.blue,
                recentsLimit: 28,
                replaceEmojiOnLimitExceed: false,
                noRecents: const Text(
                  'No Recent Emojis',
                  style: TextStyle(fontSize: 20, color: Colors.black26),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.amberAccent,
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  minLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  focusNode: FocusNode()
                    ..addListener(() {
                      if (FocusScope.of(context).hasFocus) {
                        setState(() {
                          _showEmojiPicker = false;
                        });
                      }
                    }),
                  onChanged: (value) {
                    setState(() {
                      sendButton = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      onPressed: _toggleEmojiPicker,
                      icon: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard
                            : Icons.emoji_emotions,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _handleCameraImageVideo,
                          icon: const Icon(Icons.camera),
                        ),
                        IconButton(
                          onPressed: widget.onAttachmentPressed,
                          icon: const Icon(Icons.attach_file),
                        ),
                        IconButton(
                          onPressed: _handleImagePick,
                          icon: const Icon(Icons.browse_gallery),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  right: 2,
                  left: 2,
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF128C7E),
                  child: IconButton(
                    icon: Icon(
                      sendButton ? Icons.send : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (sendButton) {
                        _scrollToBottom();
                        widget.onSendMessage(
                          _messageController.text,
                          widget.sourchat,
                          widget.receiverId,
                          "",
                        );
                        _messageController.clear();
                        setState(() {
                          sendButton = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
