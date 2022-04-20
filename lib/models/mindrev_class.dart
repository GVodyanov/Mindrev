import 'package:flutter/material.dart';
import 'package:mindrev/models/mindrev_structure.dart';

import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/services/color_to_hex.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_class.g.dart';

@HiveType(typeId: 1)
class MindrevClass {
  @HiveField(0)
  String name = ''; //class name

  @HiveField(1)
  String color = colorToHex(Colors.lightBlue); //accent color for class

  @HiveField(2)
  String date = DateTime.now().toIso8601String(); //creation date

  @HiveField(3)
  List<MindrevTopic> topics = []; //topics that the class contains

  MindrevClass(this.name, this.color); //constructor

  void addTopic(MindrevTopic topic) {
    //add a new topic
    topics.add(topic);
  }

  List<Widget> displayTopics(
    var context,
    MindrevClass mClass,
    MindrevStructure structure,
    theme,
  ) {
    List<Widget> result = [];
    for (var i in mClass.topics) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(i.name, style: defaultPrimaryTextStyle()),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/materials',
                arguments: {
                  'structure': structure,
                  'class': mClass,
                  'topic': i,
                  'theme': theme,
                },
              );
            },
          ),
        ),
      );
    }
    return result.reversed.toList();
  }
}
