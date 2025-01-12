// import 'dart:convert';

import 'dart:convert';
class ChatModel {
  String name;
  String icon;
  bool isGroup;
  String time;
  String currentMessage;
  String status;
  bool select = false;
  int id;
  
  ChatModel({
    required this.name,
    required this.icon,
    required this.isGroup,
    required this.time,
    required this.currentMessage,
    required this.status,
    this.select = false,
    required this.id,
  });

  ChatModel copyWith({
    String? name,
    String? icon,
    bool? isGroup,
    String? time,
    String? currentMessage,
    String? status,
    bool? select,
    int? id,
  }) {
    return ChatModel(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isGroup: isGroup ?? this.isGroup,
      time: time ?? this.time,
      currentMessage: currentMessage ?? this.currentMessage,
      status: status ?? this.status,
      select: select ?? this.select,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'icon': icon,
      'isGroup': isGroup,
      'time': time,
      'currentMessage': currentMessage,
      'status': status,
      'select': select,
      'id': id,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      name: map['name'] as String,
      icon: map['icon'] as String,
      isGroup: map['isGroup'] as bool,
      time: map['time'] as String,
      currentMessage: map['currentMessage'] as String,
      status: map['status'] as String,
      select: map['select'] as bool,
      id: map['id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
