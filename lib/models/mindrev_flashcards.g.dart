// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindrev_flashcards.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindrevFlashcardsAdapter extends TypeAdapter<MindrevFlashcards> {
  @override
  final int typeId = 3;

  @override
  MindrevFlashcards read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindrevFlashcards(
      fields[0] as String,
    )
      ..date = fields[1] as String
      ..cards = (fields[2] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList();
  }

  @override
  void write(BinaryWriter writer, MindrevFlashcards obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.cards);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindrevFlashcardsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
