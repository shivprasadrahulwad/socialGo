import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social/screens/chat/message_action_widget.dart';

class ReplyMessageCard extends StatefulWidget {
  const ReplyMessageCard({
    Key? key,
    required this.message,
    required this.time,
    required this.messageId,
    this.replyToId,
    this.replyToContent,
  }) : super(key: key);

  final String message;
  final DateTime time;
  final String messageId;
  final String? replyToId;
  final String? replyToContent;

  @override
  ReplyMessageCardState createState() => ReplyMessageCardState();
}

class ReplyMessageCardState extends State<ReplyMessageCard> {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  double left = 0.0;
  double top = 0.0;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          if (selectedEmoji == emoji) {
            selectedEmoji = null; // Deselect emoji when tapped again
          } else {
            selectedEmoji = emoji;
          }
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
    String formattedTime = DateFormat('HH:mm').format(widget.time);

    return Align(
        alignment: Alignment.centerRight,
        child: Column(
          children: [
            if (widget.replyToId != null)
              Text(
                'Replied by you ${widget.replyToId}',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 12),
              ),
            if (widget.replyToId != null)
              Stack(
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color.fromRGBO(121, 215, 190, 1),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(widget.replyToContent ?? ''),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.5), // Semi-transparent white overlay
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: Stack(
                      clipBehavior: Clip
                          .none, // This allows the emoji to overflow outside the card boundary
                      children: [
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.grey[350],
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: GestureDetector(
                            onLongPressStart: (details) {
                              _showReactionEmojis(
                                  context, details.globalPosition);
                              MessageActionWidget.show(
                                context,
                                position: Offset(left, top + 50),
                                messageId: widget.messageId,
                                hide: false,
                                messageType: 'message',
                                message: widget.message,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 10,
                                bottom: 10,
                              ),
                              child: Text(
                                widget.message
                                    .trim(), // Apply trim here to remove any leading/trailing whitespace
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        if (selectedEmoji != null)
                          Positioned(
                            bottom:
                                -20, // Adjust the bottom offset to position the emoji
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedEmoji =
                                      null; // Remove the emoji on tap
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
