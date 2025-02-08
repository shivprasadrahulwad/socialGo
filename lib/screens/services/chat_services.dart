import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/constants/utils.dart';
import 'package:social/model/chat.dart';
import 'package:social/model/message.dart';
import 'package:social/models/user.dart';
import 'package:social/providers/user_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatServices {

  // Future<Message?> sendMessages({
  //   required BuildContext context,
  //   required String messageId,
  //   required String chatId,
  //   required String content,
  //   required String senderId,
  //   required MessageType messageType,
  //   String? quotedMessageId,
  //   String? fileName,
  //   int? fileSize,
  //   int? duration,
  //   String? thumbnail,
  // }) async {
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);

  //   try {
  //     // Construct the message payload based on MessageType
  //     print('content 1 --- ${content}');
  //     final Map<String, dynamic> payload = {
  //       'chatId': chatId,
  //       'content': content,
  //       'senderId':senderId,
  //       'messageId':messageId,
  //       'messageType': messageType.toString().split('.').last,
  //       if (quotedMessageId != null) 'quotedMessageId': quotedMessageId,
  //     };

  //     // Add media-specific fields only when they exist
  //     if (messageType != MessageType.text) {
  //       if (fileName != null) payload['fileName'] = fileName;
  //       if (fileSize != null) payload['fileSize'] = fileSize;
  //       if (duration != null) payload['duration'] = duration;
  //       if (thumbnail != null) payload['thumbnail'] = thumbnail;
  //     }

  //     final response = await http.post(
  //       Uri.parse('$uri/api/sendMessages'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'x-auth-token': userProvider.user.token,
  //       },
  //       body: jsonEncode(payload),
  //     );
  //     print('response Body send mess: --- ${response.body}}');

  //     if (response.statusCode == 201) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       return Message.fromJson(responseData);
  //     } else {
  //       Map<String, dynamic>? errorData = jsonDecode(response.body);
  //       throw HttpException(errorData?['error'] ?? 'Failed to send message');
  //     }
  //   } on SocketException {
  //     CustomSnackBar.show(context, 'No internet connection');
  //   } on HttpException catch (e) {
  //     CustomSnackBar.show(context, e.message);
  //   } on FormatException {
  //     CustomSnackBar.show(context, 'Invalid response format');
  //   } catch (e) {
  //     CustomSnackBar.show(context, 'Error: $e');
  //   }
  //   return null;
  // }


  Future<Message?> sendMessages({
    required BuildContext context,
    required String messageId,
    required String chatId,
    required String content,
    required String senderId,
    required MessageType messageType,
    String? replyTo,
    // String? onReply,
    String? fileName,
    int? fileSize,
    int? duration,
    String? thumbnail,
}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Replay message id : -- ${replyTo}');

    try {
        // Construct the message payload
        final Map<String, dynamic> payload = {
            'messageId': messageId,
            'chatId': chatId,
            'senderId': senderId,
            'messageType': messageType.toString().split('.').last,
            'content': messageType == MessageType.text 
                ? content  // Send text content directly
                : {       // Send media content as object
                    'text': null,
                    'mediaUrl': content,
                    'fileName': fileName,
                    'fileSize': fileSize,
                    'duration': duration,
                    'thumbnail': thumbnail,
                },
            if (replyTo != null) 'replyTo': replyTo,
        };

        final response = await http.post(
            Uri.parse('$uri/api/sendMessages'),
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': userProvider.user.token,
            },
            body: jsonEncode(payload),
        );

        if (response.statusCode == 201) {
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            return Message.fromJson(responseData);
        } else {
            final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
            throw HttpException(errorData?['error'] ?? 'Failed to send message');
        }
    } catch (e) {
        print('Error sending message: $e');
        CustomSnackBar.show(context, 'Error: $e');
        return null;
    }
}

//reply message
Future<Message?> replyMessages({
    required BuildContext context,
    required String messageId,
    required String chatId,
    required dynamic content,
    required String senderId,
    required MessageType messageType,
    String? quotedMessageId,
    String? forwardedFrom,
    String? fileName,
    int? fileSize,
    int? duration,
    String? thumbnail,
    ContactInfo? contactInfo,
}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
        // Construct message content based on type
        final Map<String, dynamic> messageContent = messageType == MessageType.text
            ? {
                'text': content,
                'mediaUrl': null,
                'thumbnail': null,
                'fileName': null,
                'fileSize': null,
                'duration': null,
                'contactInfo': null,
              }
            : {
                'text': null,
                'mediaUrl': content,
                'thumbnail': thumbnail,
                'fileName': fileName,
                'fileSize': fileSize,
                'duration': duration,
                'contactInfo': contactInfo?.toJson(),
              };

        // Construct the complete message payload
        final Map<String, dynamic> payload = {
            'messageId': messageId,
            'chatId': chatId,
            'senderId': senderId,
            'messageType': messageType.toString().split('.').last,
            'content': messageContent,
            'quotedMessageId': quotedMessageId,
            'forwardedFrom': forwardedFrom,
        };

        final response = await http.post(
            Uri.parse('$uri/api/replyMessages'),
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': userProvider.user.token,
            },
            body: jsonEncode(payload),
        );

        print('Respnce body of replay message--: ${response.body}' );

        if (response.statusCode == 201) {
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            return Message.fromJson(responseData);
        } else {
            final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
            throw HttpException(errorData?['error'] ?? 'Failed to send message');
        }
    } catch (e) {
        print('Error sending message: $e');
        CustomSnackBar.show(context, 'Error: $e');
        return null;
    }
}
  

  static Future<Message?> sendGroupMessage({
    required BuildContext context,
    required String chatId,
    required String content,
    required String senderId,
    required MessageType type,
    required bool isGroup,
    IO.Socket? socket,
    String? replyTo,
    String? fileName,
    int? fileSize,
    int? duration,
    String? thumbnail,
    ContactInfo? contactInfo,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // Create message content based on type
      final MessageContent messageContent = MessageContent(
        text: type == MessageType.text ? content : null,
        mediaUrl: type != MessageType.text ? content : null,
        thumbnail: thumbnail,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
        contactInfo: contactInfo,
      );

      // Create local message object for immediate UI update
      final Message localMessage = Message(
        messageId: messageId,
        chatId: chatId,
        senderId: senderId,
        type: type,
        content: messageContent,
        replyTo: replyTo,
        status: MessageStatus.sending,
      );

      // Prepare socket payload
      final Map<String, dynamic> socketPayload = {
        'messageId': messageId,
        'message': type == MessageType.text ? content : null,
        'sourceId': senderId,
        if (isGroup) 'groupId': chatId else 'targetId': chatId,
        'path': type != MessageType.text ? content : null,
        'type': isGroup ? 'group' : 'private',
        'messageType': type.toString().split('.').last,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        if (duration != null) 'duration': duration,
        if (thumbnail != null) 'thumbnail': thumbnail,
      };

      // Emit socket event
      if (socket != null && socket.connected) {
        socket.emit(
          isGroup ? 'groupMessage' : 'privateMessage',
          socketPayload,
        );
      }

      // Prepare API payload
      final Map<String, dynamic> apiPayload = {
        'messageId': messageId,
        'chatId': chatId,
        'content': content,
        'senderId': senderId,
        'type': type.toString().split('.').last,
        if (replyTo != null) 'replyTo': replyTo,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        if (duration != null) 'duration': duration,
        if (thumbnail != null) 'thumbnail': thumbnail,
        if (contactInfo != null) 'contactInfo': contactInfo.toJson(),
      };

      // Make API call to persist message
      final response = await http.post(
        Uri.parse('$uri/api/messages/${isGroup ? "group/" : ""}send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(apiPayload),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Message serverMessage = Message.fromJson(responseData);

        
        return serverMessage;
      } else {
        // Handle API error
        Map<String, dynamic>? errorData = jsonDecode(response.body);
        throw HttpException(errorData?['error'] ?? 'Failed to send message');
      }
    } catch (e) {
      // Handle different types of errors
      String errorMessage = 'Error sending message';
      MessageStatus errorStatus = MessageStatus.failed;
      
      if (e is SocketException) {
        errorMessage = 'No internet connection';
      } else if (e is HttpException) {
        errorMessage = e.message;
      } else if (e is FormatException) {
        errorMessage = 'Invalid response format';
      } else {
        errorMessage = 'Error: $e';
      }
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }
  }

  // Helper method for handling media uploads
  static Future<String?> uploadMedia({
    required File file,
    required BuildContext context,
    required MessageType type,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$uri/api/upload/${type.toString().split('.').last}'),
      );

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      // Add auth token
      request.headers.addAll({
        'x-auth-token': userProvider.user.token,
      });

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['url'];
      } else {
        throw HttpException('Failed to upload media');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading media: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }


Future<List<Chat>> fetchUserChats({
  required BuildContext context,
}) async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id;
    
    if (userId == null) {
      print('No user ID found.');
      return [];
    }
    
    // Ensure userId is in the correct format (24-character hex string)
    if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(userId)) {
      throw FormatException('Invalid user ID format');
    }

    final response = await http.get(
      Uri.parse('$uri/api/chats?userId=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> chatsList = jsonDecode(response.body);
      
      return chatsList.map((chatData) {
        try {
          // Ensure the chatData is properly converted to Chat object
          // Make sure your Chat.fromMap handles ObjectId strings correctly
          return Chat.fromMap(chatData as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing chat: $e');
          return null;
        }
      }).whereType<Chat>().toList();
    } else if (response.statusCode == 404) {
      // Handle no chats found
      return [];
    } else {
      throw Exception('Failed to fetch chats: ${response.statusCode}');
    }

  } catch (e) {
    print('Error fetching chats: $e');
    if (context.mounted) {
      CustomSnackBar.show(
        context, 
        e is FormatException ? e.message : 'Error fetching chats: $e'
      );
    }
    return [];
  }
}


// Flutter/Dart client code
Future<List<User>> fetchRegisteredUsers({
  required BuildContext context,
  required List<String> phoneNumbers,
}) async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id;
    
    print('📱 Attempting to fetch users for phone numbers: $phoneNumbers');
    print('🔑 Using user ID: $userId');
    
    final requestBody = jsonEncode({
      'phoneNumbers': phoneNumbers,
    });
    print('📤 Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$uri/api/registered-users'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
      body: requestBody,
    );
    
    print('📥 Response status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> usersData = jsonDecode(response.body);
      print('👥 Parsed users data length: ${usersData.length}');
      
      final List<User> users = usersData.map((userData) {
        try {
          print('🔄 Processing user data: $userData');
          return User.fromMap(userData as Map<String, dynamic>);
        } catch (e) {
          print('❌ Error parsing user data: $e');
          print('❌ Problematic user data: $userData');
          return null;
        }
      }).whereType<User>().toList();
      
      print('✅ Successfully processed ${users.length} users');
      return users;
    } else if (response.statusCode == 404) {
      print('⚠️ No users found (404)');
      return [];
    } else {
      throw HttpException('Failed to fetch registered users. Status code: ${response.statusCode}');
    }
  } on SocketException {
    print('❌ Network error: No internet connection');
    throw const HttpException('No Internet connection');
  } catch (e) {
    print('❌ General error in fetchRegisteredUsers: $e');
    throw HttpException('Failed to fetch registered users: $e');
  }
}

Future<Chat?> createOrGetChat({
    required BuildContext context,
    required String participantId,
    required bool hide,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user.id;
      final token = userProvider.user.token;

      if (userId == null) {
        throw Exception('No user ID found.');
      }

      // Debug prints
      print('Sending userId: $userId');
      print('Sending participantId: $participantId');
      print('Sending chat type hide: $hide');

      final response = await http.post(
        Uri.parse('$uri/api/createGetChats'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'participantId': participantId,
          'hide': hide,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body chats -----: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final chatData = jsonDecode(response.body);
        return Chat.fromMap(chatData as Map<String, dynamic>);
      } else {
        final errorBody = jsonDecode(response.body);
        throw HttpException(
          'Failed to create/get chat: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating/getting chat: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('Error details: $e');
      return null;
    }
  }

  Future<bool> updateChatPassword({
  required BuildContext context,
  required String chatId,
  required String password,
}) async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user.token;

    final response = await http.patch(
      Uri.parse('$uri/api/updateChatPassword'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'chatId': chatId,
        'password': password,
      }),
    );

    print('Response status code: ${response.body}');

    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } else {
      final errorBody = jsonDecode(response.body);
      throw HttpException(
        'Failed to update password: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    print('Error details: $e');
    return false;
  }
}


//delete single message 
Future<void> deleteMessage({
  required BuildContext context,
  required String messageId,
}) async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user.token;

    final response = await http.delete(
      Uri.parse('$uri/api/messages/$messageId'), // Endpoint to delete a message
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    print('Deleting message: $messageId');
    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      // Message deleted successfully
      print('Message deleted successfully');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message deleted successfully'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      final errorBody = jsonDecode(response.body);
      throw HttpException(
        'Failed to delete message: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
      );
    }
  } catch (e) {
    print('Error deleting message: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting message: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    rethrow;
  }
}

Future<void> deleteAllMessages({
    required BuildContext context,
    required String chatId,
  }) async {
    try {
      print('Starting deletion process for chat: $chatId');
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user.id;  // Make sure to get the user ID
      final token = userProvider.user.token;

      // First, get all messages for this chat from local Hive storage
      final messagesBox = await Hive.openBox<Message>('messages');
      final localMessages = messagesBox.values.where((msg) => 
        msg.chatId == chatId && 
        !msg.deletedFor.any((status) => status.userId == userId)
      ).toList();
      final messageIds = localMessages.map((msg) => msg.messageId).toList();

      // Delete from server
      final response = await http.delete(
        Uri.parse('$uri/api/messages/chat/$chatId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      print('Server response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
      //   for (var message in localMessages) {
      //   await messagesBox.delete(message.messageId);
      // }
      await messagesBox.deleteAll(messageIds);

      await messagesBox.close();

      print('Successfully deleted ${messageIds.length} messages from local storage');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${messageIds.length} messages deleted'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      await messagesBox.close();
      
      print('Successfully deleted ${localMessages.length} messages from local storage');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localMessages.length} messages deleted'),
            duration: const Duration(seconds: 3),
          ),
        );
      } 
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat cleared successfully'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw HttpException(
          'Server error: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error during message deletion: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear chat: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      rethrow;
    }
  }

  
  Future<void> blockUser({
  required BuildContext context,
  required String chatId,
  required String userIdToBlock,
}) async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user.token;

    final response = await http.post(
      Uri.parse('$uri/api/chat/block'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'chatId': chatId,
        'userIdToBlock': userIdToBlock,
      }),
    );

    print('Blocking user in chat: $chatId');
    print('User to block: $userIdToBlock');
    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      // User blocked successfully
      final chat = jsonDecode(response.body);
      print('User blocked successfully');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User blocked successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // You might want to update your local chat state here
      // For example, if you're using a ChatProvider:
      // Provider.of<ChatProvider>(context, listen: false).updateChat(chat);
      
      return chat;
    } else {
      final errorBody = jsonDecode(response.body);
      throw HttpException(
        'Failed to block user: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
      );
    }
  } catch (e) {
    print('Error blocking user: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error blocking user: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    rethrow;
  }
}

// Complementary unblock function
Future<void> unblockUser({
  required BuildContext context,
  required String chatId,
  required String userIdToUnblock,
}) async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user.token;

    final response = await http.post(
      Uri.parse('$uri/api/chat/unblock'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'chatId': chatId,
        'userIdToUnblock': userIdToUnblock,
      }),
    );

    print('Unblocking user in chat: $chatId');
    print('User to unblock: $userIdToUnblock');
    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      // User unblocked successfully
      final chat = jsonDecode(response.body);
      print('User unblocked successfully');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Update local chat state if needed
      return chat;
    } else {
      final errorBody = jsonDecode(response.body);
      throw HttpException(
        'Failed to unblock user: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
      );
    }
  } catch (e) {
    print('Error unblocking user: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unblocking user: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    rethrow;
  }
}

// Helper function to check if a user is blocked
bool isUserBlocked({
  required List<dynamic> blockedUsers,
  required String userId,
}) {
  return blockedUsers.any((user) => user['userId'] == userId);
}

  //get the chat messages of two users
  Future<List<Message>> getChatMessages({
    required BuildContext context,
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;

      final response = await http.get(
        Uri.parse('$uri/api/chats/$chatId/messages?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      print('Fetching messages for chat: $chatId, page: $page');
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Message> messages = (data['messages'] as List)
            .map((msgJson) => Message.fromJson(msgJson as Map<String, dynamic>))
            .toList();

        print('Fetched ${messages.length} messages');
        return messages;
      } else {
        final errorBody = jsonDecode(response.body);
        throw HttpException(
          'Failed to fetch messages: ${response.statusCode}, ${errorBody['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error fetching messages: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching messages: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      rethrow;
    }
  }
}