import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:provider/provider.dart';
import 'package:social/models/user.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/chat/chat_screen.dart';
import 'package:social/screens/services/chat_services.dart'; // Ensure you have this dependency

// class SearchContactScreen extends StatefulWidget {
//   const SearchContactScreen({super.key});

//   @override
//   State<SearchContactScreen> createState() => _SearchContactScreenState();
// }

// class _SearchContactScreenState extends State<SearchContactScreen> {
//   Future<List<Contact>> getContacts() async {
//     bool isGranted = await Permission.contacts.isGranted;
//     if (!isGranted) {
//       isGranted = await Permission.contacts.request().isGranted;
//     }
//     if (isGranted) {
//       return await FastContacts.getAllContacts();
//     }
//     return [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             // Implement back navigation
//             Navigator.pop(context);
//           },
//         ),
//         title: const Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Select Contact',
//                   style: TextStyle(color: Colors.black, fontSize: 18),
//                 ),
//                 Text(
//                   '187 contacts',
//                   style: TextStyle(color: Colors.black45, fontSize: 14),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Icon(Icons.search, color: Colors.black),
//                 SizedBox(width: 15),
//                 Icon(Icons.more_vert, color: Colors.black),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           const Text(
//             'Invite to SocialGo',
//             style: TextStyle(color: Colors.grey),
//           ),
//           Expanded(
//             // Use Expanded to prevent overflow issues
//             child: FutureBuilder<List<Contact>>(
//               future: getContacts(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: SizedBox(
//                       height: 50,
//                       child: CircularProgressIndicator(),
//                     ),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error: ${snapshot.error}'),
//                   );
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                     child: Text('No contacts available'),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     Contact contact = snapshot.data![index];
//                     return ListTile(
//                       leading: const CircleAvatar(
//                         radius: 20,
//                         child: Icon(Icons.person),
//                       ),
//                       title: Text(contact.displayName),
//                       subtitle: Text(contact.phones.isNotEmpty
//                           ? contact.phones[0].number
//                           : 'No phone'),
//                       trailing: const Text(
//                         'Invite',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 ClipOval(
//                     child: Image.network(
//                   'https://images.unsplash.com/photo-1735641241204-44519d33651b?q=80&w=1915&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 )),
//                 const SizedBox(width: 10),
//                 const Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Shivprasad Rahulwad',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       'Invite',
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SearchContactScreen extends StatefulWidget {
//   const SearchContactScreen({super.key});

//   @override
//   State<SearchContactScreen> createState() => _SearchContactScreenState();
// }

// class _SearchContactScreenState extends State<SearchContactScreen> {
//   List<Contact> phoneContacts = [];
//   Map<String, User> registeredUsers = {};
//   bool isLoading = true;
//   String token = '';  // Ensure you fetch the token from your authentication mechanism

//   @override
//   void initState() {
//     super.initState();
//     loadContacts();
//   }

//   Future<void> loadContacts() async {
//     setState(() => isLoading = true);
//     try {
//       // Get phone contacts
//       phoneContacts = await getContacts();

//       if (phoneContacts.isNotEmpty) {
//         // Extract phone numbers
//         List<String> phoneNumbers = phoneContacts
//             .where((contact) => contact.phones.isNotEmpty)
//             .map((contact) => contact.phones[0].number)
//             .toList();

//         // Fetch registered users using ChatServices with token
//         print('phone numbers beforee passing :${phoneNumbers}');
//         await fetchRegisteredUsers(phoneNumbers);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading contacts: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   // Updated method to call fetchRegisteredUsers in ChatServices
// Future<void> fetchRegisteredUsers(List<String> phoneNumbers) async {
//   try {
//     // Assuming ChatServices.fetchRegisteredUsers returns a List<User>
//     final chatService = ChatServices();
//      print('phone numbers beforee passing 2:${phoneNumbers}');

//     final users = await chatService.fetchRegisteredUsers(
//       phoneNumbers: phoneNumbers,
//       context: context,
//     );

//     setState(() {
//       registeredUsers = {
//         for (var user in users) user.number: user
//       };
//     });
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching registered users: $e')),
//       );
//     }
//   }
// }

//   Future<List<Contact>> getContacts() async {
//     bool isGranted = await Permission.contacts.isGranted;
//     if (!isGranted) {
//       isGranted = await Permission.contacts.request().isGranted;
//     }
//     if (isGranted) {
//       return await FastContacts.getAllContacts();
//     }
//     return [];
//   }

//   Widget _buildUserAvatar(Contact contact, User? userDetails) {
//     if (userDetails != null && userDetails.avatar.isNotEmpty) {
//       return CircleAvatar(
//         radius: 20,
//         backgroundImage: NetworkImage(userDetails.avatar),
//         onBackgroundImageError: (_, __) => const Icon(Icons.person),
//       );
//     }

//     return CircleAvatar(
//       radius: 20,
//       child: Text(
//         contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildUserStatus(User? userDetails) {
//     if (userDetails == null) return Container();

//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: userDetails.isOnline ? Colors.green : Colors.grey,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           userDetails.isOnline ? 'Online' : 'Offline',
//           style: TextStyle(
//             color: userDetails.isOnline ? Colors.green : Colors.grey,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Select Contact',
//                   style: TextStyle(color: Colors.black, fontSize: 18),
//                 ),
//                 Text(
//                   '${phoneContacts.length} contacts',
//                   style: const TextStyle(color: Colors.black45, fontSize: 14),
//                 ),
//               ],
//             ),
//             const Row(
//               children: [
//                 Icon(Icons.search, color: Colors.black),
//                 SizedBox(width: 15),
//                 Icon(Icons.more_vert, color: Colors.black),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text(
//                     'Invite to SocialGo',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: phoneContacts.length,
//                     itemBuilder: (context, index) {
//                       Contact contact = phoneContacts[index];
//                       String phoneNumber = contact.phones.isNotEmpty
//                           ? contact.phones[0].number
//                           : '';
//                       User? userDetails = registeredUsers[phoneNumber];

//                       return ListTile(
//                         leading: _buildUserAvatar(contact, userDetails),
//                         title: Text(
//                           userDetails?.name ?? contact.displayName,
//                           style: const TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(phoneNumber),
//                             if (userDetails != null) ...[
//                               Text(
//                                 '@${userDetails.username}',
//                                 style: const TextStyle(color: Colors.blue),
//                               ),
//                               _buildUserStatus(userDetails),
//                             ],
//                           ],
//                         ),
//                         trailing: userDetails != null
//                             ? TextButton(
//                                 onPressed: () {
//                                   // Handle starting chat or viewing profile
//                                   // Navigate to chat or profile screen
//                                 },
//                                 child: const Text('Message'),
//                               )
//                             : TextButton(
//                                 onPressed: () {
//                                   // Implement invite functionality
//                                 },
//                                 child: const Text('Invite'),
//                               ),
//                         onTap: () {
//                           if (userDetails != null) {
//                             // Handle user selection
//                             // Navigate to chat or profile screen
//                           }
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

class SearchContactScreen extends StatefulWidget {
  const SearchContactScreen({super.key});

  @override
  State<SearchContactScreen> createState() => _SearchContactScreenState();
}

class _SearchContactScreenState extends State<SearchContactScreen> {
  List<Contact> phoneContacts = [];
  Map<String, User> registeredUsers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    setState(() => isLoading = true);
    try {
      // Get phone contacts
      phoneContacts = await getContacts();

      if (phoneContacts.isNotEmpty) {
        // Extract phone numbers
        List<String> phoneNumbers = phoneContacts
            .where((contact) => contact.phones.isNotEmpty)
            .map((contact) => contact.phones[0].number)
            .toList();

        // Fetch registered users using ChatServices
        await fetchRegisteredUsers(phoneNumbers);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchRegisteredUsers(List<String> phoneNumbers) async {
    try {
      final chatService = ChatServices();
      final users = await chatService.fetchRegisteredUsers(
        phoneNumbers: phoneNumbers,
        context: context,
      );

      setState(() {
        // Create a map with normalized phone numbers as keys
        registeredUsers = {
          for (var user in users) normalizePhoneNumber(user.number): user
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching registered users: $e')),
        );
      }
    }
  }

  String normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.getAllContacts();
    }
    return [];
  }

  Widget _buildUserAvatar(Contact contact, User? userDetails) {
    if (userDetails != null && userDetails.avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(userDetails.avatar),
        onBackgroundImageError: (_, __) => const Icon(Icons.person),
      );
    }

    // Fallback to first letter of name (prioritize registered user's name if available)
    String displayName = userDetails?.name ?? contact.displayName;
    return CircleAvatar(
      radius: 20,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildUserStatus(User? userDetails) {
    if (userDetails == null) return Container();

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: userDetails.isOnline ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          userDetails.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: userDetails.isOnline ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Contact',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Text(
                  '${phoneContacts.length} contacts',
                  style: const TextStyle(color: Colors.black45, fontSize: 14),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.search, color: Colors.black),
                SizedBox(width: 15),
                Icon(Icons.more_vert, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Contacts on SocialGo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      // Registered Users Section
                      if (registeredUsers.isNotEmpty) ...[
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Contacts on SocialGo',
                            style: TextStyle(
                              color: Colors.grey,
                         
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ...phoneContacts.where((contact) {
                          String phoneNumber = contact.phones.isNotEmpty
                              ? normalizePhoneNumber(contact.phones[0].number)
                              : '';
                          return registeredUsers.containsKey(phoneNumber);
                        }).map((contact) {
                          String phoneNumber =
                              normalizePhoneNumber(contact.phones[0].number);
                          User? userDetails = registeredUsers[phoneNumber];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => ChatScreen(reciverId: userDetails!.id, sourchat: user.id, chatId: '',)));
                            },
                            child: ListTile(
                              leading: _buildUserAvatar(contact, userDetails),
                              title: Text(
                                userDetails?.name ?? contact.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.phones.isNotEmpty
                                      ? contact.phones[0].number
                                      : ''),
                                ],
                              ),
                              trailing: TextButton(
                                onPressed: () {
                                  // Handle starting chat
                                },
                                child: Text(
                                  '~${userDetails?.username ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],

                      // Unregistered Users Section
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Text(
                          'Invite to SocialGo',
                          style: TextStyle(
                            color: Colors.grey,
                            // fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...phoneContacts.where((contact) {
                        String phoneNumber = contact.phones.isNotEmpty
                            ? normalizePhoneNumber(contact.phones[0].number)
                            : '';
                        return !registeredUsers.containsKey(phoneNumber);
                      }).map((contact) {
                        return ListTile(
                          leading: _buildUserAvatar(contact, null),
                          title: Text(
                            contact.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.phones.isNotEmpty
                                  ? contact.phones[0].number
                                  : ''),
                            ],
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              // Implement invite functionality
                            },
                            child: const Text(
                              'Invite',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
