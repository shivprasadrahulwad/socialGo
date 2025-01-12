// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:social/call/own_video_call_chat_widget.dart';
import 'package:social/call/reply_video_call_chat_widget.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/model/chat.dart';
import 'package:social/model/chatModel.dart';
import 'package:social/screens/Home/chat_page.dart';
import 'package:social/screens/Home/login_screen.dart';
import 'package:social/screens/account/account_bottom_sheet.dart';
import 'package:social/screens/services/chat_services.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  // final List<ChatModel> chatmodels;
  final List<Chat> chatModells;
  // final ChatModel sourchat;
  final String sourcechat;

  HomeScreen({
    Key? key,
    // Key? key,
    required this.chatModells,
    required this.sourcechat,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> items = [
    {'img': 'assets/images/shrutika.png', 'text': 'WhatsApp', 'route': '/home'},
    {'img': 'assets/images/shrutika.png', 'text': 'Share', 'route': '/search'},
    {
      'img': 'assets/images/shrutika.png',
      'text': 'Copy link',
      'route': '/settings'
    },
    {
      'img': 'assets/images/shrutika.png',
      'text': 'Add to story',
      'route': '/profile'
    },
    {
      'img': 'assets/images/shrutika.png',
      'text': 'Download',
      'route': '/alerts'
    },
    {'img': 'assets/images/shrutika.png', 'text': 'SMS', 'route': '/info'},
  ];

@override
void initState() {
  super.initState();
}


  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => const AccountBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [           
            GestureDetector(
              onTap: () {
                showCustomBottomSheet(context);
              },
              child: Row(
                children: [
                  const Text(
                    'shivprasad_rahulwad',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Transform.rotate(
                      angle: 1.5,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: GestureDetector(
                onTap: () => {
                  // navigateToSearchScreen()
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[200],
                        ),
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Search ',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        // Handle navigation or action here
                        Navigator.pushNamed(context, item['route']!);
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    item['img']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Green circle indicator
                              Positioned(
                                bottom: 0,
                                right: 20, // Same as the horizontal margin
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['text']!,
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
            Row(
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: (){
                    
                  },
                  child: const Text(
                    'Requests',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: GlobalVariables.blueTextColor),
                  ),
                ),
              ],
            ),

            // const OwnVideoCallChatWidget(duration: '',),
            // const ReplyVideoCallChatWidget(),
            const SizedBox(
              height: 10,
            ),
            // Expanded(
            //   // Wrap ChatPage with Expanded
            //   child: ChatPage(
            //     chatmodels: widget.chatmodels,
            //     sourchat: widget.sourchat,
            //   ),
            // ),
            Expanded(
              // Wrap ChatPage with Expanded
              child: ChatPage(
                chatModells: widget.chatModells,
                sourcechat: widget.sourcechat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
