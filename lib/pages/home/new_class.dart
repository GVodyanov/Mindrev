import 'package:flutter/material.dart';

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:sembast/utils/value_utils.dart';

class NewClass extends StatefulWidget {
  const NewClass({Key? key}) : super(key: key);

  @override
  _NewClassState createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  final _formKey = GlobalKey<FormState>();

  Color? tempColor;
  Color mainColor = Colors.lightBlue;
  String? newClassName;

  //function for creating a dialog for the color picker
  void openDialog(Widget content, Map text) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.secondary,
          contentPadding: const EdgeInsets.all(8.0),
          title: Text(text['chooseColorDetails'], style: TextStyle(color: theme.secondaryText)),
          content: content,
          actions: [
            defaultButton(text['cancel'], Navigator.of(context).pop),
            defaultButton(text['submit'], () {
              Navigator.of(context).pop();
              setState(() {
                mainColor = tempColor!;
              });
            })
          ],
        );
      },
    );
  }

  //this is a function to obv create a new class
  Future<bool> newClass(String name, String color) async {
    dynamic existing = await local.read('classes', null);
    List newList = [];
    if (existing == null) {
      local.write(
        [
          name
        ],
        'classes',
        null,
      );
    } else {
      newList = cloneList(existing as List);
    }
    if (newList.contains(name) == false) {
      newList.add(name);
      local.update(newList, 'classes', null);
    }
    await local.write(
      {
        'color': color,
        'date': DateTime.now().toIso8601String()
      },
      'properties',
      name,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Future text = readText('newClass');
    return FutureBuilder(
      future: text,
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) => snapshot.hasData
          ? Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data!['title'], style: defaultSecondaryTextStyle),
                elevation: 10,
                centerTitle: true,
                backgroundColor: theme.secondary,
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  cursorColor: theme.accent,
                                  style: defaultPrimaryTextStyle,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return snapshot.data!['errorNoText'];
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    setState(() {
                                      newClassName = value;
                                    });
                                  },
                                  decoration: defaultPrimaryInputDecoration(snapshot.data!['label']),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  child: ListTile(
                                    trailing: defaultButton(
                                      snapshot.data!['chooseColor'],
                                      (() {
                                        openDialog(
                                          MaterialColorPicker(
                                            selectedColor: mainColor,
                                            onColorChange: (color) => setState(() {
                                              tempColor = color;
                                            }),
                                          ),
                                          snapshot.data,
                                        );
                                      }),
                                    ),
                                    leading: CircleColor(
                                      circleSize: 30,
                                      color: mainColor,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primaryText!),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                defaultButton(
                                  snapshot.data!['submit'],
                                  (() async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState?.save();
                                      if (newClassName != null) {
                                        String mainColorString = mainColor.toString();
                                        const start = 'Color(0xff';
                                        const end = ')';

                                        final startIndex = mainColorString.indexOf(start);
                                        final endIndex = mainColorString.indexOf(end, startIndex + start.length);
                                        await newClass('$newClassName', '#' + mainColorString.substring(startIndex + start.length, endIndex));
                                        Navigator.pop(context);
                                        Navigator.pushReplacementNamed(context, '/home');
                                      }
                                    }
                                  }),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
