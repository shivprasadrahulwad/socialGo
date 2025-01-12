import 'package:flutter/material.dart';

// class ReplyVideoCallChatWidget extends StatelessWidget {
//   const ReplyVideoCallChatWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         width: screenWidth * 0.6,
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: const Icon(
//                     Icons.video_call,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Video call started',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       '12:39',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               alignment: Alignment.center,
//               child: const Text(
//                 'Join',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


class ReplyVideoCallChatWidget extends StatelessWidget {
  final String? duration; // Pass the duration dynamically
  final String? time; // Pass the time dynamically

  const ReplyVideoCallChatWidget({
    Key? key,
    this.duration,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerLeft, // Align to the left side
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container for video call information
          Container(
            width: screenWidth * 0.6,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.video_call,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (duration == 'Ongoing call')
                      const Text(
                        'Video call started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (duration != 'Ongoing call')
                      const Text(
                        'Video call Ended',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      duration ?? 'Duration not available', // Display the passed duration dynamically
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12), // Space between the container and the time
          // Column for time on the right side
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically center the time
            crossAxisAlignment: CrossAxisAlignment.end, // Align time to the right
            children: [
              Text(
                time ?? 'No time available', // Display the passed time dynamically
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
