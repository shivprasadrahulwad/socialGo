import 'package:flutter/material.dart';
import 'package:social/screens/chat/message_action_widget.dart';
import 'package:video_player/video_player.dart';

class OwnVideoCard extends StatefulWidget {
  const OwnVideoCard({
    Key? key,
    required this.videoUrl,
    required this.time,
    required this.isRead,
    required this.messageId,
    this.replyToId,
    this.replyToContent,
    required this.onReply,
  }) : super(key: key);

  final String videoUrl;
  final DateTime time;
  final bool isRead;
  final String messageId;
  final String? replyToId;
  final String? replyToContent;
  final Function(String messageId, String message) onReply;

  @override
  OwnVideoCardState createState() => OwnVideoCardState();
}

class OwnVideoCardState extends State<OwnVideoCard> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  String? selectedEmoji;
  late double left;
  late double top;
  String? repliedMessageId;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isSliding = false;
  double _slideDelta = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
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

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);
    try {
      await _videoController?.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController?.value.isPlaying ?? false) {
        _videoController?.pause();
        _isPlaying = false;
      } else {
        _videoController?.play();
        _isPlaying = true;
      }
    });
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
      widget.onReply(widget.messageId, widget.videoUrl);
    }
    
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

  // Widget _buildVideoPlayer() {
  //   if (_videoController?.value.isInitialized ?? false) {
  //     return Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         AspectRatio(
  //           aspectRatio: _videoController!.value.aspectRatio,
  //           child: VideoPlayer(_videoController!),
  //         ),
  //         GestureDetector(
  //           onTap: _togglePlayPause,
  //           child: Container(
  //             color: Colors.black26,
  //             child: Icon(
  //               _isPlaying ? Icons.pause : Icons.play_arrow,
  //               size: 50,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 0,
  //           left: 0,
  //           right: 0,
  //           child: VideoProgressIndicator(
  //             _videoController!,
  //             allowScrubbing: true,
  //             colors: VideoProgressColors(
  //               playedColor: Colors.blue,
  //               bufferedColor: Colors.grey,
  //               backgroundColor: Colors.grey[300]!,
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return const Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   }
  // }
  Widget _buildVideoPlayer() {
    if (_videoController?.value.isInitialized ?? false) {
      return Stack(
        fit: StackFit.expand,  // This makes the Stack fill its container
        alignment: Alignment.center,
        children: [
          SizedBox.expand(  // This replaces AspectRatio to fill the full space
            child: FittedBox(
              fit: BoxFit.cover,  // This ensures the video fills the space
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.black26,
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.blue,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.grey[300]!,
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      width: MediaQuery.of(context).size.width / 2.2,
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
                                    'Replying to this video',
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
                                  messageType: 'video',
                                  message: widget.videoUrl,
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
                                  child: _buildVideoPlayer(),
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
    _videoController?.dispose();
    _slideController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}