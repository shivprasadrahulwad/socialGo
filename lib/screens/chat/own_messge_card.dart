// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:social/screens/chat/message_action_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class OwnMessageCard extends StatefulWidget {
  const OwnMessageCard({
    Key? key,
    required this.message,
    required this.time,
    required this.isRead,
    required this.messageId,
    required this.onReply,
    this.replyToId,
    this.replyToContent
  }) : super(key: key);

  final String message;
  final DateTime time;
  final bool isRead;
  final String messageId;
  final String? replyToId;
  final String? replyToContent;
  final Function(String messageId, String message) onReply;

  @override
  OwnMessageCardState createState() => OwnMessageCardState();
}

class OwnMessageCardState extends State<OwnMessageCard>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  late double left;
  late double top;
  late AnimationController _swipeController;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0.0;
  final double _swipeThreshold = 50.0;
  String? repliedMessageId;
  

  void handleReply(String messageId, String message) {
  setState(() {
    repliedMessageId = messageId;
  });
}

  Future<void> _initializeUrlLauncher() async {
    try {
      // Initialize the URL launcher platform channel
      await WidgetsFlutterBinding.ensureInitialized();
    } catch (e) {
      print('Error initializing URL launcher: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUrlLauncher();
    repliedMessageId = null;
    // Initialize animation controller
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0.0), // Slide right by 30% of width
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
  }

  // Updated URL launcher method with better error handling
  Future<void> _launchURL(String url) async {
    try {
      // First, ensure the URL is properly formatted
      final Uri uri = Uri.parse(url.trim());

      // Check if the URL can be launched
      if (!await canLaunchUrl(uri)) {
        throw 'Could not launch $url';
      }

      // Attempt to launch the URL with fallback options
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );

      if (!launched) {
        // Try fallback to universal_link mode if external application fails
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open the link. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the link: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
      // Limit the drag to left direction only and set maximum drag distance
      _dragExtent = _dragExtent.clamp(0.0, 100.0);
      _swipeController.value = _dragExtent / 100;
    });
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (_dragExtent >= _swipeThreshold) {
      // If swipe exceeds threshold, trigger reply
      widget.onReply(widget.messageId, widget.message);
      // Show reply indicator animation
      _showReplyIndicator();
    }

    // Reset position with animation
    _swipeController.reverse();
    _dragExtent = 0.0;
  }

  void _showReplyIndicator() {
    // Temporary visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Replying to message...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Updated method to create rich text with clickable URLs
  Widget _buildMessageText() {
    final urlPattern = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    final message = widget.message.trim();
    final matches = urlPattern.allMatches(message);

    if (matches.isEmpty) {
      return Text(
        message,
        style: const TextStyle(fontSize: 16),
      );
    }

    final List<InlineSpan> children = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before URL
      if (match.start > lastEnd) {
        children.add(TextSpan(
          text: message.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16),
        ));
      }

      // Add clickable URL
      final url = match.group(0)!;
      children.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => _launchURL(url),
          onDoubleTap: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text(
            url,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 0, 13, 255),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after last URL
    if (lastEnd < message.length) {
      children.add(TextSpan(
        text: message.substring(lastEnd),
        style: const TextStyle(fontSize: 16),
      ));
    }

    return RichText(
      text: TextSpan(
        children: children,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
  

  void _showReactionEmojis(BuildContext context, Offset position) {
    _overlayEntry?.remove();

    final screenSize = MediaQuery.of(context).size;
    const containerWidth = 300.0;
    const containerHeight = 50.0;

    left = (screenSize.width - containerWidth) / 2 + 30;
    top = (screenSize.height - containerHeight) / 2 - 50;

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
                color: Colors.black.withOpacity(0.3),
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

  //   bool get isCloudinaryImage {
  //   return widget.replyToContent!.startsWith('https://res.cloudinary.com/');
  // }
  bool get isCloudinaryImage {
  return widget.replyToContent != null &&
         widget.replyToContent!.startsWith('https://res.cloudinary.com/');
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
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(widget.time);

    return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.replyToId != null) 
            Text(
              'Replied by you ${widget.replyToId}',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 12),
            ),

            if (isCloudinaryImage)
            // Stack(
            //   children: [
            //     Card(
            //       elevation: 1,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //       color: const Color.fromRGBO(121, 215, 190, 1),
            //       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //       child: Padding(
            //         padding: const EdgeInsets.only(
            //           left: 15,
            //           right: 15,
            //           top: 10,
            //           bottom: 10,
            //         ),
            //         child: Image.network(
            //           widget.replyToContent ?? '',
            //           fit: BoxFit.cover,
            //         ),
            //       ),
            //     ),
            //     Positioned.fill(
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.5),
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Stack(
  children: [
    Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            widget.replyToContent ?? 'assets/images/shrutika.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  ],
),
            if (widget.replyToId != null && !isCloudinaryImage) 
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: const Color.fromRGBO(121, 215, 190, 1),
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
                              child: _buildMessageText(),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Icon(
                              Icons.reply,
                              color: Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onHorizontalDragUpdate: _handleSwipe,
                          onHorizontalDragEnd: _handleSwipeEnd,
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
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: const Color.fromRGBO(121, 215, 190, 1),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: _buildMessageText(),
                              ),
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
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
