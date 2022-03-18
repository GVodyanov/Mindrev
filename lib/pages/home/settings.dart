import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:toml/toml.dart';
import 'package:hexcolor/hexcolor.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var box = Hive.lazyBox('mindrev');
  var settings = {};
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('settings');
  Future futureThemes = rootBundle.loadString('assets/themes.toml');

  //variables for form
  //final _formKey = GlobalKey<FormState>();
  bool uiColors = true;
  int? selectedTheme;
  String? selectedThemeName;
  String currentTheme = 'default';

  //function to get old settings
  Future getSettings() async {
    try {
      settings = await box.get('settings');
    } catch (e) {
      //no settings set yet
    }

    //update pre set form vars
    try {
      uiColors = settings['uiColors'];
    } catch (e) {
      uiColors = true;
    }

    settings['theme'] ??= 0;
  }

  //function to load themes from theme file
  void getThemes() async {
    dynamic themes = await rootBundle.loadString('assets/themes.toml');
    themes = TomlDocument.parse(themes).toMap();
  }

  //function to display themes from getThemes
  List<Widget> displayThemes(String rawTOML) {
    Map themesMap = TomlDocument.parse(rawTOML).toMap();
    //convert map to list for easier cycling
    List themesList = [];
    themesMap['themes'].forEach((k, v) => themesList.add(v));
    List<Widget> result = [];
    for (int i = themesList.length - 1; i >= 0; i--) {
      //pre select set theme
      if (settings['theme'] == themesList[i]['name'] && selectedTheme == null) selectedTheme = i;
      if (selectedTheme == i) currentTheme = themesList[i]['name'];
      result.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: selectedTheme == i ? theme.accent : theme.primary,
              elevation: 8,
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
                    constraints: const BoxConstraints(maxWidth: 80, minWidth: 50, maxHeight: 80),
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
                Text(themesList[i]['name'], style: TextStyle(color: selectedTheme == i ? theme.accentText : theme.primaryText))
              ],
            ),
            onPressed: () {
              //logic for changing selected theme
              setState(() {
                selectedTheme = i;
                selectedThemeName = themesList[i]['name'];
              });
            },
          ),
        ),
      );
    }
    return result.reversed.toList();
  }

  //function to save settings
  Future<bool> saveSettings() async {
    await box.put('settings', {
      'uiColors': uiColors,
      'theme': selectedThemeName,
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        futureText,
        futureThemes,
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          String themes = snapshot.data![1];

          return Scaffold(
            backgroundColor: theme.primary,

            //appbar
            appBar: AppBar(
              foregroundColor: theme.secondaryText,
              title: Text(text['title']),
              centerTitle: true,
              elevation: 10,
              backgroundColor: theme.secondary,
            ),

            //button to save
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(
                Icons.check,
              ),
              label: Text(
                text['apply'],
              ),
              foregroundColor: theme.accentText,
              backgroundColor: theme.accent,
              onPressed: () async {
                await saveSettings();
                await getTheme();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),

            //body with everything
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text['ui'],
                            style: TextStyle(color: theme.primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text(text['uiColors'], style: defaultPrimaryTextStyle()),
                            leading: Icon(Icons.palette, color: theme.accent),
                            trailing: Switch(
                              value: uiColors,
                              onChanged: (bool value) {
                                setState(() {
                                  uiColors = value;
                                });
                              },
                              activeColor: theme.accent,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            text['theme'],
                            style: TextStyle(color: theme.primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.brush, color: theme.accent),
                                const SizedBox(width: 25),
                                Expanded(
                                  child: Material(
                                    color: theme.primary,
                                    elevation: 8,
                                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        direction: Axis.horizontal,
                                        children: [
                                          for (Widget i in displayThemes(themes)) i
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            //loading() screen to be shown until Future is found
            body: loading(),
          );
        }
      },
    );
  }
}
