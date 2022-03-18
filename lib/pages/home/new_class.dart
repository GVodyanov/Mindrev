import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/color_to_hex.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';

class NewClass extends StatefulWidget {
  const NewClass({Key? key}) : super(key: key);

  @override
  _NewClassState createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('newClass');

  //variables for form
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
  Future<bool> newClass(String name, Color color) async {
    var box = Hive.lazyBox('mindrev');

    //check if the class already exists
    List classes = await box.get('classes') ?? [];
    for (MindrevClass i in classes) {
      if (i.name == name) return false;
    }

    //write the information
    MindrevClass newClass = MindrevClass(name, colorToHex(color).toString());
    classes.add(newClass);
    await box.put('classes', classes);
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
              foregroundColor: theme.secondaryText,
              title: Text(
                text['title'],
                style: defaultSecondaryTextStyle(),
              ),
              elevation: 4,
              centerTitle: true,
              backgroundColor: theme.secondary,
            ),

            //body with everything else
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
                                style: defaultPrimaryTextStyle(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return text['errorNoText'];
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  setState(() {
                                    newClassName = value;
                                  });
                                },
                                decoration: defaultPrimaryInputDecoration(
                                  text['label'],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                child: ListTile(
                                  trailing: defaultButton(
                                    text['chooseColor'],
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
                                text['submit'],
                                (() async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState?.save();
                                    if (newClassName != null) {
                                      await newClass(
                                        '$newClassName',
                                        mainColor,
                                      );
                                      Navigator.pop(context);
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
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
