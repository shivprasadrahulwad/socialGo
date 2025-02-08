// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatDataAdapter extends TypeAdapter<ChatData> {
  @override
  final int typeId = 10;

  @override
  ChatData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatData(
      chatId: fields[0] as String,
      receiverId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.chatId)
      ..writeByte(1)
      ..write(obj.receiverId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
