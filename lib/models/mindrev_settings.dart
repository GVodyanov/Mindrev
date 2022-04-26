import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_settings.g.dart';

@HiveType(typeId: 4)
class MindrevSettings {
  @HiveField(0)
  bool uiColors = true;

  @HiveField(1)
  bool confetti = true;

  @HiveField(2)
  String theme = 'Default';

  @HiveField(3)
  String lang = 'en';

  //for notes material
  @HiveField(4)
  bool? markdownEdit = false;
}
