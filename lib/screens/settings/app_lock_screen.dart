import 'package:flutter/material.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock'),
      ),
      body: const Center(
        child: Text('App Lock Screen'),
      ),
    );
  }
}