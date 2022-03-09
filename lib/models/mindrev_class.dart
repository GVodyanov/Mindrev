import 'package:mindrev/models/mindrev_topic.dart';

class MindrevClass {
  String name = '';
  String color = '03A9F4';
  String date = DateTime.now().toIso8601String();
  List<MindrevTopic> topics = [];

  MindrevClass(this.name, this.color);

  void addTopic(MindrevTopic topic) {
    topics.add(topic);
  }
}
