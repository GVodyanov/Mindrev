import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/models/mindrev_material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TopicExtra extends StatefulWidget {
  const TopicExtra({Key? key}) : super(key: key);

  @override
  State<TopicExtra> createState() => _TopicExtraState();
}

class _TopicExtraState extends State<TopicExtra> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('topicExtra');
  Map routeData = {};

  //hive box
  var box = Hive.lazyBox('mindrev');

  //simple function to get topic details
  Future<MindrevTopic?>? getTopic(String className, String topicName) async {
    //first we need to get the list of all classes
    List classes = await box.get('classes');

    //then we return the one with the right name
    if (classes.isNotEmpty) {
      try {
        List topics = classes.firstWhere((element) => element.name == className).topics;
        return topics.firstWhere((element) => element.name == topicName);
      } catch (e, s) {
        s;
        //happens on renaming
      }
    }
    return MindrevTopic('');
  }

  //remove data from under the class
  Future<bool> removeMaterialData(String className, String topicName, List materials) async {
    List toDelete = [];

    for (MindrevMaterial i in materials) {
      toDelete.add(
        className + '/' + topicName + '/' + i.name,
      );
    }

    for (String path in toDelete) {
      await box.delete(path);
    }
    return true;
  }

  //rename data paths from under the class
  Future<bool> renameMaterialData(
    String className,
    String topicName,
    String newName,
    List materials,
  ) async {
    List toRename = [];
    List toDelete = [];

    for (MindrevMaterial i in materials) {
      toRename.add(
        '/' + i.name,
      );
      toDelete.add(
        className + '/' + topicName + '/' + i.name,
      );
    }

    for (String path in toRename) {
      await box.put(
        className + '/' + newName + path,
        await box.get(className + '/' + topicName + path),
      );
    }
    for (String path in toDelete) {
      await box.delete(path);
    }
    return true;
  }

  String? newName;
  MindrevTopic? gotTopic;

  @override
  Widget build(BuildContext context) {
    //route data to get class and topic information
    routeData =
        routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;

    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastAccentColor = routeData['accentColor'] == theme.accent
        ? theme.accentText
        : textColor(routeData['accentColor']);
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary
        ? theme.secondaryText
        : textColor(routeData['secondaryColor']);

    return FutureBuilder(
      future: Future.wait([
        futureText,
        getTopic(routeData['className'], routeData['topicName'])!,
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          gotTopic ??= snapshot.data![1];

          //how we format our date
          DateFormat dateFormat = DateFormat('H:m\nE d/M/y');

          return Scaffold(
            backgroundColor: theme.primary,
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(routeData['topicName']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //date created
                        ListTile(
                          textColor: theme.primaryText,
                          leading: Icon(Icons.calendar_today, color: routeData['accentColor']),
                          title: Text(text['creationDate'], style: defaultPrimaryTextStyle()),
                          trailing: Text(
                            dateFormat.format(DateTime.parse(gotTopic!.date)),
                            style: defaultPrimaryTextStyle(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        //rename topic
                        Text(
                          text['rename'],
                          style: TextStyle(
                            color: theme.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: routeData['topicName'],
                                cursorColor: routeData['accentColor'],
                                style: defaultSecondaryTextStyle(),
                                decoration: defaultSecondaryInputDecoration(
                                  text['newName'],
                                ),
                                onChanged: (String? value) {
                                  setState(() {
                                    newName = value;
                                  });
                                },
                              ),
                            ),
                            //note to self maybe remove old flip cards from list
                            IconButton(
                              onPressed: () async {
                                if (newName != null || newName != '') {
                                  //retrieve list of topics, modify the name of the topic in
                                  //question, put it back into hive
                                  List classes = await box.get('classes');
                                  await renameMaterialData(
                                    routeData['className'],
                                    routeData['topicName'],
                                    newName!,
                                    classes
                                        .firstWhere(
                                          (element) => element.name == routeData['className'],
                                        )
                                        .topics
                                        .firstWhere(
                                          (element) => element.name == routeData['topicName'],
                                        )
                                        .materials,
                                  );
                                  //find index of the topic to be changed
                                  int index = classes
                                      .firstWhere(
                                        (element) => element.name == routeData['className'],
                                      )
                                      .topics
                                      .indexWhere(
                                        (element) => element.name == routeData['topicName'],
                                      );
                                  //update topic object
                                  print(gotTopic!.materials);
                                  gotTopic!.name = newName ?? gotTopic!.name;
                                  //place topic object back into right indexes
                                  classes
                                      .firstWhere(
                                        (element) => element.name == routeData['className'],
                                      )
                                      .topics[index] = gotTopic;

                                  print(gotTopic!.materials);
                                  //move back to topics page
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  await box.put('classes', classes);
                                  //update again
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/topics',
                                    arguments: routeData,
                                  );
                                } else {
                                  SnackBar errorNoText = SnackBar(
                                    content: Text(
                                      text['errorNoText'],
                                      style: defaultSecondaryTextStyle(),
                                    ),
                                    backgroundColor: theme.secondary,
                                    elevation: 20,
                                    duration: const Duration(milliseconds: 1500),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(errorNoText);
                                }
                              },
                              icon: Icon(Icons.check, color: theme.secondaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        //delete topic
                        Row(
                          children: [
                            Text(
                              text['delete'],
                              style: TextStyle(
                                color: theme.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.warning, color: theme.primaryText),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        coloredButton(
                          text['delete'],
                          () {
                            Alert(
                              context: context,
                              style: defaultAlertStyle(),
                              title: text['sure'] + ' ' + routeData['topicName'],
                              buttons: [
                                coloredDialogButton(
                                  text['confirm'],
                                  context,
                                  () async {
                                    //remove where name is the one selected
                                    List classes = await box.get('classes');
                                    removeMaterialData(
                                      routeData['className'],
                                      routeData['topicName'],
                                      classes
                                          .firstWhere(
                                            (element) =>
                                                element.name == routeData['className'],
                                          )
                                          .topics
                                          .firstWhere(
                                            (element) =>
                                                element.name == routeData['topicName'],
                                          )
                                          .materials,
                                    );
                                    classes
                                        .firstWhere(
                                          (element) => element.name == routeData['className'],
                                        )
                                        .topics
                                        .removeWhere(
                                          (element) => element.name == routeData['topicName'],
                                        );
                                    //go back to home page
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    await box.put('classes', classes);
                                    //update again
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/topics',
                                      arguments: routeData,
                                    );
                                  },
                                  routeData['accentColor'],
                                  contrastAccentColor!,
                                ),
                                coloredDialogButton(
                                  text['cancel'],
                                  context,
                                  () => Navigator.pop(context),
                                  routeData['accentColor'],
                                  contrastAccentColor,
                                )
                              ],
                            ).show();
                          },
                          routeData['accentColor'],
                          contrastAccentColor!,
                        )
                      ],
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
