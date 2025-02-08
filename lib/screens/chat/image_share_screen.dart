import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';

class ImageShareScreen extends StatefulWidget {
  final String imageUrl;
  final String senderName;
  final String? profileImage;
  final String? timeAgo;

  const ImageShareScreen({
    Key? key,
    required this.imageUrl,
    required this.senderName,
    this.profileImage,
    this.timeAgo,
  }) : super(key: key);

  @override
  State<ImageShareScreen> createState() => _ImageShareScreenState();
}

class _ImageShareScreenState extends State<ImageShareScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLiked = false;
  late AnimationController _likeAnimationController;
  bool _showOverlay = true;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _replyController.dispose();
    super.dispose();
  }
  Future<void> _saveImage() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) throw Exception('Failed to download image');

      final result = await ImageGallerySaver.saveImage(
        response.bodyBytes,
        quality: 100,
        name: "chat_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        _showSuccessMessage('Image saved to gallery');
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      _showErrorMessage('Error saving image');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareImage() async {
  setState(() => _isLoading = true);
  try {
    final response = await http.get(Uri.parse(widget.imageUrl));
    if (response.statusCode != 200) throw Exception('Failed to download image');

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File imageFile = File(tempPath);
    await imageFile.writeAsBytes(response.bodyBytes);

    await Share.shareXFiles([XFile(tempPath)], text: 'Check out this image!');
    await imageFile.delete();
  } catch (e) {
    _showErrorMessage('Error sharing image: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _handleDoubleTap() {
    setState(() => _isLiked = true);
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the available screen height excluding keyboard
    final availableHeight = MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).viewInsets.bottom;
    
    // Calculate approximate header and footer heights
    const headerHeight = 80.0; // Approximate height for the top bar
    const footerHeight = 80.0; // Approximate height for the reply section
    
    // Calculate remaining space for image
    final imageContainerHeight = availableHeight - headerHeight - footerHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top AppBar with gradient
          AnimatedOpacity(
            opacity: _showOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: headerHeight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 35, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: widget.profileImage != null
                            ? NetworkImage(widget.profileImage!)
                            : null,
                        child: widget.profileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.senderName,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.timeAgo != null)
                              Text(
                                widget.timeAgo!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.save_alt, color: Colors.black),
                        onPressed: _saveImage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Image container with dynamic height
          Container(
            height: imageContainerHeight,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain, // Changed to contain to maintain aspect ratio
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error_outline, color: Colors.black, size: 48),
                  ),
                ),
              ),
            ),
          ),

          // Reply input field at bottom
          Container(
            height: footerHeight,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // Handle camera button press
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Reply...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}