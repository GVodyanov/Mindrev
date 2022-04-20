import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/services/db.dart';

import 'package:toml/toml.dart';
import 'package:hexcolor/hexcolor.dart';

class MindrevTheme {
  Color? primary;
  Color? primaryText;
  Color? secondary;
  Color? secondaryText;
  Color? accent;
  Color? accentText;

  MindrevTheme(
    this.primary,
    this.primaryText,
    this.secondary,
    this.secondaryText,
    this.accent,
    this.accentText,
  );

  //clone method to be able to modify for uiColors
  MindrevTheme.clone(MindrevTheme theme)
      : this(
          theme.primary,
          theme.primaryText,
          theme.secondary,
          theme.secondaryText,
          theme.accent,
          theme.accentText,
        );
}

dynamic theme;

//function to get themes from theme file and return the theme set in settings
Future<bool> getTheme() async {
  //load and parse theme file
  dynamic themesMap = await rootBundle.loadString('assets/themes.toml');
  themesMap = TomlDocument.parse(themesMap).toMap();
  //convert map to list for easier cycling
  List themesList = [];
  themesMap['themes'].forEach((k, v) => themesList.add(v));

  //get theme set in settings from hive
  MindrevSettings settings = await local.getSettings();

  //find the actual theme colors for the selected theme
  try {
    //cycle through themes until theme matches name in settings
    for (int i = themesList.length - 1; i >= 0; i--) {
      if (themesList[i]!['name'] == settings.theme) {
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
    // ignore: empty_catches
  } catch (e) {}

  return true;
}
