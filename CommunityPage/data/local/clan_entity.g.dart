// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clan_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClanEntityAdapter extends TypeAdapter<ClanEntity> {
  @override
  final int typeId = 2;

  @override
  ClanEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClanEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarUrl: fields[2] as String?,
      lastMessage: fields[3] as String?,
      lastMessageAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ClanEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarUrl)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.lastMessageAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClanEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
