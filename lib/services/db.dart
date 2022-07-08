import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/models/mindrev_notes.dart';
import 'package:mindrev/models/mindrev_structure.dart';
import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/models/mindrev_material.dart';

import 'package:hive_flutter/hive_flutter.dart';

class Local {
  //open hive box
  var box = Hive.lazyBox('mindrev');

  //get structure
  Future<MindrevStructure> getStructure() async {
    MindrevStructure? structure = await box.get('structure');
    //if it is empty add it to database
    if (structure == null) await box.put('structure', MindrevStructure());

    return structure ?? MindrevStructure();
  }

  //update structure
  Future<bool> updateStructure(MindrevStructure structure) async {
    await box.put('structure', structure);
    return true;
  }

  //get settings
  Future<MindrevSettings> getSettings() async {
    MindrevSettings? settings = await box.get('settings');
    //if it is empty add it to database
    if (settings == null) await box.put('settings', MindrevSettings());

    return settings ?? MindrevSettings();
  }

  //update settings
  Future<bool> updateSettings(MindrevSettings settings) async {
    await box.put('settings', settings);
    return true;
  }

  //get classes
  Future<List<MindrevClass>?> getClasses() async {
    MindrevStructure? structure = await box.get('structure');
    return structure?.classes;
  }

  //new class
  Future<bool> newClass(MindrevClass newClass) async {
    MindrevStructure structure = await getStructure();

    //check if class already exists
    if (!structure.classes.contains(newClass)) {
      structure.classes.add(newClass);
    }

    await updateStructure(structure);
    return true; //we want to return this to easily update home page
  }

  //update class
  Future<bool> updateClass(
    MindrevClass mClass,
    MindrevStructure structure, [
    String? newName,
  ]) async {
    if (newName != null) {
      mClass.name = newName;
    }

    //update structure
    structure.classes[structure.classes.indexOf(mClass)] = mClass;

    await updateStructure(structure);

    return true;
  }

  //delete class
  Future<bool> deleteClass(MindrevClass mClass, MindrevStructure structure) async {
    List toDelete = [];

    for (MindrevTopic i in mClass.topics) {
      for (MindrevMaterial j in i.materials) {
        toDelete.add(
          j.id.toString(),
        );
      }
    }

    for (String id in toDelete) {
      await box.delete(id);
    }

    structure.classes.remove(mClass);

    await updateStructure(structure);

    return true;
  }

  Future<MindrevClass> newTopic(
    MindrevTopic newTopic,
    MindrevClass mClass,
    MindrevStructure structure,
  ) async {
    //check if topic already exists and if doesn't add it to the topics list
    if (!mClass.topics.contains(newTopic)) {
      mClass.topics.add(newTopic);
    }

    await updateClass(mClass, structure);

    return mClass; //we want to return this to easily update topics page
  }

  //update topic
  Future<MindrevTopic> updateTopic(
    MindrevTopic topic,
    MindrevClass mClass,
    MindrevStructure structure, [
    String? newName,
  ]) async {
    if (newName != null) {
      topic.name = newName;
    }
    //update mClass
    mClass.topics[mClass.topics.indexOf(topic)] = topic;

    await updateClass(mClass, structure);
    return topic;
  }

  //delete topic
  Future<bool> deleteTopic(
    MindrevTopic topic,
    MindrevClass mClass,
    MindrevStructure structure,
  ) async {
    List toDelete = [];

    for (MindrevMaterial j in topic.materials) {
      toDelete.add(
        j.id.toString(),
      );
    }

    for (String path in toDelete) {
      await box.delete(path);
    }

    mClass.topics.remove(topic);

    await updateClass(mClass, structure);

    return true;
  }

  Future<MindrevTopic> newMaterial(
    MindrevMaterial newMaterial,
    MindrevTopic topic,
    MindrevClass mClass,
    MindrevStructure structure,
  ) async {
    if (newMaterial.type == 'Flashcards') {
      await box.put(
        newMaterial.id.toString(),
        MindrevFlashcards(newMaterial.name),
      );
    }
    if (newMaterial.type == 'Notes') {
      await box.put(
        newMaterial.id.toString(),
        MindrevNotes(newMaterial.name),
      );
    }
    //check if topic already exists and if doesn't add it to the topics list
    if (!topic.materials.contains(newMaterial)) {
      topic.materials.add(newMaterial);
    }

    await updateTopic(topic, mClass, structure);

    return topic; //we want to return this to easily update topics page
  }

  //update material
  Future<MindrevMaterial> updateMaterial(
    MindrevMaterial material,
    MindrevTopic topic,
    MindrevClass mClass,
    MindrevStructure structure, [
    String? newName,
  ]) async {
    //change name and update topic parent
    material.name = newName!;
    await updateTopic(topic, mClass, structure);
    return material;
  }

  //delete material
  Future<bool> deleteMaterial(
    MindrevMaterial material,
    MindrevTopic topic,
    MindrevClass mClass,
    MindrevStructure structure,
  ) async {
    List toDelete = [];

    for (MindrevMaterial j in topic.materials) {
      toDelete.add(
        j.id.toString(),
      );
    }

    for (String path in toDelete) {
      await box.delete(path);
    }

    topic.materials.remove(material);

    await updateTopic(topic, mClass, structure);

    return true;
  }

  Future getMaterialData(
    MindrevMaterial material,
  ) async {
    return await box.get(material.id.toString());
  }

  Future<bool> updateMaterialData(
    MindrevMaterial material,
    var subMaterial,
  ) async {
    await box.put(material.id.toString(), subMaterial);
    return true;
  }
}

Local local = Local();
