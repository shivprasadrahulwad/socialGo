import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:permission_handler/permission_handler.dart';

// class VoiceCallScreen extends StatefulWidget {
//   final String channelName;
//   final String appId;
//   final String callerName; // Add caller name
//   final String callerAvatar; // Add caller avatar URL

//   const VoiceCallScreen({
//     Key? key,
//     required this.channelName,
//     required this.appId,
//     required this.callerName,
//     required this.callerAvatar,
//   }) : super(key: key);

//   @override
//   State<VoiceCallScreen> createState() => _VoiceCallScreenState();
// }

// class _VoiceCallScreenState extends State<VoiceCallScreen> with SingleTickerProviderStateMixin {
//   late AgoraClient _client;
//   bool isMicMuted = false;
//   bool _isInitialized = false;
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   Future<void> _initAgora() async {
//     await [Permission.microphone].request();
//     _client = AgoraClient(
//       agoraConnectionData: AgoraConnectionData(
//         appId: widget.appId,
//         channelName: widget.channelName,
//       ),
//     );
//     await _client.initialize();
//     setState(() {
//       _isInitialized = true;
//     });
//   }

//   @override
//   void dispose() {
//     _client.release();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: _isInitialized
//           ? SafeArea(
//               child: Column(
//                 children: [
//                   // Top Section with call duration
//                   const Padding(
//                     padding: EdgeInsets.only(top: 40),
//                     child: Text(
//                       'Voice call',
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
                  
//                   // Caller Info Section
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Animated Avatar
//                         AnimatedBuilder(
//                           animation: _pulseAnimation,
//                           builder: (context, child) {
//                             return Transform.scale(
//                               scale: _pulseAnimation.value,
//                               child: Container(
//                                 width: 120,
//                                 height: 120,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Colors.white24, width: 2),
//                                   image: DecorationImage(
//                                     image: NetworkImage(widget.callerAvatar),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           widget.callerName,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Bottom Controls
//                   Container(
//                     padding: const EdgeInsets.only(bottom: 50),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // Speaker Button
//                         _buildCircularButton(
//                           icon: Icons.volume_up,
//                           color: Colors.white60,
//                           backgroundColor: Colors.white24,
//                           onPressed: () {},
//                         ),
//                         // Mute Button
//                         _buildCircularButton(
//                           icon: isMicMuted ? Icons.mic_off : Icons.mic,
//                           color: Colors.white,
//                           backgroundColor: isMicMuted ? Colors.red : Colors.white24,
//                           onPressed: () {
//                             setState(() {
//                               isMicMuted = !isMicMuted;
//                               _client.engine.muteLocalAudioStream(isMicMuted);
//                             });
//                           },
//                         ),
//                         // End Call Button
//                         _buildCircularButton(
//                           icon: Icons.call_end,
//                           color: Colors.white,
//                           backgroundColor: Colors.red,
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//               ),
//             ),
//     );
//   }

//   Widget _buildCircularButton({
//     required IconData icon,
//     required Color color,
//     required Color backgroundColor,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: backgroundColor,
//       ),
//       child: IconButton(
//         icon: Icon(icon),
//         color: color,
//         iconSize: 32,
//         padding: const EdgeInsets.all(12),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }


import 'dart:async';

class VoiceCallScreen extends StatefulWidget {
  final String channelName;
  final String appId;
  final String callerName;
  final String callerAvatar;

  const VoiceCallScreen({
    Key? key,
    required this.channelName,
    required this.appId,
    required this.callerName,
    required this.callerAvatar,
  }) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> with SingleTickerProviderStateMixin {
  late AgoraClient _client;
  bool isMicMuted = false;
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _timer;
  int _seconds = 0; // Variable to store the time spent in call

  @override
  void initState() {
    super.initState();
    _initAgora();
    _initializeAnimations();
    _startTimer(); // Start the timer when the screen is initialized
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initAgora() async {
    await [Permission.microphone].request();
    _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: widget.appId,
        channelName: widget.channelName,
      ),
    );
    await _client.initialize();
    setState(() {
      _isInitialized = true;
    });
  }


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _client.release();
    _pulseController.dispose();
    _timer.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'Voice call',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24, width: 2),
                                  image: DecorationImage(
                                  image: AssetImage(widget.callerAvatar),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.callerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _formatDuration(_seconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircularButton(
                          icon: Icons.volume_up,
                          color: Colors.white60,
                          backgroundColor: Colors.white24,
                          onPressed: () {},
                        ),
                        _buildCircularButton(
                          icon: isMicMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                          backgroundColor: isMicMuted ? Colors.red : Colors.white24,
                          onPressed: () {
                            setState(() {
                              isMicMuted = !isMicMuted;
                              _client.engine.muteLocalAudioStream(isMicMuted);
                            });
                          },
                        ),
                        _buildCircularButton(
                          icon: Icons.call_end,
                          color: Colors.white,
                          backgroundColor: Colors.red,
                          onPressed: () {
                            _endCall();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }

  void _endCall() {
    // Pass the call duration back to the previous screen when call ends
    Navigator.pop(context, _formatDuration(_seconds));

    // Stop the timer when the call ends
    _timer.cancel();
  }

  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color,
        iconSize: 32,
        padding: const EdgeInsets.all(12),
        onPressed: onPressed,
      ),
    );
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600; // Calculate hours
    int minutes = (seconds % 3600) ~/ 60; // Calculate minutes
    int remainingSeconds = seconds % 60; // Calculate remaining seconds
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
