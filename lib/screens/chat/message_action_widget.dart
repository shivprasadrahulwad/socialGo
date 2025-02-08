import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:social/model/message.dart';
import 'package:social/screens/services/chat_services.dart';

// class MessageActionWidget {
//   static Future<void> _deleteMessage(
//       BuildContext context, String messageId) async {
//     try {
//       // Delete from server
//       final messagesBox = await Hive.openBox<Message>('messages');
//       await messagesBox.delete(messageId);
//       await messagesBox.close();
//       await ChatServices().deleteMessage(context: context, messageId: messageId);
//       print('Server message deletion called for messageId: $messageId');
      
//       print('Message deleted from Hive for messageId: $messageId');
//     } catch (e) {
//       print('Error during message deletion: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete message')),
//       );
//     }
//   }

//   static void show(
//     BuildContext context, {
//     required Offset position,
//     required String messageId,
//     required bool hide,
//     required String messageType,
//     required String message,
//   }) {
//     final overlay = Overlay.of(context);
//     OverlayEntry? overlayEntry;
//     final isMediaMessage = messageType == 'video' || messageType == 'voice';
//     final isImageMessage = messageType == 'image';

//     overlayEntry = OverlayEntry(
//       builder: (context) => Stack(
//         children: [
//           Positioned.fill(
//             child: GestureDetector(
//               onTap: () => overlayEntry?.remove(),
//               behavior: HitTestBehavior.opaque,
//               child: Container(
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//           Positioned(
//             left: position.dx,
//             top: position.dy,
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 width: 236,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 margin: const EdgeInsets.only(top: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildActionItem(
//                       icon: Icons.reply,
//                       text: 'Reply',
//                       onTap: () {
//                         overlayEntry?.remove();
//                       },
//                     ),
//                     // Forward for non-media messages
//                     if (!isMediaMessage)
//                       _buildActionItem(
//                         icon: Icons.forward,
//                         text: 'Forward',
//                         onTap: () {
//                           overlayEntry?.remove();
//                         },
//                       ),
//                     // Show Save for images, Copy for text messages
//                     if (!isMediaMessage && !isImageMessage)
//                       _buildActionItem(
//                         icon: Icons.copy,
//                         text: 'Copy',
//                         onTap: () async {
//                           await Clipboard.setData(ClipboardData(text: message));
//                           overlayEntry?.remove();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Message copied to clipboard')),
//                           );
//                         },
//                       ),
//                     if (isImageMessage)
//                       _buildActionItem(
//                         icon: Icons.download,
//                         text: 'Save',
//                         onTap: () {
//                           // Add your save image logic here
//                           overlayEntry?.remove();
//                         },
//                       ),
//                     // Delete for you is always shown
//                     _buildActionItem(
//                       icon: Icons.delete,
//                       text: 'Delete for you',
//                       onTap: () {
//                         overlayEntry?.remove();
//                       },
//                     ),
//                     // Unsend only for non-media messages
//                     if (!isMediaMessage)
//                       _buildActionItem(
//                         icon: Icons.undo,
//                         text: 'Unsend',
//                         iconColor: Colors.red,
//                         textColor: Colors.red,
//                         onTap: () async {
//                           print('message to delete-- ${messageId}');
//                           await _deleteMessage(context, messageId);
//                           overlayEntry?.remove();
//                         },
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     overlay.insert(overlayEntry);
//   }

//   static Widget _buildActionItem({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     Color? iconColor,
//     Color? textColor,
//   }) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: iconColor ?? Colors.black54,
//               size: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               text,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: textColor ?? Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class MessageActionWidget {
  static Future<void> _saveImageToGallery(BuildContext context, String message) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to save images')),
        );
        return;
      }

      // Create SocialGo directory if it doesn't exist
      final directory = Directory('/storage/emulated/0/Pictures/SocialGo');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(message).isNotEmpty ? path.extension(message) : '.jpg';
      final fileName = 'socialgo_$timestamp$extension';
      final filePath = path.join(directory.path, fileName);

      // Download and save the image
      final response = await http.get(Uri.parse(message));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Notify media scanner to make image visible in gallery
        await _scanFile(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to Gallery/SocialGo')),
        );
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  static Future<void> _scanFile(String filePath) async {
    try {
      // For Android: Use MediaScanner to make the file visible in gallery
      if (Platform.isAndroid) {
        await Future.wait([
          Platform.isAndroid
              ? Process.run('am', ['broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE', '-d', 'file://$filePath'])
              : Future.value(),
        ]);
      }
    } catch (e) {
      print('Error scanning file: $e');
    }
  }

  static Future<void> _deleteMessage(
      BuildContext context, String messageId) async {
    try {
      // Delete from server
      final messagesBox = await Hive.openBox<Message>('messages');
      await messagesBox.delete(messageId);
      await messagesBox.close();
      await ChatServices().deleteMessage(context: context, messageId: messageId);
      print('Server message deletion called for messageId: $messageId');
      
      print('Message deleted from Hive for messageId: $messageId');
    } catch (e) {
      print('Error during message deletion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete message')),
      );
    }
  }

  

  static void show(
    BuildContext context, {
    required Offset position,
    required String messageId,
    required bool hide,
    required String messageType,
    required String message,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    final isMediaMessage = messageType == 'video' || messageType == 'voice';
    final isImageMessage = messageType == 'image';

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry?.remove(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 236,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionItem(
                      icon: Icons.reply,
                      text: 'Reply',
                      onTap: () {
                        overlayEntry?.remove();
                      },
                    ),
                    // Forward for non-media messages
                    if (!isMediaMessage)
                      _buildActionItem(
                        icon: Icons.forward,
                        text: 'Forward',
                        onTap: () {
                          overlayEntry?.remove();
                        },
                      ),
                    // Show Save for images, Copy for text messages
                    if (!isMediaMessage && !isImageMessage)
                      _buildActionItem(
                        icon: Icons.copy,
                        text: 'Copy',
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: message));
                          overlayEntry?.remove();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Message copied to clipboard')),
                          );
                        },
                      ),
                    if (isImageMessage)
                      _buildActionItem(
                        icon: Icons.download,
                        text: 'Save',
                        onTap: () async {
                          overlayEntry?.remove();
                          await _saveImageToGallery(context, message);
                        },
                      ),
                    // Delete for you is always shown
                    _buildActionItem(
                      icon: Icons.delete,
                      text: 'Delete for you',
                      onTap: () {
                        overlayEntry?.remove();
                      },
                    ),
                    // Unsend only for non-media messages
                    if (!isMediaMessage)
                      _buildActionItem(
                        icon: Icons.undo,
                        text: 'Unsend',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () async {
                          print('message to delete-- ${messageId}');
                          await _deleteMessage(context, messageId);
                          overlayEntry?.remove();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

  static Widget _buildActionItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.black54,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}