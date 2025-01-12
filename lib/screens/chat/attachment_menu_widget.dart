import 'package:flutter/material.dart';
import 'package:social/screens/chat/camera_screen.dart';

class ChatAttachmentMenuWidget extends StatelessWidget {
  final VoidCallback onClose;

  const ChatAttachmentMenuWidget({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAttachmentButton(
                        icon: Icons.description,
                        color: Colors.indigo,
                        label: 'Document',
                        onTap: () {},
                      ),
                      _buildAttachmentButton(
                        icon: Icons.camera_alt,
                        color: Colors.pink,
                        label: 'Camera',
                        onTap: () {
                          
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => CameraScreen(
                                  //       onImageSend: onImageSend,
                                  //     ),
                                  //   ),
                                  // );
                        },
                      ),
                      _buildAttachmentButton(
                        icon: Icons.photo_library,
                        color: Colors.purple,
                        label: 'Gallery',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAttachmentButton(
                        icon: Icons.headphones,
                        color: Colors.orange,
                        label: 'Audio',
                        onTap: () {},
                      ),
                      _buildAttachmentButton(
                        icon: Icons.contacts,
                        color: Colors.teal,
                        label: 'Contact',
                        onTap: () {},
                      ),
                      _buildAttachmentButton(
                        icon: Icons.poll,
                        color: Colors.green,
                        label: 'Poll',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}