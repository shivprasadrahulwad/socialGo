import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:social/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    name: '',
    username: '',
    avatar: '',
    isOnline: false,
    lastSeen: DateTime.now(),
    createdAt: DateTime.now(),
    email: '',
    password: '',
    type: 'user',
    number: '',
    groups: [], token: '', id: '',
  );

  User get user => _user;

  // Update setUser to handle the new User model with decoded JSON
 void setUser(String userJson) {
    try {
      // Decode the JSON string to a Map<String, dynamic>
      Map<String, dynamic> userMap = jsonDecode(userJson);

      // Now pass the map to fromMap
      _user = User.fromMap(userMap);
      notifyListeners();
    } catch (e) {
      print("Error decoding user data: $e");
    }
  }
  // Set User from an already created User object (model)
  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  // Update user details with copyWith method
  void updateUser(User newUserDetails) {
    _user = _user.copyWith(
      name: newUserDetails.name,
      username: newUserDetails.username,
      avatar: newUserDetails.avatar,
      isOnline: newUserDetails.isOnline,
      lastSeen: newUserDetails.lastSeen,
      createdAt: newUserDetails.createdAt,
      email: newUserDetails.email,
      token: newUserDetails.token,
      password: newUserDetails.password,
      type: newUserDetails.type,
      number: newUserDetails.number,
      groups: newUserDetails.groups,
    );
    notifyListeners();
  }
}