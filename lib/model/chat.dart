import 'dart:convert';

class Chat {
  final String id;
  final String type;
  final bool hide;
  final String hidePass;
  final List<Participant> participants;
  final String? name; 
  final String? description;
  final String? groupPicture;
  final String? createdBy; 
  final DateTime createdAt;
  final Settings settings;

  Chat({
    required this.id,
    required this.hide,
    required this.hidePass,
    required this.type,
    required this.participants,
    this.name,
    this.description,
    this.groupPicture,
    this.createdBy,
    required this.createdAt,
    required this.settings,
  });


  factory Chat.fromMap(Map<String, dynamic> map) {
  return Chat(
    id: map['_id'] as String,
    hide: map['hide'] as bool? ?? false,
    hidePass: map['hidePass'] as String,
    type: map['type'] as String,
    participants: (map['participants'] as List<dynamic>?)
          ?.map((x) => Participant.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
    name: map['name'] as String?,
    description: map['description'] as String?,
    groupPicture: map['groupPicture'] as String?,
    createdBy: map['createdBy'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    settings: Settings.fromMap(map['settings'] as Map<String, dynamic>),
  );
}

  // Convert Chat to a Map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'hide': hide,
      'hidePass': hidePass,
      'type': type,
      'participants': participants.map((x) => x.toMap()).toList(),
      'name': name,
      'description': description,
      'type': type,
      'participants': participants.map((x) => x.toMap()).toList(),
      'name': name,
      'description': description,
      'groupPicture': groupPicture,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'settings': settings.toMap(),
    };
  }

  // Convert Chat to JSON
  String toJson() => json.encode(toMap());

  // Factory constructor to create Chat from JSON
  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  // Copy constructor to create a copy with modified fields
  Chat copyWith({
    String? id,
    bool? hide,
    String? hidePass,
    String? type,
    List<Participant>? participants,
    String? name,
    String? description,
    String? groupPicture,
    String? createdBy,
    DateTime? createdAt,
    Settings? settings,
  }) {
    return Chat(
      id: id ?? this.id,
      type: type ?? this.type,
      hide: hide ?? this.hide,
      hidePass: hidePass ?? this.hidePass,
      participants: participants ?? this.participants,
      name: name ?? this.name,
      description: description ?? this.description,
      groupPicture: groupPicture ?? this.groupPicture,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }
}

class Participant {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String password;

  Participant({
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.password = '###**###',
  });


factory Participant.fromMap(Map<String, dynamic> map) {
  // Handle nested user object structure
  final userIdValue = map['userId'];
  String userId = '';
  String? name;
  String? avatar;
  bool? isOnline;
  DateTime? lastSeen;

  if (userIdValue is Map) {
    userId = userIdValue['_id']?.toString() ?? '';
    name = userIdValue['name']?.toString();
    avatar = userIdValue['avatar']?.toString();
    isOnline = userIdValue['isOnline'] as bool?;
    lastSeen = userIdValue['lastSeen'] != null 
        ? DateTime.parse(userIdValue['lastSeen'].toString())
        : null;
  } else {
    userId = userIdValue?.toString() ?? '';
  }

  return Participant(
    userId: userId,
    role: map['role']?.toString() ?? 'member',
    password: map['password']?.toString() ?? '###**###',
    joinedAt: map['joinedAt'] != null 
        ? DateTime.parse(map['joinedAt'].toString())
        : DateTime.now(),
  );
}

  // Convert Participant to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'password': password,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  // Factory constructor to create Participant from JSON
  factory Participant.fromJson(String source) =>
      Participant.fromMap(json.decode(source) as Map<String, dynamic>);

  // Convert Participant to JSON
  String toJson() => json.encode(toMap());

  // Copy constructor to create a copy with modified fields
  Participant copyWith({
    String? userId,
    String? role,
    String? password,
    DateTime? joinedAt,
  }) {
    return Participant(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      password: password ?? this.password,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

// class Settings {
//   final bool onlyAdminsCanMessage;
//   final bool onlyAdminsCanEditInfo;


//   Settings({
//     this.onlyAdminsCanMessage = false,
//     this.onlyAdminsCanEditInfo = true,
//   });

//   // Factory constructor to create Settings from a Map
//   factory Settings.fromMap(Map<String, dynamic> map) {
//     return Settings(
//       onlyAdminsCanMessage: map['onlyAdminsCanMessage'] as bool? ?? false,
//       onlyAdminsCanEditInfo: map['onlyAdminsCanEditInfo'] as bool? ?? true,
//     );
//   }

//   // Convert Settings to a Map
//   Map<String, dynamic> toMap() {
//     return {
//       'onlyAdminsCanMessage': onlyAdminsCanMessage,
//       'onlyAdminsCanEditInfo': onlyAdminsCanEditInfo,
//     };
//   }

//   // Factory constructor to create Settings from JSON
//   factory Settings.fromJson(String source) =>
//       Settings.fromMap(json.decode(source) as Map<String, dynamic>);

//   // Convert Settings to JSON
//   String toJson() => json.encode(toMap());

//   // Copy constructor to create a copy with modified fields
//   Settings copyWith({
//     bool? onlyAdminsCanMessage,
//     bool? onlyAdminsCanEditInfo,
//   }) {
//     return Settings(
//       onlyAdminsCanMessage: onlyAdminsCanMessage ?? this.onlyAdminsCanMessage,
//       onlyAdminsCanEditInfo: onlyAdminsCanEditInfo ?? this.onlyAdminsCanEditInfo,
//     );
//   }
// }


class BlockedUser {
  final String userId;
  final DateTime blockedAt;

  BlockedUser({
    required this.userId,
    required this.blockedAt,
  });

  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    return BlockedUser(
      userId: map['userId'] as String,
      blockedAt: DateTime.parse(map['blockedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'blockedAt': blockedAt.toIso8601String(),
    };
  }
}

class Settings {
  final bool onlyAdminsCanMessage;
  final bool onlyAdminsCanEditInfo;
  final List<BlockedUser> blockedUsers;

  Settings({
    this.onlyAdminsCanMessage = false,
    this.onlyAdminsCanEditInfo = true,
    List<BlockedUser>? blockedUsers,
  }) : blockedUsers = blockedUsers ?? [];

  // Factory constructor to create Settings from a Map
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      onlyAdminsCanMessage: map['onlyAdminsCanMessage'] as bool? ?? false,
      onlyAdminsCanEditInfo: map['onlyAdminsCanEditInfo'] as bool? ?? true,
      blockedUsers: map['blockedUsers'] != null
          ? List<BlockedUser>.from(
              (map['blockedUsers'] as List<dynamic>).map(
                (x) => BlockedUser.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  // Convert Settings to a Map
  Map<String, dynamic> toMap() {
    return {
      'onlyAdminsCanMessage': onlyAdminsCanMessage,
      'onlyAdminsCanEditInfo': onlyAdminsCanEditInfo,
      'blockedUsers': blockedUsers.map((x) => x.toMap()).toList(),
    };
  }

  // Factory constructor to create Settings from JSON
  factory Settings.fromJson(String source) =>
      Settings.fromMap(json.decode(source) as Map<String, dynamic>);

  // Convert Settings to JSON
  String toJson() => json.encode(toMap());

  // Copy constructor to create a copy with modified fields
  Settings copyWith({
    bool? onlyAdminsCanMessage,
    bool? onlyAdminsCanEditInfo,
    List<BlockedUser>? blockedUsers,
  }) {
    return Settings(
      onlyAdminsCanMessage: onlyAdminsCanMessage ?? this.onlyAdminsCanMessage,
      onlyAdminsCanEditInfo: onlyAdminsCanEditInfo ?? this.onlyAdminsCanEditInfo,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  // Helper methods for blocked users
  bool isUserBlocked(String userId) {
    return blockedUsers.any((user) => user.userId == userId);
  }

  Settings blockUser(String userId) {
    if (isUserBlocked(userId)) return this;
    
    return copyWith(
      blockedUsers: [
        ...blockedUsers,
        BlockedUser(
          userId: userId,
          blockedAt: DateTime.now(),
        ),
      ],
    );
  }

  Settings unblockUser(String userId) {
    return copyWith(
      blockedUsers: blockedUsers.where((user) => user.userId != userId).toList(),
    );
  }
}