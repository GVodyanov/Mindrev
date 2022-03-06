import 'package:flutter/material.dart';

import 'package:mindrev/services/db.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hexcolor/hexcolor.dart';

class Topics extends StatefulWidget {
  const Topics({Key? key}) : super(key: key);

  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  ///TODO change class data
  ///TODO new topic
  Future text = readText('topics');
  Map routeData = {};

  //this is a function which retrieves all saved topics and their properties
  Future<List> getTopics(String className) async {
    List result = [];
    try {
      result = await local.read('topics', className);
    } catch (e) {
      // print (e);
    }
    return result;
  }

  //function to display topics when getTopics() retrieves them
  List<Widget> displayTopics(List gotTopics, String color, String className) {
    List<Widget> result = [];
    for (var i in gotTopics) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(i['name']),
            trailing: Icon(Icons.keyboard_arrow_right, color: theme.primaryText),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/materials',
                arguments: {
                  'className': className,
                  'selection': i['name'],
                  'color': color
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
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;
    Future topics = getTopics(routeData['selection']);
    Color contrastColor = textColor(routeData['color']);
    return FutureBuilder(
      future: Future.wait([
        text,
        topics
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) => snapshot.hasData
          ? Scaffold(
              appBar: AppBar(
                foregroundColor: contrastColor,
                title: Text(routeData['selection']),
                elevation: 10,
                centerTitle: true,
                backgroundColor: HexColor(routeData['color']),
              ),

              //add new topic
              floatingActionButton: FloatingActionButton.extended(
                foregroundColor: contrastColor,
                icon: const Icon(
                  Icons.add,
                ),
                label: Text(
                  snapshot.data![0]['new'],
                ),
                backgroundColor: HexColor(routeData['color']),
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
                    if (snapshot.data[1].toString() != List.empty().toString())
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: ListTile.divideTiles(
                              context: context,
                              tiles: [
                                for (Widget i in displayTopics(snapshot.data![1], routeData['color'], routeData['selection'])) i
                              ],
                            ).toList(),
                          ),
                        ),
                      ),
                    //if there are no classes prompt user to create some
                    if (snapshot.data[1].toString() == List.empty().toString())
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
                      ),
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
