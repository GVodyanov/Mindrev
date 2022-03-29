import 'package:flash_card/flash_card.dart';
import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hive_flutter/hive_flutter.dart';

class NewFlashcards extends StatefulWidget {
  const NewFlashcards({ Key? key }) : super(key: key);

  @override
  State<NewFlashcards> createState() => _NewFlashcardsState();
}

class _NewFlashcardsState extends State<NewFlashcards> {
  //open box
  var box = Hive.lazyBox('mindrev');

  //futures that will be awaited by FutureBuilder
  Future futureText = readText('flashcards');
  Map routeData = {};

  //List that contains created Flashcards
  List? flashcards = [{'front' : '', 'back' : ''}];

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
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          Map text = snapshot.data![0];

          return Scaffold(
            backgroundColor: theme.primary,

            //appbar
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(text['title']),
            ),

            floatingActionButton: FloatingActionButton.extended (
              foregroundColor: contrastAccentColor,
              icon: const Icon (
                Icons.add,
              ),
              label: Text(
                text['new'],
              ),
              backgroundColor: routeData['accentColor'],
              onPressed: () {
                setState(() {
                  flashcards!.add({'front' : '', 'back' : ''});
                });
              },
            ),

            body: SingleChildScrollView(
              child: Center (
                child: Column (
                  children: [
                    // for (Map i in flashcards) Padding (
                    //   child:  
                    // )
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