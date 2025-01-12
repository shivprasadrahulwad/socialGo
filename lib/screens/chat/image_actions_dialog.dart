// import 'package:flutter/material.dart';

// class ImageActionsDialog extends StatelessWidget {
//   final String dateTime;
//   final VoidCallback onReply;
//   final VoidCallback onForward;
//   final VoidCallback onSave;
//   final VoidCallback onDelete;
//   final VoidCallback onUnsend;
//   final double imageWidth; // New parameter for image width

//   const ImageActionsDialog({
//     Key? key,
//     required this.dateTime,
//     required this.onReply,
//     required this.onForward,
//     required this.onSave,
//     required this.onDelete,
//     required this.onUnsend,
//     required this.imageWidth, // Required parameter
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Semi-transparent white background
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//           // Actions container
//           Positioned(
//             bottom: 20,
//             right: (MediaQuery.of(context).size.width - (imageWidth + 10)) / 2, // Center the dialog
//             child: Container(
//               width: imageWidth + 10, // Image width + 10 pixels
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     spreadRadius: 1,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // DateTime header
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Text(
//                       dateTime,
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                   _buildActionItem(
//                     icon: Icons.reply,
//                     text: 'Reply',
//                     onTap: onReply,
//                   ),
//                   _buildActionItem(
//                     icon: Icons.forward,
//                     text: 'Forward',
//                     onTap: onForward,
//                   ),
//                   _buildActionItem(
//                     icon: Icons.save_alt,
//                     text: 'Save',
//                     onTap: onSave,
//                   ),
//                   _buildActionItem(
//                     icon: Icons.delete,
//                     text: 'Delete for you',
//                     onTap: onDelete,
//                     isDestructive: true,
//                   ),
//                   _buildActionItem(
//                     icon: Icons.restore_from_trash,
//                     text: 'Unsend',
//                     onTap: onUnsend,
//                     isDestructive: true,
//                     isLast: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionItem({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     bool isDestructive = false,
//     bool isLast = false,
//   }) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: isDestructive ? Colors.red : Colors.black87,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 15),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: isDestructive ? Colors.red : Colors.black87,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }