import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/widgets/widgets.dart';

class Topics extends StatefulWidget {
  const Topics({Key? key}) : super(key: key);

  @override
  State<Topics> createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  Map? text;

  @override
  void initState() {
    super.initState();
    readText('topics').then((value) => setState(() => text = value));
  }

  @override
  Widget build(BuildContext context) {
    //route data to get class and theme information
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    //calling it mClass as class is reserved
    var mClass = routeData['class'];
    var theme = routeData['theme'];

    if (text != null) {
      return Scaffold(
        backgroundColor: theme.primary,

        appBar: AppBar(
          foregroundColor: theme.secondaryText,
          title: Text(mClass.name),
          elevation: 4,
          centerTitle: true,
          backgroundColor: theme.secondary,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                routeData['text'] = text?['classExtra'];
                Navigator.pushNamed(context, '/classExtra', arguments: routeData);
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
            routeData['text'] = text?['newTopic'];
            Navigator.pushNamed(context, '/newTopic', arguments: routeData);
          },
        ),
        //body with everything
        body: SingleChildScrollView(
          child: Center(
            //check if there are any topics, and if there are display them
            child: mClass.topics.isNotEmpty
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          for (Widget i in mClass.displayTopics(
                            context,
                            mClass,
                            routeData['structure'],
                            theme,
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
