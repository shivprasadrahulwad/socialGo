import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class ConfessionCard extends StatefulWidget {
//   final String content;
//   final String category;
//   final DateTime timestamp;
//   final int likes;
//   final int supports;
//   final bool isAnonymous;
//   final Function()? onLike;
//   final Function()? onShare;
//   final Function()? onReport;

//   const ConfessionCard({
//     Key? key,
//     required this.content,
//     required this.category,
//     required this.timestamp,
//     required this.likes,
//     required this.supports,
//     this.isAnonymous = true,
//     this.onLike,
//     this.onShare,
//     this.onReport,
//   }) : super(key: key);

//   @override
//   State<ConfessionCard> createState() => _ConfessionCardState();
// }

// class _ConfessionCardState extends State<ConfessionCard> with SingleTickerProviderStateMixin {
//   bool isLiked = false;
//   bool isBookmarked = false;
//   late AnimationController _likeAnimationController;
//   late Animation<double> _likeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _likeAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(
//         parent: _likeAnimationController,
//         curve: Curves.elasticOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _likeAnimationController.dispose();
//     super.dispose();
//   }

//   void _handleLike() {
//     setState(() {
//       isLiked = !isLiked;
//       if (isLiked) {
//         _likeAnimationController.forward().then((_) => _likeAnimationController.reverse());
//       }
//     });
//     widget.onLike?.call();
//   }

//   String _getTimeAgo() {
//     final now = DateTime.now();
//     final difference = now.difference(widget.timestamp);

//     if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else {
//       return DateFormat('MMM d').format(widget.timestamp);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.blue.shade100,
//                   child: Text(
//                     'A',
//                     style: TextStyle(
//                       color: Colors.blue.shade700,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.isAnonymous ? 'Anonymous' : 'User Name',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Text(
//                         _getTimeAgo(),
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     widget.category,
//                     style: TextStyle(
//                       color: Colors.blue.shade700,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Content
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               widget.content,
//               style: const TextStyle(
//                 fontSize: 16,
//                 height: 1.4,
//               ),
//             ),
//           ),

//           // Interaction Buttons
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     // Like Button
//                     ScaleTransition(
//                       scale: _likeAnimation,
//                       child: IconButton(
//                         onPressed: _handleLike,
//                         icon: Icon(
//                           isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
//                           color: isLiked ? Colors.blue : Colors.grey.shade600,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       '${widget.likes}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(width: 16),

//                     // Support Button
//                     IconButton(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.favorite_outline,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       '${widget.supports}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     // Share Button
//                     IconButton(
//                       onPressed: widget.onShare,
//                       icon: Icon(
//                         Icons.share_outlined,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     // Report Button
//                     IconButton(
//                       onPressed: widget.onReport,
//                       icon: Icon(
//                         Icons.flag_outlined,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// class ConfessionCard extends StatefulWidget {
//   final String content;
//   final String category;
//   final DateTime timestamp;
//   final int likes;
//   final int supports;
//   final bool isAnonymous;
//   final Function()? onLike;
//   final Function()? onShare;
//   final Function()? onReport;

//   const ConfessionCard({
//     Key? key,
//     required this.content,
//     required this.category,
//     required this.timestamp,
//     required this.likes,
//     required this.supports,
//     this.isAnonymous = true,
//     this.onLike,
//     this.onShare,
//     this.onReport,
//   }) : super(key: key);

//   @override
//   State<ConfessionCard> createState() => _ConfessionCardState();
// }

// class _ConfessionCardState extends State<ConfessionCard> with SingleTickerProviderStateMixin {
//   bool isLiked = false;
//   bool isBookmarked = false;
//   bool showReactionMenu = false;
//   Map<String, int> reactions = {};
//   late AnimationController _likeAnimationController;
//   late Animation<double> _likeAnimation;
//   Offset _tapPosition = Offset.zero;
  
//   // Define available reactions
//   final List<Map<String, dynamic>> reactionOptions = [
//     {'emoji': '❤️', 'name': 'love'},
//     {'emoji': '😂', 'name': 'haha'},
//     {'emoji': '😮', 'name': 'wow'},
//     {'emoji': '😢', 'name': 'sad'},
//     {'emoji': '😡', 'name': 'angry'},
//     {'emoji': '👍', 'name': 'like'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _likeAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(
//         parent: _likeAnimationController,
//         curve: Curves.elasticOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _likeAnimationController.dispose();
//     super.dispose();
//   }

//   void _handleLike() {
//     setState(() {
//       isLiked = !isLiked;
//       if (isLiked) {
//         _likeAnimationController.forward().then((_) => _likeAnimationController.reverse());
//       }
//     });
//     widget.onLike?.call();
//   }

//   void _showReactionMenu(BuildContext context, LongPressStartDetails details) {
//     setState(() {
//       _tapPosition = details.globalPosition;
//       showReactionMenu = true;
//     });
//   }

//   void _handleReaction(String reaction) {
//     setState(() {
//       reactions.update(reaction, (value) => value + 1, ifAbsent: () => 1);
//       showReactionMenu = false;
//     });
//   }

//   void _hideReactionMenu() {
//     setState(() {
//       showReactionMenu = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         GestureDetector(
//           onLongPressStart: (details) => _showReactionMenu(context, details),
//           onLongPressEnd: (_) => _hideReactionMenu(),
//           child: Card(
//             elevation: 2,
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundColor: Colors.blue.shade100,
//                         child: Text(
//                           'A',
//                           style: TextStyle(
//                             color: Colors.blue.shade700,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.isAnonymous ? 'Anonymous' : 'User Name',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Text(
//                               _getTimeAgo(),
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           widget.category,
//                           style: TextStyle(
//                             color: Colors.blue.shade700,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Content
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     widget.content,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),

//                 // Reactions Display
//                 if (reactions.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Wrap(
//                         spacing: 8,
//                         children: reactions.entries.map((entry) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   reactionOptions
//                                       .firstWhere((option) => option['name'] == entry.key)['emoji'],
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   entry.value.toString(),
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),

//                 // Interaction Buttons
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           ScaleTransition(
//                             scale: _likeAnimation,
//                             child: IconButton(
//                               onPressed: _handleLike,
//                               icon: Icon(
//                                 isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
//                                 color: isLiked ? Colors.blue : Colors.grey.shade600,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '${widget.likes}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           IconButton(
//                             onPressed: () {},
//                             icon: Icon(
//                               Icons.favorite_outline,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           Text(
//                             '${widget.supports}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           IconButton(
//                             onPressed: widget.onShare,
//                             icon: Icon(
//                               Icons.share_outlined,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: widget.onReport,
//                             icon: Icon(
//                               Icons.flag_outlined,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
        
//         // Reaction Menu Overlay
//         if (showReactionMenu)
//           Positioned(
//             left: _tapPosition.dx - 140, // Adjust these values based on your needs
//             top: _tapPosition.dy - 60,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: reactionOptions.map((reaction) {
//                   return GestureDetector(
//                     onTap: () => _handleReaction(reaction['name']),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       child: Text(
//                         reaction['emoji'],
//                         style: const TextStyle(fontSize: 24),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   String _getTimeAgo() {
//     final now = DateTime.now();
//     final difference = now.difference(widget.timestamp);

//     if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else {
//       return DateFormat('MMM d').format(widget.timestamp);
//     }
//   }
// }



class ConfessionCard extends StatefulWidget {
  final String content;
  final String category;
  final DateTime timestamp;
  final int likes;
  final int supports;
  final bool isAnonymous;
  final Function()? onLike;
  final Function()? onShare;
  final Function()? onReport;

  const ConfessionCard({
    Key? key,
    required this.content,
    required this.category,
    required this.timestamp,
    required this.likes,
    required this.supports,
    this.isAnonymous = true,
    this.onLike,
    this.onShare,
    this.onReport,
  }) : super(key: key);

  @override
  State<ConfessionCard> createState() => _ConfessionCardState();
}

class _ConfessionCardState extends State<ConfessionCard> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool isBookmarked = false;
  bool showReactionMenu = false;
  Map<String, int> reactions = {};
  Offset _tapPosition = Offset.zero;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  final List<Map<String, dynamic>> reactionOptions = [
    {'emoji': '❤️', 'name': 'love'},
    {'emoji': '😂', 'name': 'haha'},
    {'emoji': '😮', 'name': 'wow'},
    {'emoji': '😢', 'name': 'sad'},
    {'emoji': '😡', 'name': 'angry'},
    {'emoji': '👍', 'name': 'like'},
  ];

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLongPress(LongPressStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    setState(() {
      _tapPosition = localPosition;
      showReactionMenu = true;
    });
  }

  void _handleReaction(String reaction) {
    setState(() {
      if (reactions.containsKey(reaction)) {
        reactions[reaction] = reactions[reaction]! + 1;
      } else {
        reactions[reaction] = 1;
      }
      showReactionMenu = false;
    });
  }

  void _toggleReaction(String reaction) {
    setState(() {
      if (reactions.containsKey(reaction)) {
        if (reactions[reaction]! > 1) {
          reactions[reaction] = reactions[reaction]! - 1;
        } else {
          reactions.remove(reaction);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card
        GestureDetector(
          onLongPressStart: _handleLongPress,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isAnonymous ? 'Anonymous' : 'User Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _getTimeAgo(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.category,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),

                // Spacer for reactions
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Reactions Display overlapping the card
        if (reactions.isNotEmpty)
          Positioned(
            left: 5,
            bottom: -10, // Adjust this value to control how much it overlaps
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: reactions.entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _toggleReaction(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reactionOptions
                                  .firstWhere((option) => option['name'] == entry.key)['emoji'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

        // Modal barrier
        if (showReactionMenu)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showReactionMenu = false;
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

        // Reaction Menu
        if (showReactionMenu)
          Positioned(
            left: _tapPosition.dx - 140,
            top: _tapPosition.dy - 60,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: reactionOptions.map((reaction) {
                    return GestureDetector(
                      onTap: () => _handleReaction(reaction['name']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          reaction['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(widget.timestamp);
    }
  }
}