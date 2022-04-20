import 'package:flutter/material.dart';

import 'package:mindrev/services/db.dart';
import 'package:mindrev/widgets/widgets.dart';

class NewFlashcards extends StatefulWidget {
  const NewFlashcards({Key? key}) : super(key: key);

  @override
  State<NewFlashcards> createState() => _NewFlashcardsState();
}

class _NewFlashcardsState extends State<NewFlashcards> {
  //to make sure that we aren't saving that one default card
  @override
  Widget build(BuildContext context) {
    //route data to get flashcard information
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;

    var theme = routeData['theme'];
    var flashcards = routeData['flashcards'];
    Map text = routeData['text'];

    return Scaffold(
      backgroundColor: theme.primary,

      //appbar
      appBar: AppBar(
        foregroundColor: theme.secondaryText,
        title: Text(text['title']),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: theme.secondaryText,
            ),
            onPressed: () async {
              //we don't want to save default card

              await local.updateMaterialData(
                flashcards,
                routeData['topic'],
                routeData['class'],
              );

              routeData['flashcards'] = flashcards;

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
            heroTag: 'add',
            foregroundColor: theme.accentText,
            icon: const Icon(
              Icons.add,
            ),
            label: Text(
              text['new'],
            ),
            backgroundColor: theme.accent,
            onPressed: () {
              setState(() {
                flashcards.cards.add({'front': '', 'back': ''});
              });
            },
          ),
          const SizedBox(width: 20),
          FloatingActionButton.extended(
            heroTag: 'delete',
            foregroundColor: theme.accentText,
            label: const Icon(
              Icons.delete,
            ),
            backgroundColor: theme.accent,
            onPressed: () {
              setState(() {
                flashcards.cards.removeLast();
                if (flashcards.cards.isEmpty) {
                  flashcards.cards = [
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
              for (Map i in flashcards.cards)
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
                              cursorColor: theme.accent,
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
                              cursorColor: theme.accent,
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
  }
}
