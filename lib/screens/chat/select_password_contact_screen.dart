import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:provider/provider.dart';
import 'package:social/models/user.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/chat/chat_screen.dart';
import 'package:social/screens/services/chat_services.dart';
import 'package:social/widgets/custom_check_box.dart';

class SelectPassowrdContactScreen extends StatefulWidget {
  const SelectPassowrdContactScreen({super.key});

  @override
  State<SelectPassowrdContactScreen> createState() =>
      _SelectPassowrdContactScreenState();
}

class _SelectPassowrdContactScreenState
    extends State<SelectPassowrdContactScreen> {
  List<Contact> phoneContacts = [];
  Map<String, User> registeredUsers = {};
  bool isLoading = true;
  Set<User> selectedContacts = {};

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

  void _toggleContactSelection(User user) {
    setState(() {
      if (selectedContacts.contains(user)) {
        selectedContacts.remove(user);
      } else if (selectedContacts.length < 3) {
        selectedContacts.add(user);
      }
    });
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
                if (selectedContacts.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Selected contacts',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (selectedContacts.isNotEmpty)
                  Container(
                    height: 100,
                    color: Colors.grey[100],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedContacts.length,
                      itemBuilder: (context, index) {
                        final user = selectedContacts.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  _buildUserAvatar(
                                      phoneContacts.firstWhere((contact) =>
                                          normalizePhoneNumber(
                                              contact.phones[0].number) ==
                                          user.number),
                                      user),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _toggleContactSelection(user),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      // Registered Users Section
                      // if (registeredUsers.isNotEmpty) ...[
                      //   const Padding(
                      //     padding:
                      //         EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //     child: Text(
                      //       'Contacts on SocialGo',
                      //       style: TextStyle(
                      //         color: Colors.grey,

                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ),
                      //   ...phoneContacts.where((contact) {
                      //     String phoneNumber = contact.phones.isNotEmpty
                      //         ? normalizePhoneNumber(contact.phones[0].number)
                      //         : '';
                      //     return registeredUsers.containsKey(phoneNumber);
                      //   }).map((contact) {
                      //     String phoneNumber =
                      //         normalizePhoneNumber(contact.phones[0].number);
                      //     User? userDetails = registeredUsers[phoneNumber];

                      //     return GestureDetector(
                      //       onTap: () {
                      //         Navigator.push(
                      // context,
                      // MaterialPageRoute(
                      //     builder: (builder) => ChatScreen(reciverId: userDetails!.id, sourchat: user.id, chatId: '', hide: false,)));
                      //       },
                      //       child: ListTile(
                      //         leading: _buildUserAvatar(contact, userDetails),
                      //         title: Text(
                      //           userDetails?.name ?? contact.displayName,
                      //           style: const TextStyle(
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.black,
                      //           ),
                      //         ),
                      //         subtitle: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Text(contact.phones.isNotEmpty
                      //                 ? contact.phones[0].number
                      //                 : ''),
                      //           ],
                      //         ),
                      //         trailing: TextButton(
                      //           onPressed: () {
                      //             // Handle starting chat
                      //           },
                      //           child: Text(
                      //             '~${userDetails?.username ?? ''}',
                      //             style: const TextStyle(
                      //               color: Colors.green,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   }).toList(),
                      // ],
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

                          return ListTile(
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
                            trailing: userDetails != null
                                ? CustomCheckbox(
                                    isSelected:
                                        selectedContacts.contains(userDetails),
                                    onChanged: (value) {
                                      if (selectedContacts.length < 3 ||
                                          selectedContacts
                                              .contains(userDetails)) {
                                        _toggleContactSelection(userDetails);
                                      }
                                    },
                                  )
                                : null,
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
                ),
                if (selectedContacts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        print(
                            'Selected contacts: ${selectedContacts.map((user) => user.name)}');
                      },
                      child: Text('Continue (${selectedContacts.length})'),
                    ), 
                  ),
              ],
            ),
    );
  }
}
