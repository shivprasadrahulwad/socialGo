// ignore_for_file: public_member_api_docs, sort_constructors_first
// class GroupMessageModel {
//   final String senderId;
//   final String senderName;
//   final String message;
//   final String timestamp;


//   GroupMessageModel({
//     required this.senderId,
//     required this.senderName,
//     required this.message,
//     required this.timestamp,
//   });
// }


class MsgModel {
  String type;
  String msg;
  String sender;

  MsgModel({
    required this.type,
    required this.msg,
    required this.sender,
  });
}
