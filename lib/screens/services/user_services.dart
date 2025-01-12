import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/constants/utils.dart';
import 'package:social/providers/user_provider.dart';

class UserServices {
  Future<List<Map<String, dynamic>>> fetchAllUsers({
    required BuildContext context,
  }) async {
    try {
      print('Fetching all users...');
      
      // Send the GET request
      http.Response res = await http.get(
        Uri.parse('$uri/api/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        // Decode the response
        List<dynamic> usersList = jsonDecode(res.body);
        print('Decoded users data: $usersList');
        return List<Map<String, dynamic>>.from(usersList);
      } else {
        throw Exception('Failed to fetch users: ${res.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      CustomSnackBar.show(context, 'Error fetching users: $e');
      return [];
    }
  }
}
