// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:agora_uikit/controllers/rtc_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/call/video_call_screen.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/chat/message_action_widget.dart';

// class ReplyVideoCallChatWidget extends StatefulWidget {
//   final int duration; // Pass the duration dynamically
//   final String time; // Pass the time dynamically
//   final String message;
//   final String chatId;

//   const ReplyVideoCallChatWidget({
//     Key? key,
//     required this.duration,
//     required this.time,
//     required this.message,
//     required this.chatId,
//   }) : super(key: key);

//   @override
//   State<ReplyVideoCallChatWidget> createState() => _ReplyVideoCallChatWidgetState();
// }

// class _ReplyVideoCallChatWidgetState extends State<ReplyVideoCallChatWidget> {
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return Align(
//       alignment: Alignment.centerLeft, // Align to the left side
//       child: Padding(
//         padding: EdgeInsets.only(left: 10),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Container for video call information
//             Container(
//               width: screenWidth * 0.6,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: widget.duration != 0 || widget.message == 'Video call started' ? Colors.grey : Colors.red,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Icon(
//                                 widget.message == 'Video call ended'
//                                     ? Icons.call_end_outlined
//                                     : Icons.call,
//                                 color: Colors.white,
//                                 size: 30,
//                               ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (widget.message == 'Video call started')
//                         const Text(
//                           'Video call started',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       if (widget.message == 'Video call ended')
//                         const Text(
//                           'Video call ended',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${widget.time}', // Display the passed duration dynamically
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               if (widget.duration == 0 && widget.message == 'Video call ended')
//               SizedBox(height: 10,),
//               if (widget.duration == 0 && widget.message == 'Video call ended')
//                           Container(
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: const Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Center(
//                                 child: Text(
//                                   'Call back',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                 ],
//               )
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



class ReplyVideoCallChatWidget extends StatefulWidget {
  final int duration;
  final String time;
  final String message;
  final String chatId;
  final String messageId;

  const ReplyVideoCallChatWidget({
    Key? key,
    required this.duration,
    required this.time,
    required this.message,
    required this.chatId,
    required this.messageId,
  }) : super(key: key);

  @override
  State<ReplyVideoCallChatWidget> createState() => _ReplyVideoCallChatWidgetState();
}

class _ReplyVideoCallChatWidgetState extends State<ReplyVideoCallChatWidget> {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  late double left;
  late double top;

  void _showReactionEmojis(BuildContext context, Offset position) {
    _overlayEntry?.remove();

    final screenSize = MediaQuery.of(context).size;
    const containerWidth = 300.0;
    const containerHeight = 50.0;

    left = (screenSize.width - containerWidth) / 2 + 30;
    top = (screenSize.height - containerHeight) / 2 - 50;

    if (left < 10) left = 10;
    if (left + containerWidth > screenSize.width - 10) {
      left = screenSize.width - containerWidth - 10;
    }
    if (top < 10) top = position.dy + 20;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _overlayEntry?.remove();
                _overlayEntry = null;
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            top: top,
            left: left,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildReactionEmoji('❤️'),
                    _buildReactionEmoji('😂'),
                    _buildReactionEmoji('😮'),
                    _buildReactionEmoji('😢'),
                    _buildReactionEmoji('🙏'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildReactionEmoji(String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmoji = emoji;
        });
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onLongPress: widget.duration == 0
                      ? null
                      : () {
                          final RenderBox renderBox = context.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(Offset.zero);
                          _showReactionEmojis(
                            context,
                            position + Offset(renderBox.size.width / 2, 0),
                          );
                          MessageActionWidget.show(
                          context,
                          position: Offset(left, top + 50),
                          messageId: widget.messageId,
                          hide: false,
                          messageType: 'video',
                          message: widget.message,
                        );
                        },
                  child: Container(
                    width: screenWidth * 0.6,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.duration != 0 || widget.message == 'Video call started' ? Colors.grey : Colors.red,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                widget.message == 'Video call ended'
                                    ? Icons.call_end_outlined
                                    : Icons.call,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.message == 'Video call started'
                                      ? 'Video call started'
                                      : 'Video call ended',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.time,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (widget.duration == 0 && widget.message == 'Video call ended') ...[
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoCallScreen(
                                    channelName: widget.chatId,
                                    callerName: userId,
                                    callerAvatar: 'assets/images/shrutika.png',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'Call back',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (selectedEmoji != null)
                  Positioned(
                    bottom: -20,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEmoji = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          selectedEmoji!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}