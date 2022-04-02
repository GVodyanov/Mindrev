import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hive_flutter/hive_flutter.dart';

class NewFlashcards extends StatefulWidget {
  const NewFlashcards({Key? key}) : super(key: key);

  @override
  State<NewFlashcards> createState() => _NewFlashcardsState();
}

class _NewFlashcardsState extends State<NewFlashcards> {
  //open box
  var box = Hive.lazyBox('mindrev');

  //futures that will be awaited by FutureBuilder
  Future futureText = readText('newFlashcards');
  Map routeData = {};

  //get already created flashcards
  Future<List<Map>?> getFlashcardsList(
    String materialName,
    String topicName,
    String className,
  ) async {
    MindrevFlashcards flashcards = await box.get('$className/$topicName/$materialName');
    return flashcards.cards;
  }

  //List that contains created Flashcards
  List<Map> flashcardsList = [
    {'front': '', 'back': ''}
  ];

  //bool to see if previous flashcards had been loaded, kind of janky ik
  bool restored = false;

  @override
  void initState() {
    super.initState();
  }

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

    //position variables
    String className = routeData['className'];
    String topicName = routeData['topicName'];
    String materialName = routeData['name'];

    return FutureBuilder(
      future: Future.wait([
        futureText,
        getFlashcardsList(
          routeData['name'],
          routeData['topicName'],
          routeData['className'],
        ),
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          Map text = snapshot.data![0];
          //assign previous flashcards list if it isn't empty
          if (snapshot.data![1].isNotEmpty &&
              flashcardsList[0]['front'] == '' &&
              flashcardsList[0]['back'] == '' &&
              !restored) {
            flashcardsList = snapshot.data![1];
            restored = true;
          }
          return Scaffold(
            backgroundColor: theme.primary,

            //appbar
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(text['title']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: contrastSecondaryColor,
                  ),
                  onPressed: () async {
                    //save flashcards and send back, while reloading previous page
                    MindrevFlashcards flashcards =
                        await box.get('$className/$topicName/$materialName');
                    flashcards.cards = flashcardsList;
                    await box.put('$className/$topicName/$materialName', flashcards);
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      '/flashcards',
                      arguments: routeData,
                    );
                  },
                )
              ],
            ),

            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  foregroundColor: contrastAccentColor,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: Text(
                    text['new'],
                  ),
                  backgroundColor: routeData['accentColor'],
                  onPressed: () {
                    setState(() {
                      flashcardsList.add({'front': '', 'back': ''});
                    });
                  },
                ),
                const SizedBox(width: 20),
                FloatingActionButton.extended(
                  foregroundColor: contrastAccentColor,
                  label: const Icon(
                    Icons.delete,
                  ),
                  backgroundColor: routeData['accentColor'],
                  onPressed: () {
                    setState(() {
                      flashcardsList.removeLast();
                      if (flashcardsList.isEmpty) {
                        flashcardsList = [
                          {'front': '', 'back': ''}
                        ];
                      }
                    });
                  },
                ),
              ],
            ),

            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    for (Map i in flashcardsList)
                      Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Material(
                                color: theme.primary,
                                elevation: 4,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: TextFormField(
                                    initialValue: i['front'],
                                    style: defaultPrimaryTextStyle(),
                                    onChanged: (String value) => i['front'] = value,
                                    cursorColor: routeData['accentColor'],
                                    decoration: InputDecoration(
                                      hintText: text['front'],
                                      hintStyle: defaultPrimaryTextStyle(),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Material(
                                color: theme.primary,
                                elevation: 4,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: TextFormField(
                                    initialValue: i['back'],
                                    style: defaultPrimaryTextStyle(),
                                    onChanged: (String value) => i['back'] = value,
                                    cursorColor: routeData['accentColor'],
                                    decoration: InputDecoration(
                                      hintText: text['back'],
                                      hintStyle: defaultPrimaryTextStyle(),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return loading();
        }
      },
    );
  }
}
