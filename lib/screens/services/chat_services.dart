import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/constants/utils.dart';
import 'package:social/model/chat.dart';
import 'package:social/model/message.dart';
import 'package:social/models/user.dart';
import 'package:social/providers/user_provider.dart';

class ChatServices {

  Future<Message?> sendMessages({
    required BuildContext context,
    required messageId,
    required String chatId,
    required String content,
    required String senderId,
    required MessageType messageType,
    String? quotedMessageId,
    String? fileName,
    int? fileSize,
    int? duration,
    String? thumbnail,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Construct the message payload based on MessageType
      final Map<String, dynamic> payload = {
        'chatId': chatId,
        'content': content,
        'senderId':senderId,
        'messageId':messageId,
        'messageType': messageType.toString().split('.').last,
        if (quotedMessageId != null) 'quotedMessageId': quotedMessageId,
      };

      // Add media-specific fields only when they exist
      if (messageType != MessageType.text) {
        if (fileName != null) payload['fileName'] = fileName;
        if (fileSize != null) payload['fileSize'] = fileSize;
        if (duration != null) payload['duration'] = duration;
        if (thumbnail != null) payload['thumbnail'] = thumbnail;
      }

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
        Map<String, dynamic>? errorData = jsonDecode(response.body);
        throw HttpException(errorData?['error'] ?? 'Failed to send message');
      }
    } on SocketException {
      CustomSnackBar.show(context, 'No internet connection');
    } on HttpException catch (e) {
      CustomSnackBar.show(context, e.message);
    } on FormatException {
      CustomSnackBar.show(context, 'Invalid response format');
    } catch (e) {
      CustomSnackBar.show(context, 'Error: $e');
    }
    return null;
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

    final response = await http.get(
      Uri.parse('$uri/api/chats?userId=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      },
    );
    
    print('Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Even if the response is empty, it will be a valid JSON array
      print('response.body) users -- ${response.body}');
      final List<dynamic> chatsList = jsonDecode(response.body);
      
      // Convert to Chat objects
      return chatsList.map((chatData) {
        try {
          return Chat.fromMap(chatData as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing chat: $e');
          return null;
        }
      }).whereType<Chat>().toList();
    }
    
    return [];
    
  } catch (e) {
    print('Error fetching chats: $e');
    if (context.mounted) {
      CustomSnackBar.show(context, 'Error fetching chats: $e');
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

      final response = await http.post(
        Uri.parse('$uri/api/createGetChats'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'participantId': participantId,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

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