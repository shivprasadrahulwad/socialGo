// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

// class OwnMessageCard extends StatefulWidget {
//   const OwnMessageCard({
//     Key? key,
//     required this.message,
//     required this.time,
//     required this.isRead,
//   }) : super(key: key);

//   final String message;
//   final String time;
//   final bool isRead;

//   @override
//   OwnMessageCardState createState() => OwnMessageCardState();
// }

// class OwnMessageCardState extends State<OwnMessageCard> {
//   OverlayEntry? _overlayEntry;
//   String? selectedEmoji;

//   void _showReactionEmojis(BuildContext context, Offset position) {
//     _overlayEntry?.remove();
    
//     final screenSize = MediaQuery.of(context).size;
//     const containerWidth = 300.0;
//     const containerHeight = 50.0;
    
//     double left = position.dx - (containerWidth / 2);
//     double top = position.dy - 60;
    
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
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8, bottom: 8),
//             child: Text(
//               widget.time,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//           Flexible(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width - 100,
//               ),
//               child: Stack(
//                 children: [
//                   Card(
//                     elevation: 1,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     color: const Color(0xffdcf8c6),
//                     margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                     child: GestureDetector(
//                       onLongPressStart: (details) {
//                         _showReactionEmojis(context, details.globalPosition);
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                           left: 10,
//                           right: 30,
//                           top: 5,
//                           bottom: 10,
//                         ),
//                         child: Text(
//                           widget.message,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (selectedEmoji != null)
//                     Positioned(
//   bottom: -25, // Adjust this value to make it float half above and half below the message container.
//   right: 15,
//   child: Container(
//     padding: const EdgeInsets.all(4),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 4,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Text(
//       selectedEmoji!,
//       style: const TextStyle(fontSize: 16),
//     ),
//   ),
// ),

//                   Positioned(
//                     bottom: 4,
//                     right: 25,
//                     child: Icon(
//                       Icons.done_all,
//                       size: 20,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


class OwnMessageCard extends StatefulWidget {
  const OwnMessageCard({
    Key? key,
    required this.message,
    required this.time,
    required this.isRead, // Ensure you pass the isRead property here
  }) : super(key: key);

  final String message;
  final String time;
  final bool isRead;

  @override
  OwnMessageCardState createState() => OwnMessageCardState();
}

class OwnMessageCardState extends State<OwnMessageCard> {
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
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Text(
              widget.time,
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
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: const Color(0xffdcf8c6),
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        _showReactionEmojis(context, details.globalPosition);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 30,
                          top: 5,
                          bottom: 10,
                        ),
                        child: Text(
                          widget.message,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  if (selectedEmoji != null)
                    Positioned(
                      bottom: -25, // Adjust this value to make it float half above and half below the message container.
                      right: 15,
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
                  // Show "read" icon with blue color when isRead is true
                  Positioned(
                    bottom: 4,
                    right: 25,
                    child: Icon(
                      Icons.done_all,
                      size: 20,
                      color: widget.isRead ? Colors.blue : Colors.grey[600], // Change color based on isRead
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
