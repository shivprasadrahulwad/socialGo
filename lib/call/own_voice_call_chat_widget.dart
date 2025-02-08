// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:social/call/voice_call_screen.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/chat/message_action_widget.dart';

// class OwnVoiceCallChatWidget extends StatefulWidget {
//   final int? duration; // Accepting duration parameter
//   final String? time; // Accepting time parameter
//   final String message;
//   final String chatId;

//   const OwnVoiceCallChatWidget({
//     Key? key,
//     this.duration,
//     this.time,
//     required this.message,
//     required this.chatId,
//   }) : super(key: key);

//   @override
//   State<OwnVoiceCallChatWidget> createState() => _OwnVoiceCallChatWidgetState();
// }

// class _OwnVoiceCallChatWidgetState extends State<OwnVoiceCallChatWidget> {
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//         final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final userId = userProvider.user.id;

//     return Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.only(right: 10),
//         child: GestureDetector(
//           onTap: widget.duration == 0
//             ? () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => VoiceCallScreen(
//                       channelName: widget.chatId,
//                       appId: '20810c5544884126b8ffbbe4e0453736',
//                       callerName: userId,
//                       callerAvatar: 'assets/images/shrutika.png',
//                     ),
//                   ),
//                 );
//               }
//             : null,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(width: 12), // Space between time and the container
//               Container(
//                   width: screenWidth * 0.6,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.grey,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Icon(
//                               widget.message == 'Voice call ended'
//                                   ? Icons.call_missed_outgoing
//                                   : Icons.call,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (widget.message == 'Voice call started')
//                                 const Text(
//                                   'Voice call started',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               if (widget.message == 'Voice call ended')
//                                 const Text(
//                                   'Voice call Ended',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${widget.time}', // Display the passed duration dynamically
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       if (widget.duration == 0 && widget.message == 'Voice call ended')
//                       SizedBox(
//                         height: 10,
//                       ),
//                       if (widget.duration == 0 && widget.message == 'Voice call ended')
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: const Padding(
//                             padding: EdgeInsets.all(10.0),
//                             child: Center(
//                               child: Text(
//                                 'Call back',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                     ],
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


class OwnVoiceCallChatWidget extends StatefulWidget {
  final int? duration;
  final String? time;
  final String message;
  final String chatId;
  final String messageId;

  const OwnVoiceCallChatWidget({
    Key? key,
    this.duration,
    this.time,
    required this.message,
    required this.chatId,
    required this.messageId,
  }) : super(key: key);

  @override
  State<OwnVoiceCallChatWidget> createState() => _OwnVoiceCallChatWidgetState();
}

class _OwnVoiceCallChatWidgetState extends State<OwnVoiceCallChatWidget> {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  late double top;
  late double left;

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
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
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
                          messageType: 'voice',
                          message: widget.message,
                        );
                        },
                  onTap: widget.duration == 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceCallScreen(
                                channelName: widget.chatId,
                                appId: '20810c5544884126b8ffbbe4e0453736',
                                callerName: userId,
                                callerAvatar: 'assets/images/shrutika.png',
                              ),
                            ),
                          );
                        }
                      : null,
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
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                widget.message == 'Voice call ended'
                                    ? Icons.call_missed_outgoing
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
                                  widget.message == 'Voice call started'
                                      ? 'Voice call started'
                                      : 'Voice call Ended',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.time}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (widget.duration == 0 && widget.message == 'Voice call ended') ...[
                          SizedBox(height: 10),
                          Container(
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