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
    return MindrevNotes()
      ..name = fields[0] as String
      ..date = fields[1] as String
      ..notus = fields[3] as NotusDocument
      ..markdown = fields[4] as String;
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
      ..write(obj.notus)
      ..writeByte(4)
      ..write(obj.markdown);
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
