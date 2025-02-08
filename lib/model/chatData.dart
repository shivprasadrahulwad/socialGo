import 'package:hive/hive.dart';

part 'chatData.g.dart';

@HiveType(typeId: 10)
class ChatData extends HiveObject {
  @HiveField(0)
  final String chatId;

  @HiveField(1)
  final String receiverId;

  ChatData({required this.chatId, required this.receiverId});
}
