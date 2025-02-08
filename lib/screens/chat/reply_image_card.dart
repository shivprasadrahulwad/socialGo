import 'package:flutter/material.dart';
import 'package:social/screens/chat/image_share_screen.dart';
import 'package:social/screens/chat/message_action_widget.dart';

// class ReplayImageCard extends StatelessWidget {
//   const ReplayImageCard({
//     Key? key,
//     required this.path,
//     required this.time,
//   }) : super(key: key);

//     final String path;
//   final String time;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//         child: Container(
//           height: MediaQuery.of(context).size.height / 2.3,
//           width: MediaQuery.of(context).size.width / 1.8,
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15), color: Colors.teal),
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Image.network("http://192.168.1.103:5000/uploads/$path", fit: BoxFit.fitHeight,),
//           ),
//         ),
//       ),
//     );
//   }
// }



class ReplyImageCard extends StatefulWidget {
  const ReplyImageCard({
    Key? key,
    required this.path,
    required this.time,
    required this.messageId,
  }) : super(key: key);

  final String path;
  final DateTime time;
  final String messageId;

  @override
  _ReplyImageCardState createState() => _ReplyImageCardState();
}

class _ReplyImageCardState extends State<ReplyImageCard> {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  late double left;
  late double top;


   String get optimizedImageUrl {
    // Add Cloudinary transformations for optimal loading
    // Example: w_auto,c_scale,q_auto,f_auto
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
  final imageWidth = MediaQuery.of(context).size.width / 2.2;

  return Align(
    alignment: Alignment.centerLeft, // Align the entire widget to the left side
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align children to the start (left)
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none, // Allow reaction to overflow
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3.3,
                width: imageWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.teal,
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageShareScreen(
                              imageUrl: widget.path,
                              senderName: 'Sender Name',
                              profileImage: "https://images.app.goo.gl/rpyNFLM3M6emmKgFA",
                              timeAgo: "12 minutes ago",
                            ),
                          ),
                        );
                      },
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
                      child: Image.network(
                        optimizedImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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
                                Text('Failed to load image', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (selectedEmoji != null)
                Positioned(
                  bottom: -15, // Position half outside the image
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmoji = null; // Remove reaction on tap
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
        ],
      ),
    ),
  );
}

}
