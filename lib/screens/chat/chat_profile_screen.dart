import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social/model/message.dart';
import 'package:social/screens/chat/chat_profile_action_widget.dart';
import 'package:social/screens/services/chat_services.dart';

// class ChatProfileScreen extends StatefulWidget {
//   final String chatId;
//   final bool isUserBlocked;
//   final String targetUserId;
//   const ChatProfileScreen(
//       {Key? key,
//       required this.chatId,
//       required this.isUserBlocked,
//       required this.targetUserId})
//       : super(key: key);

//   @override
//   _ChatProfileScreenState createState() => _ChatProfileScreenState();
// }

// class _ChatProfileScreenState extends State<ChatProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late Box<Message> _messageBox;
//   List<Message> _images = [];
//   List<Message> _videos = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _messageBox = Hive.box<Message>('messages');
//     _fetchMedia();
//   }

//   void _fetchMedia() {
//     final messages =
//         _messageBox.values.where((msg) => msg.chatId == widget.chatId);
//     setState(() {
//       _images = messages.where((msg) => msg.type == MessageType.image).toList();
//       _videos = messages.where((msg) => msg.type == MessageType.video).toList();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Chat Profile'),
//       // ),
//       body: Column(
//         children: [
//           const SizedBox(
//             height: 30,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               const Column(
//                 children: [
//                   Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: CircleAvatar(
//                         radius: 60,
//                         backgroundImage:
//                             AssetImage('assets/images/shrutika.png'),
//                       ),
//                     ),
//                   ),
//                   Text(
//                     'Shivprasad Rahulwad',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     '8830031264',
//                     style: TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//               IconButton(
//                 icon: const Icon(Icons.more_vert),
//                 onPressed: () {
//                   final RenderBox renderBox =
//                       context.findRenderObject() as RenderBox;
//                   final Offset position = renderBox.localToGlobal(Offset.zero);
//                   ChatProfileActionWidget.show(context,
//                       position: position,
//                       chatId: widget.chatId,
//                       targetUserId: widget.targetUserId,
//                       isBlocked: widget.isUserBlocked);
//                 },
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildActionButton(Icons.person, 'Profile'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 _buildActionButton(Icons.search, 'Search'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 _buildActionButton(Icons.volume_off, 'Mute'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 _buildActionButton(Icons.share, 'Share'),
//               ],
//             ),
//           ),
//           const ListTile(
//             leading: Icon(Icons.security),
//             title: Text('Privacy & Safety'),
//           ),
//           const ListTile(
//             leading: Icon(Icons.lock),
//             title: Text('Chat Lock'),
//           ),
//           TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(text: 'Images'),
//               Tab(text: 'Videos'),
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildMediaGrid(_images),
//                 _buildMediaGrid(_videos),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMediaGrid(List<Message> mediaList) {
//     if (mediaList.isEmpty) {
//       return const Center(child: Text('No media found'));
//     }
//     return GridView.builder(
//       padding: const EdgeInsets.all(8.0),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//       ),
//       itemCount: mediaList.length,
//       itemBuilder: (context, index) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(8.0),
//           child: Image.network(
//             mediaList[index].content.mediaUrl ?? '',
//             fit: BoxFit.cover,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildActionButton(IconData icon, String label) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.black, width: 1),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 30),
//             const SizedBox(height: 4),
//             Text(label, textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ChatProfileScreen extends StatefulWidget {
  final String chatId;
  final bool isUserBlocked;
  final String targetUserId;
  const ChatProfileScreen(
      {Key? key,
      required this.chatId,
      required this.isUserBlocked,
      required this.targetUserId})
      : super(key: key);

  @override
  _ChatProfileScreenState createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box<Message> _messageBox;
  List<Message> _images = [];
  List<Message> _videos = [];
  OverlayEntry? overlayEntry;
  BuildContext? navigatorContext;

  @override
  void initState() {
    super.initState();
    navigatorContext = Navigator.of(context).context;
    _tabController = TabController(length: 2, vsync: this);
    _messageBox = Hive.box<Message>('messages');
    _fetchMedia();
  }

  Future<void> handleClearChat() async {
    if (navigatorContext == null) return;

    try {
      print('Starting deletion process');
      final messenger = ScaffoldMessenger.of(navigatorContext!);
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Clearing chat...'),
            ],
          ),
          duration: Duration(days: 1),
        ),
      );

      print('Calling deleteAllMessages');
      await ChatServices().deleteAllMessages(
        context: navigatorContext!,
        chatId: widget.chatId,
      );
      print('Delete completed');

      if (navigatorContext!.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(content: Text('Chat cleared successfully')),
        );
      }
    } catch (e) {
      print('Error caught: $e');
      if (navigatorContext!.mounted) {
        ScaffoldMessenger.of(navigatorContext!).hideCurrentSnackBar();
        ScaffoldMessenger.of(navigatorContext!).showSnackBar(
          SnackBar(
            content: Text('Error clearing chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _fetchMedia() {
    final messages =
        _messageBox.values.where((msg) => msg.chatId == widget.chatId);
    setState(() {
      _images = messages.where((msg) => msg.type == MessageType.image).toList();
      _videos = messages.where((msg) => msg.type == MessageType.video).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Column(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            AssetImage('assets/images/shrutika.png'),
                      ),
                    ),
                  ),
                  Text(
                    'Shivprasad Rahulwad',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '8830031264',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              IconButton(
  icon: const Icon(Icons.share),
  onPressed: () {
    Share.share('Check out this chat profile!');
  },
),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.person, 'Profile', () {
                  // Handle profile action
                }),
                const SizedBox(width: 10),
                _buildActionButton(Icons.search, 'Search', () {
                  // Handle search action
                }),
                const SizedBox(width: 10),
                _buildActionButton(Icons.notifications_none, 'Mute', () {
                  // Handle mute action
                }),
                const SizedBox(width: 10),
                _buildActionButton(Icons.more_vert, 'More', () {
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final Offset position = renderBox.localToGlobal(Offset.zero);
                  ChatProfileActionWidget.show(context,
                      position: position,
                      chatId: widget.chatId,
                      targetUserId: widget.targetUserId,
                      isBlocked: widget.isUserBlocked);
                }),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Theme'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Clear Chat'),
            onTap: () async {
              print('Clear Chat clicked');
              overlayEntry?.remove();

              final shouldDelete = await showDialog<bool>(
                context: navigatorContext!,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat'),
                  content: const Text(
                      'Are you sure you want to clear all messages? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              print('Dialog result: $shouldDelete');
              if (shouldDelete == true) {
                await handleClearChat();
              }
            },
          ),
          // const ListTile(
          //   leading: Icon(Icons.lock),
          //   title: Text('Chat Lock'),
          // ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacy & Safety'),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaGrid(_images),
                _buildMediaGrid(_videos),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<Message> mediaList) {
    if (mediaList.isEmpty) {
      return const Center(child: Text('No media found'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            mediaList[index].content.mediaUrl ?? '',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
