import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/pages/home/about.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //open box
  var box = Hive.lazyBox('mindrev');

  //futures that will be awaited by FutureBuilder
  List<Future>? futureText = [
    readText('home'),
    readText('sidebar'),
    readText('about'),
  ];

  //function which retrieves all saved classes and their properties
  Future getClasses() async {
    return box.get('classes');
  }

  //function to get settings
  Future getSettings() async {
    return await box.get('settings');
  }

  //function to display classes when getClasses() retrieves them
  List<Widget> displayClasses(List gotClasses, bool? uiColors) {
    List<Widget> result = [];
    for (var i in gotClasses) {
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
                  'topicName': i.name,
                  'accentColor': uiColors == false ? theme.accent : HexColor(i.color),
                  'secondaryColor': uiColors == false ? theme.secondary : HexColor(i.color)
                },
              );
            },
          ),
        ),
      );
    }
    return result.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        futureText![0],
        futureText![1],
        futureText![2],
        getClasses(),
        getSettings(),
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          Map sidebar = snapshot.data![1];
          Map about = snapshot.data![2];
          List classes = snapshot.data![3] ?? List.empty();
          Map settings = snapshot.data![4] ?? {};

          return Scaffold(
            backgroundColor: theme.primary,

            //appbar
            appBar: AppBar(
              foregroundColor: theme.secondaryText,
              title: Text(
                'Mindrev',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 24,
                ),
              ),
              elevation: 4,
              centerTitle: true,
              backgroundColor: theme.secondary,
            ),

            //button to add new class
            floatingActionButton: FloatingActionButton.extended(
              icon: Icon(
                Icons.add,
                color: theme.accentText,
              ),
              label: Text(
                text['new'],
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: theme.secondary,
                        ),
                        child: SvgPicture.asset('assets/logo.svg', color: theme.accent),
                      ),
                      ListTile(
                        title: Text(sidebar['home'], style: defaultSecondaryTextStyle()),
                        leading: Icon(Icons.home, color: theme.secondaryText),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(sidebar['settings'], style: defaultSecondaryTextStyle()),
                        leading: Icon(Icons.settings, color: theme.secondaryText),
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      ListTile(
                        title: Text(sidebar['help'], style: defaultSecondaryTextStyle()),
                        leading: Icon(Icons.help, color: theme.secondaryText),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(sidebar['about'], style: defaultSecondaryTextStyle()),
                        leading: Icon(Icons.info, color: theme.secondaryText),
                        onTap: () {
                          showAbout(about, context);
                        },
                      ),
                      const Divider(endIndent: 5, indent: 5),
                      ListTile(
                        leading: Icon(Icons.close, color: theme.secondaryText),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            //body with everything
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //check if there are any classes, and if there are display them
                  if (classes.isNotEmpty)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: [
                              for (Widget i in displayClasses(classes, settings['uiColors'])) i
                            ],
                          ).toList(),
                        ),
                      ),
                    ),
                  //if there are no classes prompt user to create some
                  if (classes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                        child: ConstrainedBox(
                          child: Material(
                            color: theme.primary,
                            elevation: 4,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                snapshot.data![0]['create'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: theme.primaryText,
                                ),
                              ),
                            ),
                          ),
                          constraints: const BoxConstraints(
                            maxWidth: 500,
                            maxHeight: 300,
                          ),
                        ),
                      ),
                    )
                ],
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
