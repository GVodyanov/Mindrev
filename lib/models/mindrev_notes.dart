import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_notes.g.dart';

@HiveType(typeId: 6)
class MindrevNotes {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  String date = DateTime.now().toIso8601String();

  @HiveField(3)
  String content = '';

  @HiveField(4)
  List<String> images = [];

  MindrevNotes(this.name);

  MindrevNotes.fromFull (Map json) {
    name = json['name'];
    date = json['date'];
    content = json['content'];
    images = json['images'];
  }

  Future<Map> toJson(String id) async {
    //add imageData to normal attributes
    //as we need to transfer the images as well
    var box = await Hive.openBox('$id-images');
    Map imageData = {};
    for (String i in images) {
      imageData['i'] = await box.get(i);
    }

    return {
      'name': name,
      'date': date,
      'content': content,
      'images': images,
      'imageData': imageData,
    };
  }

  static Future<MindrevNotes> fromJson(Map json, String id) async {
    //we have to fill in images from memory
    var box = await Hive.openBox('$id-images');
    for (String i in json['images']) {
      await box.put(i, json['imageData'][i]);
    }

    //use constructor with json to actually get the object
    return MindrevNotes.fromFull(json);
  }
}
