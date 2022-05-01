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

  MindrevNotes(this.name);
}