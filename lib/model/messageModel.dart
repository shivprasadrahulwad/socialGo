// class MessageModel {
//   String type;
//   String message;
//   String time;
//   String path;
//   String?  duration;
//     bool isRead;  
//   String? readAt;  
//   String messageId;  

//   MessageModel({
//     required this.type,
//     required this.message,
//     required this.time,
//     required this.path,
//     this.duration,
//     this.isRead = false,  // Default to false
//     this.readAt,
//     required this.messageId,
//   });

//   // Factory constructor to create a MessageModel from a Map
//   factory MessageModel.fromMap(Map<String, dynamic> map) {
//     return MessageModel(
//       type: map['type'] ?? '', // Handle null or missing values
//       message: map['message'] ?? '',
//       time: map['time'] ?? '',
//       path: map['path'] ?? '',
//       duration: map['duration'],
//       isRead: map['isRead'] ?? false,
//       readAt: map['readAt'],
//       messageId: map['messageId'] ?? '',
//     );
//   }
// }
