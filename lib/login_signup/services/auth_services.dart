import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social/constants/error_handle.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/constants/utils.dart';
import 'package:social/models/user.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/Home/login_screen.dart';

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String username,
    required String number,
    required String name,
    
  }) async {
    try {
      User user = User(
        name: '',
        username: username,
        avatar: '',
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
        email: email,
        password: password,
        type: 'user',
        number: number,
        groups: [''], token: '', id: '',
      );

      // final response = await http.post(
      //   Uri.parse('$uri/api/signup'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json; charset=UTF-8',
      //   },
      //   body: jsonEncode(user.toJson()), // Encode body to JSON string
      // );

      final response = await http.post(
  Uri.parse('$uri/api/signup'),
  headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  },
  // Make sure user.toJson() returns a valid Map<String, dynamic>
  body: json.encode({
    "username": username,
    "email": email,
    "number": number,
    "password": password,
    "name": name
  }),
);

      print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          print('✅ Signup successful!');
          CustomSnackBar.show(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    } catch (e) {
      print('❌ Error occurred during signup: $e');
      CustomSnackBar.show(context, e.toString());
    }
  }


  void signInUser({
  required BuildContext context,
  required String email,
  required String username,
  required String password,
  required String number,
}) async {
  try {
    // Create a Map to hold the body parameters
    Map<String, String> body = {
      'password': password,
    };

    // Add email, number, or username to the body if provided
    if (email.isNotEmpty) {
      body['email'] = email;
    } else if (number.isNotEmpty) {
      body['number'] = number;
    } else if (username.isNotEmpty) {
      body['username'] = username;
    }

    print('Request body:-- $body');

    // Send the request with the correct parameters
    http.Response res = await http.post(
      Uri.parse('$uri/api/signin'),
      body: jsonEncode(body),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        Map<String, dynamic> userData = jsonDecode(res.body);
        print('Decoded user data: $userData');
      } catch (e) {
        print('Error decoding response body: $e');
        throw Exception('Invalid JSON response');
      }
      Provider.of<UserProvider>(context, listen: false).setUser(res.body);
      print('Token to store: ${jsonDecode(res.body)['token']}');

      await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
      print('Token stored: ${jsonDecode(res.body)['token']}');

      // Wait for 3 seconds and then navigate to LoginScreen
      Timer(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      });
    } else {
      throw Exception('Failed to sign in: ${res.statusCode}');
    }
  } catch (e) {
    CustomSnackBar.show(context, 'Error: $e');
  }
}


  void getUserData(
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );

        print('Token retrieved: $token');


        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
        print('Token is valid: $response');

      }
    } catch (e) {
      CustomSnackBar.show(context, e.toString());
    }
  }
}
