import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/color_to_hex.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/db.dart';

import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class NewClass extends StatefulWidget {
  const NewClass({Key? key}) : super(key: key);

  @override
  State<NewClass> createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  //controllers
  final TextEditingController _classNameController = TextEditingController();

  //color
  Color selectedColor = Colors.lightBlue;

  //function for creating a dialog for the color picker
  void openDialog(Widget content, Map text) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.secondary,
          contentPadding: const EdgeInsets.all(8.0),
          title:
              Text(text['chooseColorDetails'], style: TextStyle(color: theme.secondaryText)),
          content: content,
          actions: [
            defaultButton(text['submit'], Navigator.of(context).pop),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    //dispose controller
    _classNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    Map text = routeData['text'];

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
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                TextField(
                  controller: _classNameController,
                  cursorColor: theme.accent,
                  style: defaultPrimaryTextStyle(),
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
                            selectedColor: Colors.lightBlue,
                            onColorChange: (color) => setState(() {
                              selectedColor = color;
                            }),
                          ),
                          text,
                        );
                      }),
                    ),
                    leading: CircleColor(
                      circleSize: 30,
                      color: selectedColor,
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
                    //check if class name is empty
                    if (_classNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(defaultSnackbar(text['errorNoText']));
                    } else {
                      //if not go ahead and create class
                      await local.newClass(
                        MindrevClass(
                          _classNameController.text,
                          colorToHex(selectedColor).toString(),
                        ),
                      );
                      Navigator.pop(context);
                      //we don't pass in the new structure and let home fetch from database
                      //again because if doesn't have routeData seeing as it is the first
                      //page
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
