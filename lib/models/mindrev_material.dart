import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_material.g.dart';

@HiveType(typeId: 3)
class MindrevMaterial {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  String type = '';

  @HiveField(2)
  String date = DateTime.now().toIso8601String();

  MindrevMaterial(this.name, this.type);

  toJson() => {
        'name': name,
        'type': type,
        'date': date,
      };

  MindrevMaterial.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    type = json['type'];
    date = json['date'];
  }
}
