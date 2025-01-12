import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class OwnVoiceCallChatWidget extends StatelessWidget {
  final String? duration; // Accepting duration parameter
  final String? time; // Accepting time parameter

  const OwnVoiceCallChatWidget({
    Key? key,
    this.duration, // Pass the duration dynamically
    this.time, // Pass the time dynamically
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container for time on the left side, outside the main container
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically center the time
            crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12), // Space between time and the container
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
                    Icons.call,
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
                        'Voice call started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (duration != 'Ongoing call')
                      const Text(
                        'Voice call Ended',
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
        ],
      ),
    );
  }
}
