import 'dart:convert';

class Chat {
  final String id;
  final String type;
  final List<Participant> participants;
  final String? name; 
  final String? description;
  final String? groupPicture;
  final String? createdBy; 
  final DateTime createdAt;
  final Settings settings;

  Chat({
    required this.id,
    required this.type,
    required this.participants,
    this.name,
    this.description,
    this.groupPicture,
    this.createdBy,
    required this.createdAt,
    required this.settings,
  });

  // Factory constructor to create Chat from a Map
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['_id'] as String,
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
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;

  Participant({
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
  });

  // Factory constructor to create Participant from a Map
factory Participant.fromMap(Map<String, dynamic> map) {
    // Handle both cases where userId might be a string or an object
    final userIdValue = map['userId'];
    final String userId = userIdValue is Map 
        ? userIdValue['_id']?.toString() ?? '' 
        : userIdValue?.toString() ?? '';

    return Participant(
      userId: userId,
      role: map['role']?.toString() ?? 'member',
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
    DateTime? joinedAt,
  }) {
    return Participant(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class Settings {
  final bool onlyAdminsCanMessage;
  final bool onlyAdminsCanEditInfo;

  Settings({
    this.onlyAdminsCanMessage = false,
    this.onlyAdminsCanEditInfo = true,
  });

  // Factory constructor to create Settings from a Map
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      onlyAdminsCanMessage: map['onlyAdminsCanMessage'] as bool? ?? false,
      onlyAdminsCanEditInfo: map['onlyAdminsCanEditInfo'] as bool? ?? true,
    );
  }

  // Convert Settings to a Map
  Map<String, dynamic> toMap() {
    return {
      'onlyAdminsCanMessage': onlyAdminsCanMessage,
      'onlyAdminsCanEditInfo': onlyAdminsCanEditInfo,
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
  }) {
    return Settings(
      onlyAdminsCanMessage: onlyAdminsCanMessage ?? this.onlyAdminsCanMessage,
      onlyAdminsCanEditInfo: onlyAdminsCanEditInfo ?? this.onlyAdminsCanEditInfo,
    );
  }
}
