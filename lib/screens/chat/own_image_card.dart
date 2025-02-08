// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';
// import 'package:social/screens/chat/image_share_screen.dart';
// import 'package:social/screens/chat/message_action_widget.dart';

// class OwnImageCard extends StatefulWidget {
//   const OwnImageCard({
//     Key? key,
//     required this.path,
//     required this.time,
//     required this.isRead,
//     required this.messageId,
//   }) : super(key: key);

//   final String path;
//   final DateTime time;
//   final bool isRead;
//   final String messageId;

//   @override
//   OwnImageCardState createState() => OwnImageCardState();
// }

// class OwnImageCardState extends State<OwnImageCard> {
//   OverlayEntry? _overlayEntry;
//   String? selectedEmoji;
//   late double left;
//   late double top;

//     String get optimizedImageUrl {
//     // Add Cloudinary transformations for optimal loading
//     // Example: w_auto,c_scale,q_auto,f_auto
//     if (widget.path.contains('cloudinary.com')) {
//       final uri = Uri.parse(widget.path);
//       final pathSegments = uri.pathSegments;
//       final insertIndex = pathSegments.indexOf('upload') + 1;
//       final newPathSegments = List<String>.from(pathSegments);
//       newPathSegments.insert(insertIndex, 'w_auto,c_scale,q_auto,f_auto');
//       return uri.replace(pathSegments: newPathSegments).toString();
//     }
//     return widget.path;
//   }

//   void _showReactionEmojis(BuildContext context, Offset position) {
//     _overlayEntry?.remove();
    
//     final screenSize = MediaQuery.of(context).size;
//     const containerWidth = 300.0;
//     const containerHeight = 50.0;
    
//     left = (screenSize.width - containerWidth) / 2 + 30;
//     top = (screenSize.height - containerHeight) / 2 - 50;
    
//     if (left < 10) left = 10;
//     if (left + containerWidth > screenSize.width - 10) {
//       left = screenSize.width - containerWidth - 10;
//     }
//     if (top < 10) top = position.dy + 20;
    
//     _overlayEntry = OverlayEntry(
//       builder: (context) => Stack(
//         children: [
//           Positioned.fill(
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () {
//                 _overlayEntry?.remove();
//                 _overlayEntry = null;
//               },
//               child: Container(
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//           Positioned(
//             top: top,
//             left: left,
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildReactionEmoji('❤️'),
//                     _buildReactionEmoji('😂'),
//                     _buildReactionEmoji('😮'),
//                     _buildReactionEmoji('😢'),
//                     _buildReactionEmoji('🙏'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   Widget _buildReactionEmoji(String emoji) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedEmoji = emoji;
//         });
//         _overlayEntry?.remove();
//         _overlayEntry = null;
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Text(
//           emoji,
//           style: const TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _overlayEntry?.remove();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageWidth = MediaQuery.of(context).size.width / 2.2;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Text(
//               widget.time.toString(),
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//           Stack(
//             clipBehavior: Clip.none, // Allow reaction to overflow
//             children: [
//               Container(
//                 height: MediaQuery.of(context).size.height / 3.5,
//                 width: imageWidth,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.teal,
//                 ),
//                 child: Card(
//                   margin: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ImageShareScreen(
//                               imageUrl: widget.path,
//                               senderName: 'Sender Name',
//                               profileImage: "https://images.app.goo.gl/rpyNFLM3M6emmKgFA",
//                               timeAgo: "12 minutes ago",
//                             ),
//                           ),
//                         );
//                       },
//                       onLongPressStart: (details) {
//                         _showReactionEmojis(context, details.globalPosition);
//                         MessageActionWidget.show(
//                           context,
//                           position: Offset(left, top + 50),
//                           messageId: widget.messageId,
//                           hide: false,
//                           messageType: 'image',
//                           message: widget.path,
//                         );
//                       },
//                       child: Image.network(
//                         optimizedImageUrl,
//                         fit: BoxFit.cover,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                             ),
//                           );
//                         },
//                         errorBuilder: (context, error, stackTrace) {
//                           print('Error loading image: $error\nPath: ${widget.path}');
//                           return const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.error, color: Colors.red),
//                                 SizedBox(height: 8),
//                                 Text('Failed to load image',
//                                     style: TextStyle(color: Colors.red)),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               if (selectedEmoji != null)
//                 Positioned(
//                   bottom: -15, // Position half outside the image
//                   right: 15,
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedEmoji = null; // Remove reaction on tap
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         selectedEmoji!,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }








// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:social/screens/chat/image_share_screen.dart';
import 'package:social/screens/chat/message_action_widget.dart';

class OwnImageCard extends StatefulWidget {
  const OwnImageCard({
    Key? key,
    required this.path,
    required this.time,
    required this.isRead,
    required this.messageId,
    this.replyToId,
    this.replyToContent,
    required this.onReply,
  }) : super(key: key);

  final String path;
  final DateTime time;
  final bool isRead;
  final String messageId;
  final String? replyToId;
  final String? replyToContent;
  final Function(String messageId, String message) onReply;

  @override
  OwnImageCardState createState() => OwnImageCardState();
}

class OwnImageCardState extends State<OwnImageCard> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  late double left;
  late double top;
  String? repliedMessageId;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isSliding = false;
  double _slideDelta = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  String get optimizedImageUrl {
    if (widget.path.contains('cloudinary.com')) {
      final uri = Uri.parse(widget.path);
      final pathSegments = uri.pathSegments;
      final insertIndex = pathSegments.indexOf('upload') + 1;
      final newPathSegments = List<String>.from(pathSegments);
      newPathSegments.insert(insertIndex, 'w_auto,c_scale,q_auto,f_auto');
      return uri.replace(pathSegments: newPathSegments).toString();
    }
    return widget.path;
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      if (!_isSliding) {
        _isSliding = true;
      }
      _slideDelta += details.delta.dx;
      final slidePercent = (_slideDelta / 100).clamp(-1.0, 0.0);
      _slideController.value = -slidePercent;
    });
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (_slideDelta <= -50) {
      // Threshold reached, trigger reply
      widget.onReply(widget.messageId, widget.path);
    }
    
    // Reset position
    _slideController.reverse();
    setState(() {
      _isSliding = false;
      _slideDelta = 0;
    });
  }

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
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width / 2.2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              widget.time.toString(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: Row(
                  children: [
                    if (_isSliding) 
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.reply,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                      child: Column(
                        children: [
                          if (repliedMessageId != null && 
                              repliedMessageId == widget.messageId)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.reply, 
                                    size: 16, 
                                    color: Colors.grey[600]
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Replying to this image',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: GestureDetector(
                              onHorizontalDragUpdate: _handleSwipe,
                              onHorizontalDragEnd: _handleSwipeEnd,
                              onLongPressStart: (details) {
                                _showReactionEmojis(context, details.globalPosition);
                                MessageActionWidget.show(
                                  context,
                                  position: Offset(left, top + 50),
                                  messageId: widget.messageId,
                                  hide: false,
                                  messageType: 'image',
                                  message: widget.path,
                                );
                              },
                              child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: repliedMessageId == widget.messageId
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        )
                                      : BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: repliedMessageId == widget.messageId
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        )
                                      : BorderRadius.circular(20),
                                  child: Image.network(
                                    optimizedImageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error\nPath: ${widget.path}');
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error, color: Colors.red),
                                            SizedBox(height: 8),
                                            Text('Failed to load image',
                                                style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedEmoji != null)
                Positioned(
                  bottom: -15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmoji = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
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
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}