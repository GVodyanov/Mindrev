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
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('settings');
  Future futureThemes = rootBundle.loadString('assets/themes.toml');

  //variables for form
  //final _formKey = GlobalKey<FormState>();
  bool uiColors = true;
  int? selectedTheme;
  String currentTheme = 'default';

  //function to get old settings
  void getSettings() async {
    var settings = await box.get('settings');

    //update pre set form vars
    try {
      uiColors = settings!['uiColors'];
    } catch (e) {
      uiColors = true;
    }

    try {
      selectedTheme = settings!['theme'];
    } catch (e) {
      selectedTheme = 0;
    }
  }

	//function to get themes from theme file
  List<Widget> displayThemes(rawTOML) {
    Map themesMap = TomlDocument.parse(rawTOML).toMap();
    //convert map to list for easier cycling
    List themesList = [];
    themesMap['themes'].forEach((k, v) => themesList.add(v));
    List<Widget> result = [];
    int j = themesList.length;
    for (int i = j - 1; i >= 0; i--) {
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
                    constraints: const BoxConstraints(maxWidth: 200, minWidth: 100, maxHeight: 200),
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
                const SizedBox(height: 20),
                Text(themesList[i]['name'], style: TextStyle(color: selectedTheme == i ? theme.accentText : theme.primaryText))
              ],
            ),
            onPressed: () {
              //logic for changing selected theme
              setState(() {
                selectedTheme = i;
              });
            },
          ),
        ),
      );
    }
    return result.reversed.toList();
  }

  void getThemes() async {
    dynamic themes = await rootBundle.loadString('assets/themes.toml');
    themes = TomlDocument.parse(themes).toMap();
    
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
                Icons.save,
              ),
              label: Text(
                text['save'],
              ),
              foregroundColor: theme.accentText,
              backgroundColor: theme.accent,
              onPressed: () async {
                await box.put('settings', {
                  'uiColors': uiColors
                });
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
                            title: Text(text['uiColors'], style: defaultPrimaryTextStyle),
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
                          Row (
                            children: [
                              const SizedBox(width: 15),
                            	Icon (Icons.brush, color: theme.accent),
                            	const SizedBox(width: 25),
                              Material(
                                color: theme.primary,
                                elevation: 8,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Wrap (
                                    children: [
                                      // for (Widget i in displayThemes(themes)) i
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
            //loading screen to be shown until Future is found
            body: loading,
          );
        }
      },
    );
  }
}