import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/db.dart';

import 'package:toml/toml.dart';
import 'package:hexcolor/hexcolor.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // values determined in initState
  MindrevSettings? settings;
  Map? text;
  Map? themes;

  int? selectedTheme;
  String currentTheme = 'default';
  int showThemes = 2; //we don't want to show all themes at once

  //function to display themes from themes map
  List<Widget> displayThemes(Map? themes) {
    //convert map to list for easier cycling
    List themesList = [];
    themes?['themes'].forEach((k, v) => themesList.add(v));
    List<Widget> result = [];
    for (int i = themesList.length - 1; i >= 0; i--) {
      //pre select set theme
      if (settings!.theme == themesList[i]['name'] && selectedTheme == null) {
        selectedTheme = i;
      }
      if (selectedTheme == i) currentTheme = themesList[i]['name'];
      result.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: selectedTheme == i ? theme.accent : theme.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primary ?? Colors.white, width: 10),
                  ),
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxWidth: 80, minWidth: 50, maxHeight: 80),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: HexColor(themesList[i]['primary']),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: HexColor(themesList[i]['secondary']),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: HexColor(themesList[i]['accent']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  themesList[i]['name'],
                  style: TextStyle(
                    color: selectedTheme == i ? theme.accentText : theme.primaryText,
                  ),
                )
              ],
            ),
            onPressed: () {
              //logic for changing selected theme
              setState(() {
                selectedTheme = i;
                settings!.theme = themesList[i]['name'];
              });
            },
          ),
        ),
      );
    }
    return result.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    //wait for text and settings and then assign to respective variables
    Future.wait([
      readText('settings'),
      local.getSettings(),
      rootBundle.loadString('assets/themes.toml')
    ]).then((values) {
      setState(() {
        text = values[0] as Map;
        settings = values[1] as MindrevSettings;
        themes = TomlDocument.parse(values[2] as String).toMap();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (settings != null) {
      List<Widget> displayedThemes = displayThemes(themes);
      return Scaffold(
        backgroundColor: theme.primary,

        //appbar
        appBar: AppBar(
          foregroundColor: theme.secondaryText,
          title: Text(text?['title']),
          centerTitle: true,
          elevation: 4,
          backgroundColor: theme.secondary,
        ),

        //button to save
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(
            Icons.check,
          ),
          label: Text(
            text?['apply'],
          ),
          foregroundColor: theme.accentText,
          backgroundColor: theme.accent,
          onPressed: () async {
            await local.updateSettings(settings!);
            await getTheme();
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /* UI SECTION */

                  Text(
                    text?['ui'],
                    style: TextStyle(
                      color: theme.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(text?['uiColors'], style: defaultPrimaryTextStyle()),
                    leading: Icon(Icons.palette, color: theme.accent),
                    trailing: Switch(
                      value: settings!.uiColors,
                      onChanged: (bool value) {
                        setState(() {
                          settings!.uiColors = value;
                        });
                      },
                      activeColor: theme.accent,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    title: Text(text?['confetti'], style: defaultPrimaryTextStyle()),
                    leading: Icon(Icons.celebration, color: theme.accent),
                    trailing: Switch(
                      value: settings!.confetti,
                      onChanged: (bool value) {
                        setState(() {
                          settings!.confetti = value;
                        });
                      },
                      activeColor: theme.accent,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /* NOTES SECTION */

                  Text(
                    text?['notes'],
                    style: TextStyle(
                      color: theme.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(text?['editor'], style: defaultPrimaryTextStyle()),
                    leading: Icon(Icons.edit, color: theme.accent),
                    trailing: DropdownButton(
                      value: settings?.markdownEdit ?? false,
                      items: [
                        DropdownMenuItem(
                          child: Text(text?['editorZefyrka']),
                          value: false,
                        ),
                        DropdownMenuItem(
                          child: Text(text?['editorMarkdown']),
                          value: true,
                        ),
                      ],
                      onChanged: (bool? value) {
                        setState(() {
                          settings?.markdownEdit = value;
                        });
                      },
                      dropdownColor: theme.primary,
                      style: defaultPrimaryTextStyle(),
                      underline: Container(),
                      icon: Icon(Icons.arrow_drop_down, color: theme.accent),
                      focusColor: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /* THEME SECTION */

                  Text(
                    text?['theme'],
                    style: TextStyle(
                      color: theme.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 20,
                      children: [
                        Icon(Icons.brush, color: theme.accent),
                        const SizedBox(width: 25),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),

                          child: Material(
                            color: theme.primary,
                            elevation: 4,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                direction: Axis.horizontal,
                                children: [
                                  for (int i = 0; i <= showThemes; i++) displayedThemes[i]
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        defaultButton(
                          text?[showThemes == 2 ? 'moreThemes' : 'lessThemes'],
                              () {
                            setState(() {
                              if (showThemes == 2) {
                                showThemes = displayedThemes.length - 1;
                              } else {
                                showThemes = 2;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return loading();
    }
  }
}
