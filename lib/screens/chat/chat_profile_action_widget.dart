import 'package:flutter/material.dart';
import 'package:social/screens/chat/block_user_popup_widget.dart';
import 'package:social/screens/services/chat_services.dart';

class ChatProfileActionWidget {
  static void show(BuildContext context, {
    required Offset position,
    required String chatId,
    required String targetUserId,
    required bool isBlocked,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    const menuWidth = 160.0;
    
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final chatService = ChatServices();
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
            right: 8,
            top: position.dy + 70 > screenSize.height - 200 
                ? screenSize.height - 200 
                : position.dy + 70,
            child: Material(
              color: Colors.transparent,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1,
                child: Container(
                  width: menuWidth,
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
                        text: isBlocked ? 'Unblock' : 'Block',
                        icon: isBlocked ? Icons.lock_open : Icons.block,
                        onTap: () async{
                          showBlockDialog(context, "Smith");
                          overlayEntry?.remove();
                          try {
                            if (isBlocked) {
                              await chatService.unblockUser(
                                context: context,
                                chatId: chatId,
                                userIdToUnblock: targetUserId,
                              );
                            } else {
                              await chatService.blockUser(
                                context: context,
                                chatId: chatId,
                                userIdToBlock: targetUserId,
                              );
                            }
                          } catch (e) {
                            // Error is already handled in blockUser method
                            print('Error in menu while blocking user: $e');
                          }
                        },
                        textColor: Colors.red,
                        iconColor: Colors.red,
                      ),
                      _buildActionItem(
                        text: 'Report',
                        icon: Icons.report_problem_outlined,
                        onTap: () {
                          overlayEntry?.remove();
                          // Add report functionality here
                        },
                        textColor: Colors.red,
                        iconColor: Colors.red,
                      ),
                      _buildActionItem(
                        text: 'Password',
                        icon: Icons.lock_outline,
                        onTap: () {
                          overlayEntry?.remove();
                          // Add password functionality here
                        },
                      ),
                    ],
                  ),
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
    required IconData icon,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = Colors.black87,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}