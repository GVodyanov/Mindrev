import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/models/mindrev_material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ClassExtra extends StatefulWidget {
  const ClassExtra({Key? key}) : super(key: key);

  @override
  State<ClassExtra> createState() => _ClassExtraState();
}

class _ClassExtraState extends State<ClassExtra> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('classExtra');
  Map routeData = {};

  //hive box
  var box = Hive.lazyBox('mindrev');

  //simple function to get class details
  Future<MindrevClass?>? getClass(String className) async {
    //first we need to get the list of all classes
    List classes = await box.get('classes');

    //then we return the one with the right name
    if (classes.isNotEmpty) {
      try {
        return classes.firstWhere((element) => element.name == className);
      } catch (e, s) {
        s;
        //happens on renaming
      }
    }
    return MindrevClass('', '');
  }

  //remove data from under the class
  Future<bool> removeMaterialData(String className, List topics) async {
    List toDelete = [];

    for (MindrevTopic i in topics) {
      for (MindrevMaterial j in i.materials) {
        toDelete.add(
          className + '/' + i.name + '/' + j.name,
        );
      }
    }

    for (String path in toDelete) {
      await box.delete(path);
    }
    return true;
  }

  //rename data paths from under the class
  Future<bool> renameMaterialData(String className, String newName, List topics) async {
    List toRename = [];
    List toDelete = [];

    for (MindrevTopic i in topics) {
      for (MindrevMaterial j in i.materials) {
        toRename.add(
          '/' + i.name + '/' + j.name,
        );
        toDelete.add(
          className + '/' + i.name + '/' + j.name,
        );
      }
    }

    for (String path in toRename) {
      await box.put(newName + path, await box.get(className + path));
    }
    for (String path in toDelete) {
      await box.delete(path);
    }
    return true;
  }

  String? newName;
  MindrevClass? gotClass;

  @override
  Widget build(BuildContext context) {
    //route data to get class information
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
        getClass(routeData['className'])!,
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          gotClass ??= snapshot.data![1];

          //how we format our date
          DateFormat dateFormat = DateFormat('H:m\nE d/M/y');

          return Scaffold(
            backgroundColor: theme.primary,
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(routeData['className']),
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
                            dateFormat.format(DateTime.parse(gotClass!.date)),
                            style: defaultPrimaryTextStyle(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        //rename class
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
                                initialValue: routeData['className'],
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
                                  //retrieve list of classes, modify the name of the class in
                                  //question, put it back into hive
                                  List classes = await box.get('classes');
                                  await renameMaterialData(
                                    routeData['className'],
                                    newName!,
                                    classes
                                        .firstWhere(
                                          (element) => element.name == routeData['className'],
                                        )
                                        .topics,
                                  );
                                  int index = classes.indexWhere(
                                    (element) => element.name == routeData['className'],
                                  );
                                  gotClass!.name = newName ?? gotClass!.name;
                                  classes[index] = gotClass;
                                  //move back to home page
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (Route<dynamic> route) => false,
                                  );
                                  await box.put('classes', classes);
                                  //update again
                                  Navigator.pushReplacementNamed(context, '/home');
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
                        //delete class
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
                              title: text['sure'] + ' ' + routeData['className'],
                              buttons: [
                                coloredDialogButton(
                                  text['confirm'],
                                  context,
                                  () async {
                                    //remove where name is the one selected
                                    List classes = await box.get('classes');
                                    await removeMaterialData(
                                      routeData['className'],
                                      classes
                                          .firstWhere(
                                            (element) =>
                                                element.name == routeData['className'],
                                          )
                                          .topics,
                                    );

                                    classes.removeWhere(
                                      (element) => element.name == routeData['className'],
                                    );
                                    //go back to home page
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/home',
                                      (Route<dynamic> route) => false,
                                    );
                                    await box.put('classes', classes);
                                    //update again
                                    Navigator.pushReplacementNamed(context, '/home');
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
