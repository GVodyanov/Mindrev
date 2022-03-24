import 'package:flutter/material.dart';
import 'package:mindrev/models/mindrev_topic.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/extra/theme.dart';

import 'package:hive_flutter/hive_flutter.dart';

class NewTopic extends StatefulWidget {
  const NewTopic({Key? key}) : super(key: key);

  @override
  State<NewTopic> createState() => _NewTopicState();
}

class _NewTopicState extends State<NewTopic> {
  //futures that will be awaited by FutureBuilder
  Map routeData = {};
  Future futureText = readText('newTopic');

  //variables for form
  final _formKey = GlobalKey<FormState>();
  String? newTopicName;

  //function to create a new topic
  Future<bool> newTopic(String name, String className) async {
    var box = Hive.lazyBox('mindrev');

    //retrieve topics in right class
    List classes = await box.get('classes');
    List topics = await classes.firstWhere((element) => element.name == className).topics;

    //check if the topic already exists
    for (MindrevTopic i in topics) {
      if (i.name == name) return false;
    }

    //write the information
    MindrevTopic newTopic = MindrevTopic(name);
    topics.add(newTopic);
    classes[classes.indexWhere((element) => element.name == className)].topics = topics;
    await box.put('classes', classes);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //route data to get class information
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;

    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastAccentColor = routeData['accentColor'] == theme.accent ? theme.accentText : textColor(routeData['accentColor']);
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary ? theme.secondaryText : textColor(routeData['secondaryColor']);

    return FutureBuilder(
      future: futureText,
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data;

          return Scaffold(
            backgroundColor: theme.primary,
            //appbar
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(text['title']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
            ),

            //body with everything else
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                cursorColor: routeData['accentColor'],
                                style: defaultPrimaryTextStyle(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return text['errorNoText'];
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    newTopicName = value;
                                  });
                                },
                                decoration: defaultPrimaryInputDecoration(text['label']),
                              ),
                              const SizedBox(height: 30),
                              coloredButton(
                                text['submit'],
                                (() async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState?.save();
                                    if (newTopicName != null) {
                                      await newTopic('$newTopicName', routeData['topicName']);
                                      Navigator.pop(context);
                                      Navigator.pushReplacementNamed(context, '/topics', arguments: routeData);
                                    }
                                  }
                                }),
                                routeData['accentColor'],
                                contrastAccentColor ?? Colors.white,
                              )
                            ],
                          ),
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
