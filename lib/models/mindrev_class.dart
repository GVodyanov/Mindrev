import 'package:mindrev/models/mindrev_topic.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_class.g.dart';

@HiveType(typeId: 0)
class MindrevClass {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  String color = '03A9F4';

  @HiveField(2)
  String date = DateTime.now().toIso8601String();

  @HiveField(3)
  List<MindrevTopic> topics = [];

  MindrevClass(this.name, this.color);

  void addTopic(MindrevTopic topic) {
    topics.add(topic);
  }
}
