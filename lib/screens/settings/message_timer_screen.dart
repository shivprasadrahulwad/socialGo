import 'package:flutter/material.dart';

class MessageTimerScreen extends StatelessWidget {
  const MessageTimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Timer'),
      ),
      body: const Center(
        child: Text('Message Timer Screen'),
      ),
    );
  }
}