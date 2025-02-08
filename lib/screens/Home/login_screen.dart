import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:social/confession/create_confession_screen.dart';
import 'package:social/contact/search_contact_screen.dart';
import 'package:social/group/group_chat_screen.dart';
import 'package:social/home/home_screen.dart';
import 'package:social/model/chat.dart';
import 'package:social/model/chatData.dart';
import 'package:social/model/message.dart';
import 'package:social/poll/poll_screen.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/Home/button_card.dart';
import 'package:social/screens/Home/qr_scan_screen.dart';
import 'package:social/screens/chat/chat_screen.dart';
import 'package:social/screens/chat/sample_screen.dart';
import 'package:social/screens/groups/group_details_screen.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:social/screens/settings/settings_screen.dart';
import 'package:social/screens/story/story_widgets.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController nameController = TextEditingController();
  late Chat sourcechat;
  var uuid = Uuid();
  List<Chat> chatModells = [];
  bool _isLoading = true;
  String? _error;
  late String userId;

  @override
  void initState() {
    super.initState();
    _fetchChats();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    final participantId = userId; // Ensure this is a valid MongoDB ObjectId

    // Call the createOrGetChat method
    _createOrGetChat(participantId);
    // _createChat();
  }

  Future<void> _createOrGetChat(String participantId) async {
    final chatService = ChatServices();

    try {
      final chat = await chatService.createOrGetChat(
        context: context,
        participantId: participantId,
        hide: false,
      );

      setState(() {
        // _chat = chat;
      });
    } catch (e) {
      // Handle error appropriately, maybe show a message to the user
      print("Error: $e");
    }
  }

//   Future<void> _fetchChats() async {
//   try {
//     final chats = await ChatServices().fetchUserChats(context: context);

//     // Check if chats are not null and not empty
//     if (chats != null && chats.isNotEmpty) {
//       // Delete existing box to prevent corruption
//       await Hive.deleteBoxFromDisk('chatData');

//       // Explicitly register the adapter if not done in main
//       if (!Hive.isAdapterRegistered(10)) {  // 10 is your ChatData typeId
//         Hive.registerAdapter(ChatDataAdapter());
//       }

//       // Open box with explicit type
//       final box = await Hive.openBox<ChatData>('chatData');

//       // Store chat data for hidden chats
//       for (var chatModel in chats) {
//         if (chatModel.hide == true) {
//           // Ensure we have valid IDs
//           if (chatModel.id.isNotEmpty) {
//             String receiverId = chatModel.type == "group"
//                 ? "group"
//                 : chatModel.participants
//                     .where((participant) => participant.userId != userId)
//                     .map((participant) => participant.userId)
//                     .firstOrNull ??
//                 'No user available';

//             final chatData = ChatData(
//               chatId: chatModel.id,
//               receiverId: receiverId
//             );

//             // Store with explicit key
//             await box.put(chatModel.id, chatData);
//           }
//         }
//       }

//       // Close the box
//       await box.close();
//     }

//     setState(() {
//       chatModells = chats;
//       _isLoading = false;
//     });
//   } catch (e, stackTrace) {
//     print('Error in _fetchChats: $e');
//     print('Stack trace: $stackTrace');  // Add this to get more detailed error info
//     setState(() {
//       _isLoading = false;
//       _error = 'Failed to fetch chats: $e';
//     });
//   }
// }

  Future<void> _fetchChats() async {
    try {
      final chats = await ChatServices().fetchUserChats(context: context);
      if (chats != null && chats.isNotEmpty) {
        final box =
            Hive.box<ChatData>('chatData'); // Use the already opened box
        await box.clear(); // Clear old data

        for (var chatModel in chats) {
          if (chatModel.hide == true && chatModel.id.isNotEmpty) {
            String receiverId = chatModel.type == "group"
                ? "group"
                : chatModel.participants
                        .where((p) => p.userId != userId)
                        .map((p) => p.userId)
                        .firstOrNull ??
                    'No user available';

            final chatData =
                ChatData(chatId: chatModel.id, receiverId: receiverId);
            await box.put(chatModel.id, chatData);
          }
        }
      }

      setState(() {
        chatModells = chats;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error in _fetchChats: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _error = 'Failed to fetch chats: $e';
      });
    }
  }

  void sendReplyMessage(BuildContext context) async {
    final chatService = ChatServices();
    final String newMessageId = Uuid().v4();

    Message? message = await chatService.replyMessages(
        context: context,
        messageId: newMessageId,
        chatId: '6780a6a7e058f492419e0092',
        content: 'Hello, this is a test reply message!',
        senderId: '677fd21f5a9def773966c904',
        messageType: MessageType.text,
        quotedMessageId: 'b255ba64-2cfe-4408-8780-a3211ed887ab');

    if (message != null) {
      print('Message sent successfully: ${message.toJson()}');
    } else {
      print('Failed to send message.');
    }
  }

  Future<void> clearAllHiveData() async {
    try {
      // Open and clear messages box
      final messagesBox = await Hive.openBox<Message>('messages');
      await messagesBox.clear();
      print('Messages box cleared');

      // Open and clear chat data box
      final chatBox = await Hive.openBox<ChatData>('chatData');
      await chatBox.clear();
      print('Chat box cleared');

      // Close the boxes
      await messagesBox.close();
      await chatBox.close();

      print('All Hive data cleared successfully');
    } catch (e) {
      print('Error clearing Hive data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('SocialGo'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScanScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
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
          Row(
            children: [
              UserStoryWidget(),
              const SizedBox(
                width: 10,
              ),
              const OtherUsersStoryWidget(
                name: 'shrutika_rahulwad',
                imageName: 'assets/images/shrutika.png',
                isSeen: false,
              ),
              const SizedBox(
                width: 10,
              ),
              const OtherUsersStoryWidget(
                name: 'mr.prasad',
                imageName: 'assets/images/shrutika.png',
                isSeen: true,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const GroupDetailsScreen()));
              },
              child: const Text('Groups1')),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chatModells.length,
              itemBuilder: (context, index) {
                final chatModel = chatModells[index];

                // If it's a group, use group name
                if (chatModel.type == "group" && !chatModel.hide) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            password: '',
                            reciverId:
                                chatModel.id, // Use group ID as reciverId
                            sourchat: user.id,
                            chatId: chatModel.id,
                            hide: chatModel.hide,
                            isUserBlocked: false,
                          ),
                        ),
                      );
                    },
                    child: ButtonCard(
                      name: chatModel.name ?? 'Unnamed Group',
                      imageUrl: chatModel.groupPicture ?? '',
                    ),
                  );
                }

                // For non-group chats, get unique participant IDs excluding current user
                final uniqueParticipantIds = chatModel.participants
                    .where((participant) => participant.userId != user.id)
                    .map((participant) => participant.userId)
                    .toSet()
                    .toList();

                // Only show if not hidden and has unique participant IDs
                if (!chatModel.hide && uniqueParticipantIds.isNotEmpty) {
                  return InkWell(
                    onTap: () {
                      // Since we're using uniqueParticipantIds.first, we should also get the corresponding participant
                      final participant = chatModel.participants.firstWhere(
                        (p) => p.userId == uniqueParticipantIds.first,
                        orElse: () => Participant(
                          userId: uniqueParticipantIds.first,
                          joinedAt: DateTime.now(),
                        ),
                      );

                      //             Navigator.pushReplacement(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => ChatScreen(
                      //                   reciverId: uniqueParticipantIds.first,
                      //                   sourchat: user.id,
                      //                   chatId: chatModel.id,
                      //                   hide: chatModel.hide,
                      //                   password: participant
                      //                       .password,
                      //                   blockedUsers: chatModel.settings?.blockedUsers
                      // ?.map((blockedUser) => blockedUser.userId.toString())
                      // ?.toList() ?? [],
                      //                 ),
                      //               ),
                      //             );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            reciverId: uniqueParticipantIds.first,
                            sourchat: user.id,
                            chatId: chatModel.id,
                            hide: chatModel.hide,
                            password: participant.password,
                            isUserBlocked: chatModel.settings?.blockedUsers
                                    ?.any((blockedUser) =>
                                        blockedUser.userId.toString() ==
                                        uniqueParticipantIds.first) ??
                                false,
                          ),
                        ),
                      );
                    },
                    child: ButtonCard(
                      name: uniqueParticipantIds.first,
                      imageUrl: '',
                    ),
                  );
                }

                return Container();
              },
            ),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateConfessionScreen(),
                  ),
                );
              },
              child: const Text('create confession screen')),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDataDisplayWidget(),
                  ),
                );
              },
              child: const Text('chat data ')),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () => sendReplyMessage(context),
            child: const Text("Send Dummy Message"),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDataScreen(
                      chatId: '6780a6a7e058f492419e0092',
                    ),
                  ),
                );
              },
              child: const Text('hive messages')),
          const SizedBox(
            height: 20,
          ),

          GestureDetector(
              onTap: clearAllHiveData,
              child: const Text('clear hive messages')),
          const SizedBox(
            height: 20,
          ),

          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomesScreen(),
                  ),
                );
              },
              child: const Text('cHome screen')),
          const SizedBox(
            height: 20,
          ),

          GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ChatsScreen(),
                //   ),
                // );
              },
              child: const Text('search text screen')),
          const SizedBox(
            height: 20,
          ),

          GestureDetector(
              onTap: () => _createOrGetChat('67832e8d7602108a46881602'),
              child: const Text('create chat')),
          const SizedBox(
            height: 20,
          ),

//             ConfessionCard(
//   content: "I've been pretending to understand calculus all semester. My friends think I'm helping them, but I'm actually learning from teaching them 😅",
//   category: "Academic Life",
//   timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//   likes: 234,
//   supports: 89,
//   isAnonymous: true,
//   onLike: () {
//     // Handle like action
//   },
//   onShare: () {
//     // Handle share action
//   },
//   onReport: () {
//     // Handle report action
//   },
// ),

          GestureDetector(
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Confession'),
                        content: TextFormField(
                          controller: nameController,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupChatScreen(
                                              name: nameController.text,
                                              userId: uuid.v1(),
                                              chatId: '',
                                            )));
                              },
                              child: const Text('Enter')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Close'))
                        ],
                      )),
              child: const Text('group chat screen')),
          // const SizedBox(
          //   height: 100,
          // ),

          // GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => const CreatePollScreen()));
          //     },
          //     child: const Text('poll screen')),
          // const SizedBox(
          //   height: 100,
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SearchContactScreen()));
        },
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
