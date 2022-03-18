import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:toml/toml.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MindrevTheme {
  Color? primary;
  Color? primaryText;
  Color? secondary;
  Color? secondaryText;
  Color? accent;
  Color? accentText;

  MindrevTheme(this.primary, this.primaryText, this.secondary, this.secondaryText, this.accent, this.accentText);
}

dynamic theme;

//function to get themes from theme file and return the theme set in settings
Future<bool> getTheme() async {
  //load and parse theme file
  dynamic themesMap = await rootBundle.loadString('assets/themes.toml');
  themesMap = TomlDocument.parse(themesMap).toMap();

  //get theme set in settings from hive
  var box = Hive.lazyBox('mindrev');
  var settings = await box.get('settings');

  //find the actual theme colors for the selected theme
  //convert map to list for easier cycling
  List themesList = [];
  themesMap['themes'].forEach((k, v) => themesList.add(v));

  try {
    for (int i = themesList.length - 1; i >= 0; i--) {
      if (themesList[i]!['name'] == settings!['theme']) {
        theme = MindrevTheme(
          HexColor(themesList[i]['primary']),
          HexColor(themesList[i]['primaryText']),
          HexColor(themesList[i]['secondary']),
          HexColor(themesList[i]['secondaryText']),
          HexColor(themesList[i]['accent']),
          HexColor(themesList[i]['accentText']),
        );
      }
    }
  } catch (e) {
    //if nothing is found just return default
    theme = MindrevTheme(
      HexColor(themesList[0]['primary']),
      HexColor(themesList[0]['primaryText']),
      HexColor(themesList[0]['secondary']),
      HexColor(themesList[0]['secondaryText']),
      HexColor(themesList[0]['accent']),
      HexColor(themesList[0]['accentText']),
    );

  }

  return true;
}
