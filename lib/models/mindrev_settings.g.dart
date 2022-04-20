// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindrev_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindrevSettingsAdapter extends TypeAdapter<MindrevSettings> {
  @override
  final int typeId = 4;

  @override
  MindrevSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindrevSettings()
      ..uiColors = fields[0] as bool
      ..confetti = fields[1] as bool
      ..theme = fields[2] as String
      ..lang = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, MindrevSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uiColors)
      ..writeByte(1)
      ..write(obj.confetti)
      ..writeByte(2)
      ..write(obj.theme)
      ..writeByte(3)
      ..write(obj.lang);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindrevSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
