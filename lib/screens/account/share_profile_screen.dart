import 'package:flutter/material.dart';
import 'package:social/screens/account/card_flip_widget.dart';

class ShareProfileScreen extends StatefulWidget {
  const ShareProfileScreen({super.key});

  @override
  State<ShareProfileScreen> createState() => _ShareProfileScreenState();
}

class _ShareProfileScreenState extends State<ShareProfileScreen> {
  final List<Map<String, dynamic>> items = [
    {'icon': Icons.chat, 'text': 'WhatsApp', 'route': '/home'},
    {'icon': Icons.share, 'text': 'Share', 'route': '/search'},
    {'icon': Icons.copy, 'text': 'Copy link', 'route': '/settings'},
    {'icon': Icons.add, 'text': 'Add to story', 'route': '/profile'},
    {'icon': Icons.sms, 'text': 'Download', 'route': '/alerts'},
    {'icon': Icons.download, 'text': 'SMS', 'route': '/info'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.cancel_outlined)),
                const Spacer(),
                const Icon(Icons.edit)
              ],
            ),
            CardFlipWidget(),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.black,
                              size: 35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['text'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
