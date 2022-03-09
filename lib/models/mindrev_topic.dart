import 'package:mindrev/models/mindrev_material.dart';

class MindrevTopic {
  String name = '';
  String date = DateTime.now().toIso8601String();
  List<MindrevMaterial> materials = [];

  MindrevTopic(this.name);

  void addMaterial(MindrevMaterial material) {
  	materials.add(material);
  }
}
