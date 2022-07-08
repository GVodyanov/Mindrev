// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindrev_notes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindrevNotesAdapter extends TypeAdapter<MindrevNotes> {
  @override
  final int typeId = 6;

  @override
  MindrevNotes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindrevNotes(
      fields[0] as String,
    )
      ..date = fields[1] as String
      ..content = fields[3] as String
      ..images = (fields[4] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, MindrevNotes obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindrevNotesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
