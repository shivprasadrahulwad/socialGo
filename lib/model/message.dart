// // ignore_for_file: public_member_api_docs, sort_constructors_first
// class Message {
//   final String messageId;
//   final String chatId;
//   final String senderId;
//   final MessageType type;
//   final MessageContent content;
//   final String? replyTo;
//   final String? forwardedFrom;
//   final List<ReadStatus> readBy;
//   final List<DeliveryStatus> deliveredTo;
//   final MessageStatus status;
//   final DateTime createdAt;
//   final List<Reaction> reactions;
//   final bool isDeleted;
//   final List<DeleteStatus> deletedFor;

//   Message({
//     required this.messageId,
//     required this.chatId,
//     required this.senderId,
//     required this.type,
//     required this.content,
//     this.replyTo,
//     this.forwardedFrom,
//     this.readBy = const [],
//     this.deliveredTo = const [],
//     this.status = MessageStatus.sending,
//     DateTime? createdAt,
//     this.reactions = const [],
//     this.isDeleted = false,
//     this.deletedFor = const [],
//   }) : this.createdAt = createdAt ?? DateTime.now();

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       messageId: json['messageId'] as String,
//       chatId: json['chatId'] as String,
//       senderId: json['senderId'] as String,
//       type: MessageType.values.firstWhere(
//         (e) => e.toString() == 'MessageType.${json['type']}',
//       ),
//       content: MessageContent.fromJson(json['content'] ?? {}),
//       replyTo: json['replyTo'] as String?,
//       forwardedFrom: json['forwardedFrom'] as String?,
//       readBy: (json['readBy'] as List<dynamic>?)
//           ?.map((e) => ReadStatus.fromJson(e as Map<String, dynamic>))
//           .toList() ?? [],
//       deliveredTo: (json['deliveredTo'] as List<dynamic>?)
//           ?.map((e) => DeliveryStatus.fromJson(e as Map<String, dynamic>))
//           .toList() ?? [],
//       status: MessageStatus.values.firstWhere(
//         (e) => e.toString() == 'MessageStatus.${json['status']}',
//       ),
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       reactions: (json['reactions'] as List<dynamic>?)
//           ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
//           .toList() ?? [],
//       isDeleted: json['isDeleted'] as bool? ?? false,
//       deletedFor: (json['deletedFor'] as List<dynamic>?)
//           ?.map((e) => DeleteStatus.fromJson(e as Map<String, dynamic>))
//           .toList() ?? [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'messageId':messageId,
//       'chatId': chatId,
//       'senderId': senderId,
//       'type': type.toString().split('.').last,
//       'content': content.toJson(),
//       'replyTo': replyTo,
//       'forwardedFrom': forwardedFrom,
//       'readBy': readBy.map((e) => e.toJson()).toList(),
//       'deliveredTo': deliveredTo.map((e) => e.toJson()).toList(),
//       'status': status.toString().split('.').last,
//       'createdAt': createdAt.toIso8601String(),
//       'reactions': reactions.map((e) => e.toJson()).toList(),
//       'isDeleted': isDeleted,
//       'deletedFor': deletedFor.map((e) => e.toJson()).toList(),
//     };
//   }

//   Message copyWith({
//     String? messageId,
//     String? chatId,
//     String? senderId,
//     MessageType? type,
//     MessageContent? content,
//     String? replyTo,
//     String? forwardedFrom,
//     List<ReadStatus>? readBy,
//     List<DeliveryStatus>? deliveredTo,
//     MessageStatus? status,
//     DateTime? createdAt,
//     List<Reaction>? reactions,
//     bool? isDeleted,
//     List<DeleteStatus>? deletedFor,
//   }) {
//     return Message(
//       messageId: messageId ?? this.messageId,
//       chatId: chatId ?? this.chatId,
//       senderId: senderId ?? this.senderId,
//       type: type ?? this.type,
//       content: content ?? this.content,
//       replyTo: replyTo ?? this.replyTo,
//       forwardedFrom: forwardedFrom ?? this.forwardedFrom,
//       readBy: readBy ?? this.readBy,
//       deliveredTo: deliveredTo ?? this.deliveredTo,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       reactions: reactions ?? this.reactions,
//       isDeleted: isDeleted ?? this.isDeleted,
//       deletedFor: deletedFor ?? this.deletedFor,
//     );
//   }
// }

// enum MessageType {
//   text,
//   image,
//   video,
//   audio,
//   document,
// }

// extension MessageTypeExtension on MessageType {
//   static MessageType fromString(String value) {
//     return MessageType.values.firstWhere(
//       (type) => type.toString().split('.').last == value,
//       orElse: () => MessageType.text,
//     );
//   }
// }


// enum MessageStatus {
//   sending,
//   sent,
//   delivered,
//   read,
//   failed,
// }

// class MessageContent {
//   final String? text;
//   final String? mediaUrl;
//   final String? thumbnail;
//   final String? fileName;
//   final int? fileSize;
//   final int? duration;
//   final ContactInfo? contactInfo;

//   MessageContent({
//     this.text,
//     this.mediaUrl,
//     this.thumbnail,
//     this.fileName,
//     this.fileSize,
//     this.duration,
//     this.contactInfo,
//   });

//   factory MessageContent.fromJson(Map<String, dynamic> json) {
//     return MessageContent(
//       text: json['text'] as String?,
//       mediaUrl: json['mediaUrl'] as String?,
//       thumbnail: json['thumbnail'] as String?,
//       fileName: json['fileName'] as String?,
//       fileSize: json['fileSize'] as int?,
//       duration: json['duration'] as int?,
//       contactInfo: json['contactInfo'] != null
//           ? ContactInfo.fromJson(json['contactInfo'] as Map<String, dynamic>)
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'text': text,
//       'mediaUrl': mediaUrl,
//       'thumbnail': thumbnail,
//       'fileName': fileName,
//       'fileSize': fileSize,
//       'duration': duration,
//       'contactInfo': contactInfo?.toJson(),
//     };
//   }
// }

// class ContactInfo {
//   final String? name;
//   final String? phoneNumber;

//   ContactInfo({
//     this.name,
//     this.phoneNumber,
//   });

//   factory ContactInfo.fromJson(Map<String, dynamic> json) {
//     return ContactInfo(
//       name: json['name'] as String?,
//       phoneNumber: json['phoneNumber'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'phoneNumber': phoneNumber,
//     };
//   }
// }

// class ReadStatus {
//   final String userId;
//   final DateTime readAt;

//   ReadStatus({
//     required this.userId,
//     DateTime? readAt,
//   }) : this.readAt = readAt ?? DateTime.now();

//   factory ReadStatus.fromJson(Map<String, dynamic> json) {
//     return ReadStatus(
//       userId: json['userId'] as String,
//       readAt: DateTime.parse(json['readAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'readAt': readAt.toIso8601String(),
//     };
//   }
// }

// class DeliveryStatus {
//   final String userId;
//   final DateTime deliveredAt;

//   DeliveryStatus({
//     required this.userId,
//     DateTime? deliveredAt,
//   }) : this.deliveredAt = deliveredAt ?? DateTime.now();

//   factory DeliveryStatus.fromJson(Map<String, dynamic> json) {
//     return DeliveryStatus(
//       userId: json['userId'] as String,
//       deliveredAt: DateTime.parse(json['deliveredAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'deliveredAt': deliveredAt.toIso8601String(),
//     };
//   }
// }

// class Reaction {
//   final String user;
//   final String emoji;
//   final DateTime addedAt;

//   Reaction({
//     required this.user,
//     required this.emoji,
//     DateTime? addedAt,
//   }) : this.addedAt = addedAt ?? DateTime.now();

//   factory Reaction.fromJson(Map<String, dynamic> json) {
//     return Reaction(
//       user: json['user'] as String,
//       emoji: json['emoji'] as String,
//       addedAt: DateTime.parse(json['addedAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'user': user,
//       'emoji': emoji,
//       'addedAt': addedAt.toIso8601String(),
//     };
//   }
// }

// class DeleteStatus {
//   final String userId;
//   final DateTime deletedAt;

//   DeleteStatus({
//     required this.userId,
//     DateTime? deletedAt,
//   }) : this.deletedAt = deletedAt ?? DateTime.now();

//   factory DeleteStatus.fromJson(Map<String, dynamic> json) {
//     return DeleteStatus(
//       userId: json['userId'] as String,
//       deletedAt: DateTime.parse(json['deletedAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'deletedAt': deletedAt.toIso8601String(),
//     };
//   }
// }








import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String messageId;
  
  @HiveField(1)
  final String chatId;
  
  @HiveField(2)
  final String senderId;
  
  @HiveField(3)
  final MessageType type;
  
  @HiveField(4)
  final MessageContent content;
  
  @HiveField(5)
  final String? replyTo;
  
  @HiveField(6)
  final String? forwardedFrom;
  
  @HiveField(7)
  final List<ReadStatus> readBy;
  
  @HiveField(8)
  final List<DeliveryStatus> deliveredTo;
  
  @HiveField(9)
  final MessageStatus status;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final List<Reaction> reactions;
  
  @HiveField(12)
  final bool isDeleted;
  
  @HiveField(13)
  final List<DeleteStatus> deletedFor;

  Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.type,
    required this.content,
    this.replyTo,
    this.forwardedFrom,
    this.readBy = const [],
    this.deliveredTo = const [],
    this.status = MessageStatus.sending,
    DateTime? createdAt,
    this.reactions = const [],
    this.isDeleted = false,
    this.deletedFor = const [],
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      content: MessageContent.fromJson(json['content'] ?? {}),
      replyTo: json['replyTo'] as String?,
      forwardedFrom: json['forwardedFrom'] as String?,
      readBy: (json['readBy'] as List<dynamic>?)
          ?.map((e) => ReadStatus.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      deliveredTo: (json['deliveredTo'] as List<dynamic>?)
          ?.map((e) => DeliveryStatus.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sending,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedFor: (json['deletedFor'] as List<dynamic>?)
          ?.map((e) => DeleteStatus.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'messageId':messageId,
      'chatId': chatId,
      'senderId': senderId,
      'type': type.toString().split('.').last,
      'content': content.toJson(),
      'replyTo': replyTo,
      'forwardedFrom': forwardedFrom,
      'readBy': readBy.map((e) => e.toJson()).toList(),
      'deliveredTo': deliveredTo.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'isDeleted': isDeleted,
      'deletedFor': deletedFor.map((e) => e.toJson()).toList(),
    };
  }

  Message copyWith({
    String? messageId,
    String? chatId,
    String? senderId,
    MessageType? type,
    MessageContent? content,
    String? replyTo,
    String? forwardedFrom,
    List<ReadStatus>? readBy,
    List<DeliveryStatus>? deliveredTo,
    MessageStatus? status,
    DateTime? createdAt,
    List<Reaction>? reactions,
    bool? isDeleted,
    List<DeleteStatus>? deletedFor,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      content: content ?? this.content,
      replyTo: replyTo ?? this.replyTo,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }
}

@HiveType(typeId: 1)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  video,
  @HiveField(3)
  audio,
  @HiveField(4)
  document,
}

extension MessageTypeExtension on MessageType {
  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => MessageType.text,
    );
  }
}


@HiveType(typeId: 2)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  delivered,
  @HiveField(3)
  read,
  @HiveField(4)
  failed,
}

@HiveType(typeId: 3)
class MessageContent {
  @HiveField(0)
  final String? text;
  
  @HiveField(1)
  final String? mediaUrl;
  
  @HiveField(2)
  final String? thumbnail;
  
  @HiveField(3)
  final String? fileName;
  
  @HiveField(4)
  final int? fileSize;
  
  @HiveField(5)
  final int? duration;
  
  @HiveField(6)
  final ContactInfo? contactInfo;

  MessageContent({
    this.text,
    this.mediaUrl,
    this.thumbnail,
    this.fileName,
    this.fileSize,
    this.duration,
    this.contactInfo,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      text: json['text'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnail: json['thumbnail'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      duration: json['duration'] as int?,
      contactInfo: json['contactInfo'] != null
          ? ContactInfo.fromJson(json['contactInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'mediaUrl': mediaUrl,
      'thumbnail': thumbnail,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'contactInfo': contactInfo?.toJson(),
    };
  }
}

@HiveType(typeId: 4)
class ContactInfo {
  @HiveField(0)
  final String? name;
  
  @HiveField(1)
  final String? phoneNumber;

  ContactInfo({
    this.name,
    this.phoneNumber,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      name: json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }
}

@HiveType(typeId: 5)
class ReadStatus {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final DateTime readAt;

  ReadStatus({
    required this.userId,
    DateTime? readAt,
  }) : this.readAt = readAt ?? DateTime.now();

  factory ReadStatus.fromJson(Map<String, dynamic> json) {
    return ReadStatus(
      userId: json['userId'] as String,
      readAt: DateTime.parse(json['readAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'readAt': readAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 6)
class DeliveryStatus {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final DateTime deliveredAt;

  DeliveryStatus({
    required this.userId,
    DateTime? deliveredAt,
  }) : this.deliveredAt = deliveredAt ?? DateTime.now();

  factory DeliveryStatus.fromJson(Map<String, dynamic> json) {
    return DeliveryStatus(
      userId: json['userId'] as String,
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deliveredAt': deliveredAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 7)
class Reaction {
  @HiveField(0)
  final String user;
  @HiveField(1)
  final String emoji;
  @HiveField(2)
  final DateTime addedAt;

  Reaction({
    required this.user,
    required this.emoji,
    DateTime? addedAt,
  }) : this.addedAt = addedAt ?? DateTime.now();

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      user: json['user'] as String,
      emoji: json['emoji'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'emoji': emoji,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 8)
class DeleteStatus {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final DateTime deletedAt;

  DeleteStatus({
    required this.userId,
    DateTime? deletedAt,
  }) : this.deletedAt = deletedAt ?? DateTime.now();

  factory DeleteStatus.fromJson(Map<String, dynamic> json) {
    return DeleteStatus(
      userId: json['userId'] as String,
      deletedAt: DateTime.parse(json['deletedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deletedAt': deletedAt.toIso8601String(),
    };
  }
}
