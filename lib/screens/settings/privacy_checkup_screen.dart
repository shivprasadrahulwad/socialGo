import 'package:flutter/material.dart';

class PrivacyCheckupScreen extends StatelessWidget {
  const PrivacyCheckupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Checkup'),
      ),
      body: const Center(
        child: Text('Privacy Checkup Screen'),
      ),
    );
  }
}