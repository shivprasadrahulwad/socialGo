import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/confession/confession_card.dart';
import 'package:social/confession/confession_screen.dart';
import 'package:social/confession/create_confession_screen.dart';
import 'package:social/contact/search_contact_screen.dart';
import 'package:social/group/group_chat_screen.dart';
import 'package:social/model/chat.dart';
import 'package:social/model/chatModel.dart';
import 'package:social/poll/poll_screen.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/Home/button_card.dart';
import 'package:social/screens/Home/home_screen.dart';
import 'package:social/screens/groups/group_details_screen.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:social/screens/services/user_services.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchChats();
     final participantId = '677fd21f5a9def773966c104';  // Ensure this is a valid MongoDB ObjectId

  // Call the createOrGetChat method
  _createOrGetChat(participantId);
    // _createChat();
  }

//   void _createChat() async {
//   final  chatService = ChatServices();
//   final newChat = await chatService.createChat();

//   if (newChat != null) {
//     // Successfully created chat
//     print('Chat created: ${newChat.name}');
//   } else {
//     // Failed to create chat
//     print('Failed to create chat');
//   }
// }

Future<void> _createOrGetChat(String participantId) async {
  final chatService = ChatServices();
  
  try {
    final chat = await chatService.createOrGetChat(
      context: context,
      participantId: participantId,
    );

    setState(() {
      // _chat = chat; 
    });
  } catch (e) {
    // Handle error appropriately, maybe show a message to the user
    print("Error: $e");
  }
}

  // Method to fetch chats
  Future<void> _fetchChats() async {
    try {
      final chats = await ChatServices().fetchUserChats(context: context);
      setState(() {
        chatModells = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to fetch chats: $e';
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Scaffold(
        appBar: AppBar(
          title: const Text('SocialGo'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child:

        ListView.builder(
  itemCount: chatModells.length,
  itemBuilder: (context, index) => InkWell(
    onTap: () {
      // Assign the current chat as the sourceChat
      // Chat sourceChat = chatModells[index];
      String sourceChat = user.id;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            chatModells: chatModells,
            sourcechat: sourceChat,
          ),
        ),
      );
    },
    child: ButtonCard(
      // Display the first userId that does not match user.id
      name: chatModells[index]
          .participants
          .firstWhere(
            (participant) => participant.userId != user.id,
            orElse: () => Participant(userId: 'No user available', joinedAt: DateTime.now()), // Provide a default Participant
          )
          .userId, // Access userId directly
      imageUrl: chatModells[index].groupPicture,
    ),
  ),
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
                      builder: (context) => ConfessionScreen(
                        name: 'Shiv',
                        userId: uuid.v1(),
                      ),
                    ),
                  );
                },
                child: const Text('confession screen')),
            const SizedBox(
              height: 20,
            ),

            Text('Name --${user.id}'),
            Text('Email --${user.email}'),
            GestureDetector(
                onTap: () => _createOrGetChat('677fd21f5a9def773966c904'),
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
            const SizedBox(
              height: 100,
            ),

            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreatePollScreen()));
                },
                child: const Text('poll screen')),
            const SizedBox(
              height: 100,
            ),
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
