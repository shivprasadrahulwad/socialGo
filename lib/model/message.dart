class Message {
  final String messageId;
  final String chatId;
  final String senderId;
  final MessageType type;
  final MessageContent content;
  final String? replyTo;
  final String? forwardedFrom;
  final List<ReadStatus> readBy;
  final List<DeliveryStatus> deliveredTo;
  final MessageStatus status;
  final DateTime createdAt;
  final List<Reaction> reactions;
  final bool isDeleted;
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
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
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
}

enum MessageType {
  text,
  image,
  video,
  audio,
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


enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageContent {
  final String? text;
  final String? mediaUrl;
  final String? thumbnail;
  final String? fileName;
  final int? fileSize;
  final int? duration;
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

class ContactInfo {
  final String? name;
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

class ReadStatus {
  final String userId;
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

class DeliveryStatus {
  final String userId;
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

class Reaction {
  final String user;
  final String emoji;
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

class DeleteStatus {
  final String userId;
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

// class Message {
//   final String chatId;
//   final String messageId;
//   final String sender;
//   final String messageType;
//   final MessageContent content;
//   final QuotedMessage quotedMessage;
//   final List<ReadBy> readBy;
//   final List<DeliveredTo> deliveredTo;
//   String status;
//   final List<String> deletedFor;
//   final List<Reaction> reactions;
//   DateTime createdAt;

//   Message({
//     required this.chatId,
//     required this.messageId,
//     required this.sender,
//     required this.messageType,
//     required this.content,
//     required this.quotedMessage,
//     required this.readBy,
//     required this.deliveredTo,
//     required this.status,
//     required this.deletedFor,
//     required this.reactions,
//     required this.createdAt,
//   });

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       chatId: json['_id'],
//       sender: json['sender'],
//       messageId: json['messageId'],
//       messageType: json['messageType'],
//       content: MessageContent.fromJson(json['content']),
//       quotedMessage: json['quotedMessage'] != null
//           ? QuotedMessage.fromJson(json['quotedMessage'])
//           : QuotedMessage(),
//       readBy: json['readBy'] != null
//           ? List<ReadBy>.from(
//               json['readBy'].map((read) => ReadBy.fromJson(read)),
//             )
//           : [],
//       deliveredTo: json['deliveredTo'] != null
//           ? List<DeliveredTo>.from(
//               json['deliveredTo'].map((delivered) => DeliveredTo.fromJson(delivered)),
//             )
//           : [],
//       status: json['status'],
//       deletedFor: json['deletedFor'] != null
//           ? List<String>.from(json['deletedFor'])
//           : [],
//       reactions: json['reactions'] != null
//           ? List<Reaction>.from(
//               json['reactions'].map((reaction) => Reaction.fromJson(reaction)),
//             )
//           : [],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'chatId': chatId,
//       'messageId': messageId,
//       'sender': sender,
//       'messageType': messageType,
//       'content': content.toJson(),
//       'quotedMessage': quotedMessage.toJson(),
//       'readBy': readBy.map((read) => read.toJson()).toList(),
//       'deliveredTo': deliveredTo.map((delivered) => delivered.toJson()).toList(),
//       'status': status,
//       'deletedFor': deletedFor,
//       'reactions': reactions.map((reaction) => reaction.toJson()).toList(),
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

// class MessageContent {
//   final String text;
//   final String mediaUrl;
//   final String fileName;
//   final int fileSize;
//   final int duration;

//   MessageContent({
//     required this.text,
//     required this.mediaUrl,
//     required this.fileName,
//     required this.fileSize,
//     required this.duration,
//   });

//   factory MessageContent.fromJson(Map<String, dynamic> json) {
//     return MessageContent(
//       text: json['text'] ?? '',
//       mediaUrl: json['mediaUrl'] ?? '',
//       fileName: json['fileName'] ?? '',
//       fileSize: json['fileSize'] ?? 0,
//       duration: json['duration'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'text': text,
//       'mediaUrl': mediaUrl,
//       'fileName': fileName,
//       'fileSize': fileSize,
//       'duration': duration,
//     };
//   }
// }

// class QuotedMessage {
//   final String messageId;
//   final String content;
//   final String type;

//   QuotedMessage({
//     this.messageId = '',
//     this.content = '',
//     this.type = '',
//   });

//   factory QuotedMessage.fromJson(Map<String, dynamic> json) {
//     return QuotedMessage(
//       messageId: json['messageId'] ?? '',
//       content: json['content'] ?? '',
//       type: json['type'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'messageId': messageId,
//       'content': content,
//       'type': type,
//     };
//   }
// }

// class ReadBy {
//   final String user;
//   final DateTime readAt;

//   ReadBy({
//     required this.user,
//     required this.readAt,
//   });

//   factory ReadBy.fromJson(Map<String, dynamic> json) {
//     return ReadBy(
//       user: json['user'],
//       readAt: DateTime.parse(json['readAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'user': user,
//       'readAt': readAt.toIso8601String(),
//     };
//   }
// }

// class DeliveredTo {
//   final String user;
//   final DateTime deliveredAt;

//   DeliveredTo({
//     required this.user,
//     required this.deliveredAt,
//   });

//   factory DeliveredTo.fromJson(Map<String, dynamic> json) {
//     return DeliveredTo(
//       user: json['user'],
//       deliveredAt: DateTime.parse(json['deliveredAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'user': user,
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
//     required this.addedAt,
//   });

//   factory Reaction.fromJson(Map<String, dynamic> json) {
//     return Reaction(
//       user: json['user'],
//       emoji: json['emoji'],
//       addedAt: DateTime.parse(json['addedAt']),
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
