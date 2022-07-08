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

  @HiveField(3)
  int id = 0;

  MindrevMaterial(this.name, this.type, this.id);

  static Future<MindrevMaterial> create(String name, String type) async {
    int id = 0;
    //take last used ID, increment it, give it to the new material, and save it
    LazyBox box = Hive.lazyBox('mindrev');
    int? previousId = await box.get('materialId');
    previousId ??= 0; previousId += 1;
    id = previousId;
    await box.put('materialId', previousId);

    return MindrevMaterial(name, type, id);
  }


  toJson() => {
        'name': name,
        'type': type,
        'date': date,
        'id': id,
      };

  MindrevMaterial.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    type = json['type'];
    date = json['date'];
    id = json['id'];
  }
}
