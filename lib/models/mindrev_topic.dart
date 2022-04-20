import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:mindrev/models/mindrev_material.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hive_flutter/hive_flutter.dart';

part 'mindrev_topic.g.dart';

@HiveType(typeId: 2)
class MindrevTopic {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  String date = DateTime.now().toIso8601String();

  @HiveField(2)
  List<MindrevMaterial> materials = [];

  MindrevTopic(this.name);

  List<Widget> displayMaterials(
    var context,
    MindrevTopic topic,
    var mClass,
    var structure,
    var theme,
    Map icons,
  ) {
    List<Widget> result = [];
    //loop to add all materials to a list
    for (var i in topic.materials) {
      //check what type corresponds to what icon
      String? icon;
      for (Map j in icons['materials']) {
        if (i.type == j['name']) icon = j['icon'];
      }
      icon ??= 'flashcards'; //in case flashcard null when renaming
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: SvgPicture.asset(
              'assets/study_material_icons/$icon.svg',
              color: theme.accent,
            ),
            title: Text(i.name, style: defaultPrimaryTextStyle()),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/$icon',
                arguments: {
                  'structure': structure,
                  'class': mClass,
                  'topic': topic,
                  'material': i,
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
