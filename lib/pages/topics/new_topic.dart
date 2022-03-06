import 'package:flutter/material.dart';

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:sembast/utils/value_utils.dart';

class NewTopic extends StatefulWidget {
  const NewTopic({Key? key}) : super(key: key);

  @override
  State<NewTopic> createState() => _NewTopicState();
}

class _NewTopicState extends State<NewTopic> {
  Map routeData = {};
  Future text = readText('newTopic');
  final _formKey = GlobalKey<FormState>();

  String? newTopicName;

  //function to create a new topic
  Future<bool> newTopic(String name, String className) async {
    dynamic existingImmutable = await local.read('topics', className);
    List? existing = existingImmutable != null ? cloneValue(existingImmutable) as List : null;
    if (existingImmutable != null) {
      for (Map i in existingImmutable) {
        if (i['name'] == name) return false;
      }
    }

    List newList;
    if (existing == null) {
      newList = [
        {
          'name': name,
          'date': DateTime.now().toIso8601String()
        }
      ];
      await local.write(newList, 'topics', className);
    } else {
      existing.add({
        'name': name,
        'date': DateTime.now().toIso8601String()
      });
      newList = existing;
      await local.update(newList, 'topics', className);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;
    Color contrastColor = textColor(routeData['color']);
    return FutureBuilder(
        future: text,
        builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) => snapshot.hasData
            ? Scaffold(
                appBar: AppBar(
                  foregroundColor: contrastColor,
                  title: Text(snapshot.data!['title']),
                  elevation: 10,
                  centerTitle: true,
                  backgroundColor: HexColor(routeData['color']),
                ),
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
                                        child: Column(children: <Widget>[
                                          TextFormField(
                                            cursorColor: HexColor(routeData['color']),
                                            style: defaultPrimaryTextStyle,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return snapshot.data!['errorNoText'];
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              setState(() {
                                                newTopicName = value;
                                              });
                                            },
                                            decoration: defaultPrimaryInputDecoration(snapshot.data!['label']),
                                          ),
                                          const SizedBox(height: 30),
                                          coloredButton(snapshot.data!['submit'], (() async {
                                            if (_formKey.currentState!.validate()) {
                                              _formKey.currentState?.save();
                                              if (newTopicName != null) {
                                                await newTopic('$newTopicName', routeData['selection']);
                                                Navigator.pop(context);
                                                Navigator.pushReplacementNamed(context, '/topics', arguments: routeData);
                                              }
                                            }
                                          }), HexColor(routeData['color']), contrastColor)
                                        ]))
                                  ],
                                ))))))
            : Scaffold(
                //loading screen to be shown until Future is found
                body: loading));
  }
}
