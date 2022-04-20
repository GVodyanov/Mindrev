import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:toml/toml.dart';

class Materials extends StatefulWidget {
  const Materials({Key? key}) : super(key: key);

  @override
  State<Materials> createState() => _MaterialsState();
}

class _MaterialsState extends State<Materials> {
  Map? text;
  Map? icons;

  @override
  void initState() {
    super.initState();
    Future.wait([
      readText('materials'),
      rootBundle.loadString('assets/materials.toml'),
    ]).then((List<dynamic> values) {
      setState(() {
        text = values[0] as Map;
        icons = TomlDocument.parse(values[1]).toMap();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //route data to get class and theme information
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    //calling it mClass as class is reserved
    var topic = routeData['topic'];
    var theme = routeData['theme'];

    if (text != null) {
      return Scaffold(
        backgroundColor: theme.primary,

        appBar: AppBar(
          foregroundColor: theme.secondaryText,
          title: Text(topic.name),
          elevation: 4,
          centerTitle: true,
          backgroundColor: theme.secondary,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                routeData['text'] = text?['topicExtra'];
                Navigator.pushNamed(context, '/topicExtra', arguments: routeData);
              },
            ),
          ],
        ),

        //add new topic
        floatingActionButton: FloatingActionButton.extended(
          foregroundColor: theme.accentText,
          icon: const Icon(
            Icons.add,
          ),
          label: Text(
            text?['new'],
          ),
          backgroundColor: theme.accent,
          onPressed: () {
            routeData['text'] = text?['newMaterial'];
            Navigator.pushNamed(context, '/newMaterial', arguments: routeData);
          },
        ),

        body: SingleChildScrollView(
          child: Center(
            //check if there are any materials, and if there are display them
            child: topic.materials.isNotEmpty
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          for (Widget i in topic.displayMaterials(
                            context,
                            topic,
                            routeData['class'],
                            routeData['structure'],
                            theme,
                            icons,
                          ))
                            i
                        ],
                      ).toList(),
                    ),
                  )
                : empty(text?['create']),
          ),
        ),
      );
    } else {
      return loading();
    }
  }
}
