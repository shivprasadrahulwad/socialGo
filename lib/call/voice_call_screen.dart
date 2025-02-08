import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:permission_handler/permission_handler.dart';
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
  RtcEngine? _engine;
  bool isMicMuted = false;
  bool _isInitialized = false;
  bool _isRemoteUserConnected = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _timer;
  int _remoteDurationSeconds = 0;
  DateTime? _remoteUserJoinTime;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _initializeAnimations();
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

  void _initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine?.initialize(
      RtcEngineContext(
        appId: widget.appId,
      ),
    );

    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isInitialized = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _isRemoteUserConnected = true;
            _remoteUserJoinTime = DateTime.now();
            _startRemoteUserTimer();
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _isRemoteUserConnected = false;
            _stopRemoteUserTimer();
          });
        },
      ),
    );

    await _engine?.setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await _engine?.joinChannel(
      token: '',
      channelId: widget.channelName,
      options: ChannelMediaOptions(),
      uid: 0,
    );
  }

  void _startRemoteUserTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remoteDurationSeconds++;
      });
    });
  }

  void _stopRemoteUserTimer() {
    _timer.cancel();
  }

  void _endCall() {
    int callDuration = _remoteDurationSeconds;

    _engine?.leaveChannel();
    _engine?.release();

    Navigator.pop(context, callDuration);
    _timer.cancel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer.cancel();
    _engine?.release();
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isRemoteUserConnected
                              ? _formatDuration(_remoteDurationSeconds)
                              : 'Contacting...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
                              _engine?.muteLocalAudioStream(isMicMuted);
                            });
                          },
                        ),
                        _buildCircularButton(
                          icon: Icons.call_end,
                          color: Colors.white,
                          backgroundColor: Colors.red,
                          onPressed: _endCall,
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
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}