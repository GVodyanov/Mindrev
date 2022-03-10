import 'package:mindrev/models/mindrev_material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_topic.g.dart';

@HiveType(typeId: 1)
class MindrevTopic {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  String date = DateTime.now().toIso8601String();

  @HiveField(2)
  List<MindrevMaterial> materials = [];

  MindrevTopic(this.name);
}
