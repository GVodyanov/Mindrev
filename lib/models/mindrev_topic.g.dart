// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindrev_topic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindrevTopicAdapter extends TypeAdapter<MindrevTopic> {
  @override
  final int typeId = 2;

  @override
  MindrevTopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindrevTopic(
      fields[0] as String,
    )
      ..date = fields[1] as String
      ..materials = (fields[2] as List).cast<MindrevMaterial>();
  }

  @override
  void write(BinaryWriter writer, MindrevTopic obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.materials);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindrevTopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
