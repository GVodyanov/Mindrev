// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindrev_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindrevClassAdapter extends TypeAdapter<MindrevClass> {
  @override
  final int typeId = 0;

  @override
  MindrevClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindrevClass(
      fields[0] as String,
      fields[1] as String,
    )
      ..date = fields[2] as String
      ..topics = (fields[3] as List).cast<MindrevTopic>();
  }

  @override
  void write(BinaryWriter writer, MindrevClass obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.topics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MindrevClassAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
