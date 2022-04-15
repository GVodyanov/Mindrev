import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/models/mindrev_material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MaterialExtra extends StatefulWidget {
  const MaterialExtra({Key? key}) : super(key: key);

  @override
  State<MaterialExtra> createState() => _MaterialExtraState();
}

class _MaterialExtraState extends State<MaterialExtra> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('materialExtra');
  Map routeData = {};

  //hive box
  var box = Hive.lazyBox('mindrev');

  //simple function to get material details
  Future<MindrevMaterial?>? getMaterial(
    String className,
    String topicName,
    String name,
  ) async {
    //first we need to get the list of all classes
    List classes = await box.get('classes');

    //then we return the one with the right name
    if (classes.isNotEmpty) {
      try {
        List topics = classes.firstWhere((element) => element.name == className).topics;
        List materials = topics.firstWhere((element) => element.name == topicName).materials;
        return materials.firstWhere((element) => element.name == name);
      } catch (e, s) {
        s;
        //happens on renaming
      }
    }
    return MindrevMaterial('', '');
  }

  String? newName;
  MindrevMaterial? gotMaterial;

  @override
  Widget build(BuildContext context) {
    //route data to get class and material information
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
        getMaterial(routeData['className'], routeData['topicName'], routeData['name'])!,
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          gotMaterial ??= snapshot.data![1];

          //how we format our date
          DateFormat dateFormat = DateFormat('H:m\nE d/M/y');

          return Scaffold(
            backgroundColor: theme.primary,
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(routeData['name']),
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
                            dateFormat.format(DateTime.parse(gotMaterial!.date)),
                            style: defaultPrimaryTextStyle(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        //rename material
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
                                initialValue: routeData['name'],
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
                                  //find index of the topic to be changed
                                  int index = classes
                                      .firstWhere(
                                        (element) => element.name == routeData['className'],
                                      )
                                      .topics
                                      .firstWhere(
                                        (element) => element.name == routeData['topicName'],
                                      )
                                      .materials
                                      .indexWhere(
                                        (element) => element.name == routeData['name'],
                                      );
                                  //update topic object
                                  gotMaterial!.name = newName ?? gotMaterial!.name;
                                  //place topic object back into right indexes
                                  classes
                                      .firstWhere(
                                        (element) => element.name == routeData['className'],
                                      )
                                      .topics
                                      .firstWhere(
                                        (element) => element.name == routeData['topicName'],
                                      )
                                      .materials[index] = gotMaterial;

                                  //we also have to rename the material data
                                  var data = await box.get(
                                    routeData['className'] +
                                        '/' +
                                        routeData['topicName'] +
                                        '/' +
                                        routeData['name'],
                                  );
                                  await box.put(
                                    routeData['className'] +
                                        '/' +
                                        routeData['topicName'] +
                                        '/' +
                                        newName,
                                    data,
                                  );
                                  await box.delete(
                                    routeData['className'] +
                                        '/' +
                                        routeData['topicName'] +
                                        '/' +
                                        routeData['name'],
                                  );

                                  //move back to topics page
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  await box.put('classes', classes);
                                  //update again
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/materials',
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
                                    classes
                                        .firstWhere(
                                          (element) => element.name == routeData['className'],
                                        )
                                        .topics
                                        .firstWhere(
                                          (element) => element.name == routeData['topicName'],
                                        )
                                        .materials
                                        .removeWhere(
                                          (element) => element.name == routeData['name'],
                                        );
                                    //go back to home page
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    await box.put('classes', classes);
                                    //we also have to delete material data
                                    await box.delete(
                                      routeData['className'] +
                                          '/' +
                                          routeData['topicName'] +
                                          '/' +
                                          routeData['name'],
                                    );
                                    //update again
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/materials',
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
