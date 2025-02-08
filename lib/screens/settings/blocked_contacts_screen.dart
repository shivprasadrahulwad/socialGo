import 'package:flutter/material.dart';

class BlockedContactsScreen extends StatelessWidget {
  const BlockedContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Contacts'),
      ),
      body: const Center(
        child: Text('Blocked Contacts Screen'),
      ),
    );
  }
}