import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hive_flutter/hive_flutter.dart';

class LearnFlashcards extends StatefulWidget {
  const LearnFlashcards({Key? key}) : super(key: key);

  @override
  State<LearnFlashcards> createState() => _LearnFlashcardsState();
}

class _LearnFlashcardsState extends State<LearnFlashcards> {
  //open box
  var box = Hive.lazyBox('mindrev');

  //futures that will be awaited by FutureBuilder
  Future futureText = readText('learnFlashcards');
  Map routeData = {};

  Future<MindrevFlashcards> getFlashcards(
    String materialName,
    String topicName,
    String className,
  ) async {
    return await box.get('$className/$topicName/$materialName');
  }

  //function to shuffle list
  List<Widget>? shuffle(List<Widget>? list) {
    for (var i = list!.length - 1; i > 0; i--) {
      final j = Random().nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  int index = 0;
  List? shuffledCards;
  bool popped = false;

  @override
  Widget build(BuildContext context) {
    //route data to get class information
    routeData =
        routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;
    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary
        ? theme.secondaryText
        : textColor(routeData['secondaryColor']);

    return FutureBuilder(
      future: Future.wait([
        futureText,
        getFlashcards(routeData['name'], routeData['topicName'], routeData['className']),
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          MindrevFlashcards flashcards = snapshot.data![1];

          //get cards to display and shuffle
          List<Widget> displayCards = [];
          displayCards = flashcards.displayCards(routeData['reverse']) ?? [];
          shuffledCards ??= shuffle(displayCards);

          //check if there are cards to display and in case index too high quit
          SchedulerBinding.instance!.addPostFrameCallback((_) async {
            //also make sure we only pop once
            if (displayCards.isEmpty && !popped) {
              Navigator.pop(context);
              popped = true;
            }
            if (index > shuffledCards!.length - 1 && !popped) {
              Navigator.pop(context);
              popped = true;
            }
          });

          return Scaffold(
            backgroundColor: theme.secondary,
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(text['title']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //here we also want to check that we haven't finished the index yet
                    //seeing as build happens before condition to pop
                    if (shuffledCards != null && index <= shuffledCards!.length - 1) Flexible(
                      child: shuffledCards![index],
                    ),
                    const SizedBox(height: 50),
                    if (index <= shuffledCards!.length - 1) Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //note to self maybe remove old flip cards from list
                          IconButton(
                            onPressed: () {
                              setState(() {
                                index++;
                              });
                            },
                            icon: Icon(Icons.check, color: theme.secondaryText),
                          ),
                          const SizedBox(width: 60),
                          IconButton(
                            onPressed: () {
                              //if we make a mistake add the card to the list to be reviewed
                              setState(() {
                                shuffledCards!.add(
                                  shuffledCards![index],
                                );
                                index++;
                              });
                            },
                            icon: Icon(Icons.close, color: theme.secondaryText),
                          ),
                        ],
                      ),
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
