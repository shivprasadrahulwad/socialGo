import 'package:flutter/material.dart';
import 'package:social/screens/chat/password_management_sheet.dart';
import 'package:social/screens/services/chat_services.dart';


class ChatScreenActionWidget {
  static void show(BuildContext context, {required Offset position, required String chatId, required bool hide}) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Add a full-screen GestureDetector to capture taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry?.remove(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Your actual widget
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 236,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionItem(
                      text: 'View Contact',
                      onTap: () {
                        overlayEntry?.remove();
                        
                      },
                    ),
                    _buildActionItem(
                      text: 'Search',
                      onTap: () {
                        overlayEntry?.remove();
                        // Add search logic
                      },
                    ),
                    _buildActionItem(
                      text: 'Media, Links and Docs',
                      onTap: () {
                        overlayEntry?.remove();
                        // Add media logic
                      },
                    ),
                    _buildActionItem(
                      text: 'Mute Notifications',
                      onTap: () {
                        overlayEntry?.remove();
                        // Add mute logic
                      },
                    ),
                    _buildActionItem(
                      text: 'Disappearing Messages',
                      onTap: () {
                        overlayEntry?.remove();
                        // Add disappearing messages logic
                      },
                    ),
                    _buildActionItem(
                      text: 'Wallpaper',
                      onTap: () {
                        overlayEntry?.remove();
                        // Add wallpaper logic
                      },
                    ),
                    _buildActionItem(
                      icon: Icons.more_horiz,
                      text: 'More',
                      onTap: () {
                        overlayEntry?.remove();
                        // Show second overlay for 'More' options
                        _showMoreOptions(context, position, chatId, hide);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void _showMoreOptions(BuildContext context, Offset position, String chatId, bool hide) {
    // Directly show the second action widget (ChatScreenActionWidget1)
    ChatScreenActionWidget1.show(context, position: position, chatId: chatId, hide: hide);
  }

  static Widget _buildActionItem({
    IconData? icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: Colors.black54, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}


class ChatScreenActionWidget1 {
  static void show(BuildContext context, {
    required Offset position,
    required String chatId, 
    required bool hide
  }) {
    final overlay = Overlay.of(context);
    final navigatorContext = Navigator.of(context).context;
    OverlayEntry? overlayEntry;

    Future<void> handleClearChat() async {
      try {
        print('Starting deletion process');
        final messenger = ScaffoldMessenger.of(navigatorContext);
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
          context: navigatorContext,
          chatId: chatId,
        );
        print('Delete completed');

        if (navigatorContext.mounted) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(content: Text('Chat cleared successfully')),
          );
        }
      } catch (e) {
        print('Error caught: $e');
        if (navigatorContext.mounted) {
          ScaffoldMessenger.of(navigatorContext).hideCurrentSnackBar();
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            SnackBar(
              content: Text('Error clearing chat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry?.remove(),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 236,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionItem(
                      text: 'Report',
                      onTap: () => overlayEntry?.remove(),
                    ),
                    _buildActionItem(
                      text: 'Block',
                      onTap: () => overlayEntry?.remove(),
                    ),
                    _buildActionItem(
                      text: 'Clear Chat',
                      onTap: () async {
                        print('Clear Chat clicked');
                        overlayEntry?.remove();
                        
                        final shouldDelete = await showDialog<bool>(
                          context: navigatorContext,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Chat'),
                            content: const Text('Are you sure you want to clear all messages? This cannot be undone.'),
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
                    if(hide)
                      _buildActionItem(
                        text: 'Password Management',
                        onTap: () {
                          overlayEntry?.remove();
                          PasswordManagementSheet.show(navigatorContext, chatId: chatId);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

  static Widget _buildActionItem({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}