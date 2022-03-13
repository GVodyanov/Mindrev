import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hive_flutter/hive_flutter.dart';

class Topics extends StatefulWidget {
  const Topics({Key? key}) : super(key: key);

  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('topics');
  Map routeData = {};

  //this is a function which retrieves all saved topics and their properties
  Future<List> getTopics(String className) async {
    var box = Hive.lazyBox('mindrev');
    List classes = await box.get('classes');
    //check which class in the list of classes has the name that we want, and return its topics property
    return await classes.firstWhere((element) => element.name == className).topics;
  }

  //function to display topics when getTopics() retrieves them
  List<Widget> displayTopics(List gotTopics, Color accentColor, Color secondaryColor, String className) {
    List<Widget> result = [];
    for (var i in gotTopics) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(i.name, style: defaultPrimaryTextStyle),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/materials',
                arguments: {
                  'className': className,
                  'selection': i.name,
                  'accentColor': accentColor,
                  'secondaryColor': secondaryColor,
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
    //route data to get class information
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;

    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastAccentColor = routeData['accentColor'] == theme.accent ? theme.accentText : textColor(routeData['accentColor']);
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary ? theme.secondaryText : textColor(routeData['secondaryColor']);

    //futures that will be awaited by FutureBuilder that need to be in build
    Future futureTopics = getTopics(routeData['selection']);
    return FutureBuilder(
      future: Future.wait([
        futureText,
        futureTopics,
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          List topics = snapshot.data![1] ?? List.empty();

          return Scaffold(
            backgroundColor: theme.primary,
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(routeData['selection']),
              elevation: 10,
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
                Navigator.pushNamed(context, '/newTopic', arguments: routeData);
              },
            ),
            //body with everything
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //check if there are any topics, and if there are display them
                  if (topics.isNotEmpty)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: [
                              for (Widget i in displayTopics(topics, routeData['accentColor'], routeData['secondaryColor'], routeData['selection'])) i
                            ],
                          ).toList(),
                        ),
                      ),
                    ),

                  //if there are no classes prompt user to create some
                  if (topics.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                        child: ConstrainedBox(
                          child: Material(
                            color: theme.primary,
                            elevation: 8,
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
            //loading screen to be shown until Future is found
            body: loading,
          );
        }
      },
    );
  }
}
