import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:flash_card/flash_card.dart';

class Flashcards extends StatefulWidget {
  const Flashcards({Key? key}) : super(key: key);

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  //open box
  var box = Hive.lazyBox('mindrev');

  //key for scroll snap list and focused int
  GlobalKey<ScrollSnapListState> scrollKey = GlobalKey();
  int focused = 0;

  //futures that will be awaited by FutureBuilder
  Future futureText = readText('materials');
  Map routeData = {};

  Future<MindrevFlashcards> getFlashcards(String materialName, String topicName, String className) async {
    return await box.get('$className/$topicName/$materialName');
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
        getFlashcards(
          routeData['name'],
          routeData['topicName'],
          routeData['className'],
        ),
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          MindrevFlashcards flashcards = snapshot.data![1];
          List displayCards = flashcards.displayCards() ?? [];
          return Scaffold(
            backgroundColor: theme.primary,

            //appbar
            appBar: AppBar(
              foregroundColor: contrastSecondaryColor,
              title: Text(routeData['name']),
              elevation: 4,
              centerTitle: true,
              backgroundColor: routeData['secondaryColor'],
            ),

            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: theme.secondary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            color: theme.secondaryText,
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              focused = (focused == 0) ? 0 : focused - 1;
                              scrollKey.currentState!.focusToItem(focused);
                            },
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: SizedBox(
                              height: 200,
                              child: ScrollSnapList(
                                key: scrollKey,
                                onItemFocus: (index) {},
                                itemSize: 200,
                                itemCount: displayCards.length,
                                itemBuilder: (context, index) {
                                  return displayCards[index];
                                },
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            color: theme.secondaryText,
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              focused = (focused == displayCards.length) ? displayCards.length : focused + 1;
                              scrollKey.currentState!.focusToItem(focused);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
