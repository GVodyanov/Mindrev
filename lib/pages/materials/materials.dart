import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:toml/toml.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Materials extends StatefulWidget {
  const Materials({Key? key}) : super(key: key);

  @override
  _MaterialsState createState() => _MaterialsState();
}

class _MaterialsState extends State<Materials> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('materials');
  Map routeData = {};
  Future futureTypeIcons = rootBundle.loadString('assets/materials.toml');

  //function which retrieves all materials and their properties
  Future<List> getMaterials(String topicName, String className) async {
    var box = Hive.lazyBox('mindrev');
    List classes = await box.get('classes');
    List topics = classes.firstWhere((element) => element.name == className).topics;
    return topics.firstWhere((element) => element.name == topicName).materials;
  }

  //function to display materials when getMaterials() retrieves them
  List<Widget> displayMaterials(List gotMaterials, String gotIcons, Color accentColor, Map routeData) {
    List<Widget> result = [];
    Map icons = TomlDocument.parse(gotIcons).toMap();

    //loop to add all materials to a list
    for (var i in gotMaterials) {
      //check what type corresponds to what icon
      String? icon;
      for (Map j in icons['materials']) {
        if (i.type == j['name']) icon = j['icon'];
      }
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: SvgPicture.asset(
              'assets/study_material_icons/$icon.svg',
              color: accentColor,
            ),
            title: Text(i.name, style: defaultPrimaryTextStyle()),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              routeData['name'] = i.name;
							Navigator.pushNamed(context, '/$icon', arguments: routeData);
            },
          ),
        ),
      );
    }
    return result.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    //route data to get class information
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;

    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastAccentColor = routeData['accentColor'] == theme.accent ? theme.accentText : textColor(routeData['accentColor']);
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary ? theme.secondaryText : textColor(routeData['secondaryColor']);

    //futures that will be awaited by FutureBuilder that need to be in build
    Future futureMaterials = getMaterials(routeData['topicName'], routeData['className']);
    return FutureBuilder(
      future: Future.wait([
        futureText,
        futureMaterials,
        futureTypeIcons,
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          List materials = snapshot.data![1] ?? List.empty();
          var typeIcons = snapshot.data![2];

          return Scaffold(
            backgroundColor: theme.primary,
            //appbar
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(routeData['topicName']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
            ),

            //add new topic
            floatingActionButton: FloatingActionButton.extended(
              foregroundColor: contrastAccentColor,
              icon: const Icon(
                Icons.add,
              ),
              label: Text(
                text['new'],
              ),
              backgroundColor: routeData['accentColor'],
              onPressed: () {
                Navigator.pushNamed(context, '/newMaterial', arguments: routeData);
              },
            ),

            //body with everything
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //check if there are any topics, and if there are display them
                  if (materials.isNotEmpty)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: [
                              for (Widget i in displayMaterials(materials, typeIcons, routeData['accentColor'], routeData)) i
                            ],
                          ).toList(),
                        ),
                      ),
                    ),
                  //if there are no classes prompt user to create some
                  if (materials.isEmpty)
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
                              child: Text(text['create'], style: TextStyle(fontSize: 20, color: theme.primaryText)),
                            ),
                          ),
                          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
                        ),
                      ),
                    ),
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
