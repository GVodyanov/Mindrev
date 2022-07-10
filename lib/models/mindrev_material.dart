import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/models/mindrev_notes.dart';
import 'package:mindrev/services/db.dart';

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

  MindrevMaterial.fromFull (Map json) {
    name = json['name'];
    type = json['type'];
    date = json['date'];
    id = json['id'];
  }

  static Future<MindrevMaterial> create(String name, String type) async {
    //take last used ID, increment it, give it to the new material, and save it
    LazyBox box = Hive.lazyBox('mindrev');
    int? previousId = await box.get('materialId');
    previousId ??= 0; previousId += 1;
    int id = previousId;
    await box.put('materialId', previousId);

    return MindrevMaterial(name, type, id);
  }


  Future<Map> toJson() async {
    //also get material data and transform to json, pass data and not ID
    var materialData = await local.getMaterialData(this);
    var data = await materialData.toJson(id.toString());

    return {
        'name': name,
        'type': type,
        'date': date,
        'data': data,
      };
  }

  static Future<MindrevMaterial> fromJson (Map json) async {
    LazyBox box = Hive.lazyBox('mindrev');
    int? previousId = await box.get('materialId');
    previousId ??= 0; previousId += 1;
    int id = previousId;

    //notes has a different, async, fromJson method because of images, we have
    //to account for that
    if (json['type'] == 'notes') {
       await box.put(id.toString(), await MindrevNotes.fromJson(json['data'], id.toString()));
    } else if (json['type'] == 'flashcards'){
      await box.put(id.toString(), MindrevFlashcards.fromJson(json['data']));
    }

    json['id'] = id;
    return MindrevMaterial.fromFull(json);
  }
}
