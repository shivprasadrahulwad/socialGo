import 'dart:convert';

class User {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final String email;
  final String token;
  final String password;
  final String type;
  final String number;
  final List<String> groups;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.avatar = '',
    required this.token,
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    required this.email,
    required this.password,
    this.type = 'user',
    required this.number,
    this.groups = const [],
  });

  factory User.fromMap(Map<String, dynamic> map) {
  return User(
    id: map['_id'] as String? ?? '', // Use '_id' from the response
    name: map['name'] as String? ?? '', // Default to an empty string
    username: map['username'] as String? ?? '',
    avatar: map['avatar'] as String? ?? '',
    isOnline: map['isOnline'] as bool? ?? false,
    lastSeen: map['lastSeen'] != null
        ? DateTime.tryParse(map['lastSeen']) ?? DateTime.now()
        : DateTime.now(), // Safely parse or default to now
    createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
        : DateTime.now(),
    email: map['email'] as String? ?? '',
    token: map['token'] as String? ?? '',
    password: map['password'] as String? ?? '',
    type: map['type'] as String? ?? 'user',
    number: map['number'] as String? ?? '',
    groups: map['groups'] != null
        ? List<String>.from(map['groups'] as List)
        : [], // Handle null or empty groups safely
  );
}


  // Convert User to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'email': email,
      'token': token,
      'password': password,
      'type': type,
      'number': number,
      'groups': groups,
    };
  }

  // Convert User to JSON
  String toJson() => json.encode(toMap());

  // Factory constructor to create User from JSON
  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  // Copy constructor to modify fields
  User copyWith({
    String? id,
    String? name,
    String? username,
    String? avatar,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    String? email,
    String? token,
    String? password,
    String? type,
    String? number,
    List<String>? groups,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      token: token ?? this.token,
      password: password ?? this.password,
      type: type ?? this.type,
      number: number ?? this.number,
      groups: groups ?? this.groups,
    );
  }
}
