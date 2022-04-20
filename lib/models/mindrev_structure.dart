import 'package:flutter/material.dart';

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

part 'mindrev_structure.g.dart';

@HiveType(typeId: 0)
class MindrevStructure {
  @HiveField(0)
  List<MindrevClass> classes = []; //classes that the structure contains

  MindrevStructure(); //constructor

  void addClass(MindrevClass newClass) {
    //add a new class
    classes.add(newClass);
  }

  void removeClass(MindrevClass newClass) {
    //remove a class
    classes.remove(newClass);
  }

  void renameClass(MindrevClass oldClass, String newName) {
    //update a class
    classes.remove(oldClass);
    oldClass.name = newName;
    classes.add(oldClass);

    //also rename material data
  }

  //update theme for uiColors
  MindrevTheme updateTheme(bool? uiColors, String color) {
    //hacky way to clone on object, dart devs pls make a clone method
    final MindrevTheme modTheme = MindrevTheme.clone(theme);
    if (uiColors == true) {
      modTheme.accent = HexColor(color);
      modTheme.accentText = textColor(HexColor(color));
    }
    return modTheme;
  }

  //wrap list of classes in ListTiles
  List<Widget> displayClasses(var context, MindrevStructure structure, bool? uiColors) {
    List<Widget> result = [];
    for (MindrevClass i in classes) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(i.name, style: defaultPrimaryTextStyle()),
            leading: CircleColor(color: HexColor(i.color), circleSize: 30),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/topics',
                arguments: {
                  'structure': structure,
                  'class': i,
                  'theme': updateTheme(uiColors, i.color), //update theme if uiColors true
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
