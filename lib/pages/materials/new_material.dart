import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindrev/models/mindrev_material.dart';

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/models/mindrev_flashcards.dart';

import 'package:toml/toml.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NewMaterial extends StatefulWidget {
  const NewMaterial({Key? key}) : super(key: key);

  @override
  State<NewMaterial> createState() => _NewMaterialState();
}

class _NewMaterialState extends State<NewMaterial> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('newMaterial');
  Future futureMaterials = rootBundle.loadString('assets/materials.toml');

  Map routeData = {};

  //variables for form
  final _formKey = GlobalKey<FormState>();
  String? newMaterialName;
  int? selected;
  String? type;

  //function to create a new material
  Future<bool> newMaterial(String name, String type, String topicName, String className) async {
    var box = Hive.lazyBox('mindrev');
    //get list of materials from right topic
    List classes = await box.get('classes');
    List topics = classes.firstWhere((element) => element.name == className).topics;
    List materials = topics.firstWhere((element) => element.name == topicName).materials;

    //check if the material already exists
    for (MindrevMaterial i in materials) {
      if (i.name == name) return false;
    }

    MindrevMaterial newMaterial = MindrevMaterial(name, type);
    materials.add(newMaterial);

    topics[topics.indexWhere((element) => element.name == topicName)].materials = materials;
    classes[classes.indexWhere((element) => element.name == className)].topics = topics;
    await box.put('classes', classes);

    if (type == 'Flashcards') await box.put('$className/$topicName/$name', MindrevFlashcards(name));
    return true;
  }

  //function to return a list of materials to display
  List<Widget> displayMaterial(rawTOML, Color accentColor, Color contrastColor) {
    var material = TomlDocument.parse(rawTOML).toMap();
    List<Widget> result = [];
    int j = material['materials'].length;
    for (int i = j - 1; i >= 0; i--) {
      if (selected == i) type = material['materials'][i]['name'];
      result.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: selected == i ? accentColor : theme.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/study_material_icons/${material['materials'][i]['icon']}.svg',
                  color: selected == i ? contrastColor : accentColor,
                ),
                const SizedBox(height: 10, width: 100),
                Text(material['materials'][i]['name'], style: TextStyle(color: selected == i ? contrastColor : theme.primaryText))
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
  Widget build(BuildContext context) {
    //route data to get class information
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;

    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastAccentColor = routeData['accentColor'] == theme.accent ? theme.accentText : textColor(routeData['accentColor']);
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary ? theme.secondaryText : textColor(routeData['secondaryColor']);

    return FutureBuilder(
      future: Future.wait([
        futureText,
        futureMaterials
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          Map text = snapshot.data![0];
          String materials = snapshot.data![1];
          return Scaffold(
            backgroundColor: theme.primary,
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(text['title']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                                newMaterialName = value;
                              });
                            },
                            decoration: defaultPrimaryInputDecoration(text['label']),
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
                                      for (Widget i in displayMaterial(materials, routeData['accentColor'], contrastAccentColor ?? Colors.white)) i
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
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                if (newMaterialName != null && type != null) {
                                  bool outcome = await newMaterial('$newMaterialName', '$type', routeData['topicName'], routeData['className']);
                                  if (outcome == true) {
                                    Navigator.pop(context);
                                    Navigator.pushReplacementNamed(context, '/materials', arguments: routeData);
                                  } else {
                                    showDialog<String>(
                                      context: ctx,
                                      builder: (BuildContext ctx) => AlertDialog(
                                        title: Text(text['duplicate'], style: defaultPrimaryTextStyle()),
                                        actions: <Widget>[
                                          coloredButton(
                                            text['close'],
                                            () {
                                              Navigator.pop(context, text['close']);
                                            },
                                            routeData['accentColor'],
                                            contrastAccentColor ?? Colors.white,
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                }
                              }
                            }),
                            routeData['accentColor'],
                            contrastAccentColor ?? Colors.white,
                          )
                        ],
                      ),
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
