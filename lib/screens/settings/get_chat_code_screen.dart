import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class GetChatCodeScreen extends StatefulWidget {
//   const GetChatCodeScreen({super.key});

//   @override
//   State<GetChatCodeScreen> createState() => _GetChatCodeScreenState();
// }

// class _GetChatCodeScreenState extends State<GetChatCodeScreen> {
//   final TextEditingController _userIdController = TextEditingController();

//   void _showBottomSheet() {
//     // Mock data - replace with actual API call
//     final userData = {
//       'name': 'John Doe',
//       'chatId': 'CHAT123456',
//       'password': 'SecurePass123'
//     };

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(24),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Chat Details',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF6200EE),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildDetailRow(Icon(Icons.person), userData['name']!),
//             _buildDetailRow(Icon(Icons.assignment_ind_rounded), userData['chatId']!),
//             _buildPasswordRow(Icon(Icons.lock), userData['password']!),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

// Widget _buildDetailRow(Icon icon, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Row(
//       children: [
//         icon,
//         const SizedBox(width: 8), // Add spacing between the icon and the text
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     ),
//   );
// }


//  Widget _buildPasswordRow(Icon icon, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Row(
//       children: [
//         icon, // Display the passed icon
//         const SizedBox(width: 8), // Add some space between the icon and the text
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const Spacer(),
//         IconButton(
//           icon: const Icon(Icons.copy, color: Color(0xFF6200EE)),
//           onPressed: () {
//             Clipboard.setData(ClipboardData(text: value));
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Password copied to clipboard')),
//             );
//           },
//         ),
//       ],
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Get Hidden Chat Code',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _userIdController,
//               decoration: InputDecoration(
//                 hintText: 'Enter remote user ID',
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6200EE)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _showBottomSheet,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6200EE),
//                 minimumSize: Size(MediaQuery.of(context).size.width, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Submit',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     super.dispose();
//   }
// }


class GetChatCodeScreen extends StatefulWidget {
  const GetChatCodeScreen({super.key});

  @override
  State<GetChatCodeScreen> createState() => _GetChatCodeScreenState();
}

class _GetChatCodeScreenState extends State<GetChatCodeScreen> {
  final TextEditingController _userIdController = TextEditingController();

  void _showBottomSheet() {
    final userData = {
      'name': 'John Doe',
      'chatId': 'CHAT123456',
      'password': 'SecurePass123'
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chat Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6200EE),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(const Icon(Icons.person), userData['name']!),
            _buildDetailRow(const Icon(Icons.assignment_ind_rounded), userData['chatId']!),
            _buildPasswordRow(const Icon(Icons.lock), userData['password']!),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(Icon icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRow(Icon icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(left: 12,right: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy,size: 25, color: Color(0xFF6200EE)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Get Hidden Chat Code',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                hintText: 'Enter remote user ID',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6200EE)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                minimumSize: Size(MediaQuery.of(context).size.width, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }
}
