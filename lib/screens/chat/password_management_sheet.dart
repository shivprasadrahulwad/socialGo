import 'package:flutter/material.dart';
import 'package:social/screens/chat/chat_password_reset_screen.dart';
import 'package:social/screens/chat/select_password_contact_screen.dart';

class PasswordManagementSheet {
  static void show(BuildContext context,{required String chatId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow(
                text: 'Select Contacts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectPassowrdContactScreen(),
                    ),
                  );
                },
              ),
              _buildRow(
                text: 'Reset Password',
                onTap: () {
                  // SelectContactSheet.show(context);
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPasswordResetScreen(chatId: chatId,),
                  ),
                );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildRow({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16), // ">" icon
          ],
        ),
      ),
    );
  }
}

class SelectContactSheet {
  static void show(BuildContext context) {
    final selectedContactNotifier = ValueNotifier<String?>(null);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<String?>(
          valueListenable: selectedContactNotifier,
          builder: (context, selectedContact, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildContactTile(
                    id: 'shiv',
                    name: 'Shivprasad Rahulwad',
                    number: '8830031264',
                    imageUrl: 'https://example.com/john.jpg',
                    isSelected: selectedContact == 'shiv',
                    onSelected: () => selectedContactNotifier.value = 'shiv',
                  ),
                  _buildContactTile(
                    id: 'prasad',
                    name: 'Sai Prasad',
                    number: '+1 (555) 987-6543',
                    imageUrl: 'https://example.com/jane.jpg',
                    isSelected: selectedContact == 'prasad',
                    onSelected: () => selectedContactNotifier.value = 'prasad',
                  ),
                  ElevatedButton(
                    onPressed: selectedContact != null
                        ? () {
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Send Request'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildContactTile({
    required String id,
    required String name,
    required String number,
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ListTile(
      onTap: onSelected,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, __) => const Icon(Icons.person),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(number),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onSelected(),
        activeColor: Colors.green,
      ),
    );
  }
}
