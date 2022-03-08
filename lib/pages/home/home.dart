import 'package:flutter/material.dart';

import 'package:mindrev/models/db.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:sembast/utils/value_utils.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //this is a function which retrieves all saved classes and their properties
  Future<List> getClasses() async {
    List result = [];
    try {
      var classList = await local.read('classes', null);
      Map properties = {};
      for (var i in classList) {
        properties = cloneMap(await local.read('properties', i));
        properties['name'] = i;
        result.add(properties);
      }
    } catch (e) {
      // print (e);
    }
    return result;
  }

  //function to display classes when getClasses() retrieves them
  List<Widget> displayClasses(List gotClasses) {
    List<Widget> result = [];
    for (var i in gotClasses) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(i['name'], style: defaultPrimaryTextStyle),
            leading: CircleColor(color: HexColor(i['color']), circleSize: 30),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/topics',
                arguments: {
                  'selection': i['name'],
                  'color': i['color']
                },
              );
            },
          ),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    //futures that will be awaited by FutureBuilder
    Future<List?> classes = getClasses();
    List<Future>? text = [
      readText('home'),
      readText('sidebar')
    ];

    return FutureBuilder(
      future: Future.wait([
        text[0],
        text[1],
        classes
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) => snapshot.hasData
          ? Scaffold(
              backgroundColor: theme.primary,

              //appbar
              appBar: AppBar(
                title: Text('Mindrev', style: TextStyle(color: theme.accent, fontFamily: 'Comfortaa-Bold', fontWeight: FontWeight.bold)),
                elevation: 10,
                centerTitle: true,
                backgroundColor: theme.secondary,
              ),

              //add new class
              floatingActionButton: FloatingActionButton.extended(
                icon: Icon(
                  Icons.add,
                  color: theme.accentText,
                ),
                label: Text(
                  snapshot.data![0]['new'],
                  style: TextStyle(color: theme.accentText, fontSize: 14),
                ),
                backgroundColor: theme.accent,
                onPressed: () {
                  Navigator.pushNamed(context, '/newClass');
                },
              ),

              //drawer with navigation menu
              drawer: Drawer(
                backgroundColor: theme.secondary,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      title: Text(snapshot.data![1]['home'], style: defaultSecondaryTextStyle),
                      leading: Icon(Icons.home, color: theme.secondaryText),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text(snapshot.data![1]['settings'], style: defaultSecondaryTextStyle),
                      leading: Icon(Icons.settings, color: theme.secondaryText),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text(snapshot.data![1]['help'], style: defaultSecondaryTextStyle),
                      leading: Icon(Icons.help, color: theme.secondaryText),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text(snapshot.data![1]['about'], style: defaultSecondaryTextStyle),
                      leading: Icon(Icons.info, color: theme.secondaryText),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              //body with everything
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //check if there are any classes, and if there are display them
                    if (snapshot.data[2].toString() != List.empty().toString())
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: ListTile.divideTiles(
                              context: context,
                              tiles: [
                                for (Widget i in displayClasses(snapshot.data[2])) i
                              ],
                            ).toList(),
                          ),
                        ),
                      ),
                    //if there are no classes prompt user to create some
                    if (snapshot.data[2].toString() == List.empty().toString())
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                          child: ConstrainedBox(
                            child: Material(
                              elevation: 8,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(snapshot.data![0]['create'], style: TextStyle(fontSize: 20, color: theme.primaryText)),
                              ),
                            ),
                            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            )
          : Scaffold(
              //loading screen to be shown until Future is found
              body: loading,
            ),
    );
  }
}
