// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindrev_material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindrevMaterialAdapter extends TypeAdapter<MindrevMaterial> {
  @override
  final int typeId = 2;

  @override
  MindrevMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindrevMaterial(
      fields[0] as String,
      fields[1] as String,
    )..date = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, MindrevMaterial obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MindrevMaterialAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
