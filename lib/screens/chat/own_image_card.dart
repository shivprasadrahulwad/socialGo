// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:social/screens/chat/image_share_screen.dart';

class OwnImageCard extends StatefulWidget {
  const OwnImageCard({
    Key? key,
    required this.path,
    required this.time,
  }) : super(key: key);

  final String path;
  final String time;

  @override
  OwnImageCardState createState() => OwnImageCardState();
}

class OwnImageCardState extends State<OwnImageCard> {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;

  void _showReactionEmojis(BuildContext context, Offset position) {
    _overlayEntry?.remove();
    
    final screenSize = MediaQuery.of(context).size;
    const containerWidth = 300.0;
    const containerHeight = 50.0;
    
    double left = position.dx - (containerWidth / 2);
    double top = position.dy - 60;
    
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              widget.time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none, // Allow reaction to overflow
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3.5,
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
                      },
                      child: Image.network(
                        widget.path,
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
        ],
      ),
    );
  }
}