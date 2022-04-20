import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindrev/models/mindrev_material.dart';

import 'package:mindrev/services/db.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:toml/toml.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewMaterial extends StatefulWidget {
  const NewMaterial({Key? key}) : super(key: key);

  @override
  State<NewMaterial> createState() => _NewMaterialState();
}

class _NewMaterialState extends State<NewMaterial> {
  //values determined in initState
  Map? materialTypes;

  int? selected;
  String? materialType;

  //controllers
  final TextEditingController _materialNameController = TextEditingController();

  //function to return a list of materials to display
  List<Widget> displayMaterial(materialTypes, var theme) {
    List<Widget> result = [];
    //cycle through materials and add them to result, if selected change colors
    for (int i = materialTypes['materials'].length - 1; i >= 0; i--) {
      if (selected == i) materialType = materialTypes['materials'][i]['name'];
      result.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: selected == i ? theme.accent : theme.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/study_material_icons/${materialTypes['materials'][i]['icon']}.svg',
                  color: selected == i ? theme.accentText : theme.accent,
                ),
                const SizedBox(height: 10, width: 100),
                Text(
                  materialTypes['materials'][i]['name'],
                  style:
                      TextStyle(color: selected == i ? theme.accentText : theme.primaryText),
                )
              ],
            ),
            onPressed: () {
              setState(() {
                selected = i;
              });
            },
          ),
        ),
      );
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    //wait for materials to load from file
    rootBundle
        .loadString('assets/materials.toml')
        .then((value) => setState(() => materialTypes = TomlDocument.parse(value).toMap()));
  }

  @override
  dispose() {
    _materialNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    //calling it mClass as class is reserved
    var topic = routeData['topic'];
    var theme = routeData['theme'];
    Map text = routeData['text'];

    if (materialTypes != null) {
      return Scaffold(
        backgroundColor: theme.primary,
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

        //body with everything
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  TextField(
                    controller: _materialNameController,
                    cursorColor: theme.accent,
                    style: defaultPrimaryTextStyle(),
                    decoration: defaultPrimaryInputDecoration(
                      text['label'],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: theme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(text['type'], style: defaultPrimaryTextStyle()),
                          const SizedBox(height: 20, width: double.infinity),
                          Wrap(
                            children: [
                              for (Widget i in displayMaterial(materialTypes, theme)) i
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  coloredButton(
                    text['submit'],
                    (() async {
                      //check if class name is empty
                      if (_materialNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(defaultSnackbar(text['errorNoText']));

                        if (materialType == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(defaultSnackbar(text['errorNoType']));
                        }
                      } else {
                        //if not go ahead and create class
                        await local.newMaterial(
                          MindrevMaterial(
                            _materialNameController.text,
                            materialType!,
                          ),
                          topic,
                          routeData['class'],
                          routeData['structure'],
                        );
                        Navigator.pop(context);
                        //update routeData and go back to topics page
                        routeData['topic'] = topic;
                        Navigator.pushReplacementNamed(
                          context,
                          '/materials',
                          arguments: routeData,
                        );
                      }
                    }),
                    theme.accent,
                    theme.accentText,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return loading();
    }
  }
}
