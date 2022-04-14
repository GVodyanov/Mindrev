import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

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
  Future futureText = readText('flashcards');
  Map routeData = {};

  Future<MindrevFlashcards> getFlashcards(
    String materialName,
    String topicName,
    String className,
  ) async {
    return await box.get('$className/$topicName/$materialName');
  }

  @override
  Widget build(BuildContext context) {
    //route data to get class information
    routeData =
        routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;
    routeData['reverse'] == false;

    //set contrast color according to color passed through route data, if uiColors isn't set
    Color? contrastAccentColor = routeData['accentColor'] == theme.accent
        ? theme.accentText
        : textColor(routeData['accentColor']);
    Color? contrastSecondaryColor = routeData['secondaryColor'] == theme.secondary
        ? theme.secondaryText
        : textColor(routeData['secondaryColor']);

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
          List displayCards = flashcards.displayCards(null) ?? [];

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

            //new flashcard button
            floatingActionButton: FloatingActionButton.extended(
              foregroundColor: contrastAccentColor,
              icon: const Icon(
                Icons.add,
              ),
              label: Text(
                text['new'],
              ),
              backgroundColor: routeData['accentColor'],
              onPressed: () {
                Navigator.pushNamed(context, '/newFlashcards', arguments: routeData);
              },
            ),

            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //section to preview flashcards
                  if (displayCards.isNotEmpty)
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
                                    return Padding(
                                      child: displayCards[index],
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                    );
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
                                focused = (focused == displayCards.length)
                                    ? displayCards.length
                                    : focused + 1;
                                scrollKey.currentState!.focusToItem(focused);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  //section for different flashcard actions
                  if (displayCards.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: ListTile.divideTiles(
                              context: context,
                              tiles: [
                                ListTile(
                                  leading: Icon(
                                    Icons.menu_book_rounded,
                                    color: routeData['accentColor'],
                                  ),
                                  title:
                                      Text(text['learn'], style: defaultPrimaryTextStyle()),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: theme.primaryText,
                                  ),
                                  onTap: () {
                                    Alert(
                                      context: context,
                                      style: defaultAlertStyle(),
                                      title: text['termOrDef'],
                                      desc: text['termOrDefDesc'],
                                      buttons: [
                                        coloredDialogButton(
                                          text['term'],
                                          context,
                                          () {
                                            routeData['reverse'] = false;
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                              context,
                                              '/learnFlashcards',
                                              arguments: routeData,
                                            );
                                          },
                                          routeData['accentColor'],
                                          contrastAccentColor!,
                                        ),
                                        coloredDialogButton(
                                          text['def'],
                                          context,
                                          () {
                                            routeData['reverse'] = true;
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                              context,
                                              '/learnFlashcards',
                                              arguments: routeData,
                                            );
                                          },
                                          routeData['accentColor'],
                                          contrastAccentColor,
                                        )
                                      ],
                                    ).show();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.fitness_center,
                                    color: routeData['accentColor'],
                                  ),
                                  title:
                                  Text(text['practice'], style: defaultPrimaryTextStyle()),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: theme.primaryText,
                                  ),
                                  onTap: () {
                                    Alert(
                                      context: context,
                                      style: defaultAlertStyle(),
                                      title: text['termOrDef'],
                                      desc: text['termOrDefDesc'],
                                      buttons: [
                                        coloredDialogButton(
                                          text['term'],
                                          context,
                                              () {
                                            routeData['reverse'] = false;
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                              context,
                                              '/practiceFlashcards',
                                              arguments: routeData,
                                            );
                                          },
                                          routeData['accentColor'],
                                          contrastAccentColor!,
                                        ),
                                        coloredDialogButton(
                                          text['def'],
                                          context,
                                              () {
                                            routeData['reverse'] = true;
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                              context,
                                              '/practiceFlashcards',
                                              arguments: routeData,
                                            );
                                          },
                                          routeData['accentColor'],
                                          contrastAccentColor,
                                        )
                                      ],
                                    ).show();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.quiz, color: routeData['accentColor']),
                                  title: Text(text['quiz'], style: defaultPrimaryTextStyle()),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: theme.primaryText,
                                  ),
                                  onTap: () {
                                    Alert(
                                      context: context,
                                      style: defaultAlertStyle(),
                                      title: text['termOrDef'],
                                      desc: text['termOrDefDesc'],
                                      buttons: [
                                        coloredDialogButton(
                                          text['term'],
                                          context,
                                          () {
                                            routeData['reverse'] = false;
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                              context,
                                              '/quizFlashcards',
                                              arguments: routeData,
                                            );
                                          },
                                          routeData['accentColor'],
                                          contrastAccentColor!,
                                        ),
                                        coloredDialogButton(
                                          text['def'],
                                          context,
                                          () {
                                            routeData['reverse'] = true;
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                              context,
                                              '/quizFlashcards',
                                               arguments: routeData,
                                            );
                                          },
                                          routeData['accentColor'],
                                          contrastAccentColor,
                                        )
                                      ],
                                    ).show();
                                  },
                                ),
                              ],
                            ).toList(),
                          ),
                        ),
                      ),
                    ),
                  if (displayCards.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                        child: ConstrainedBox(
                          child: Material(
                            color: theme.primary,
                            elevation: 4,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                text['create'],
                                style: TextStyle(fontSize: 20, color: theme.primaryText),
                              ),
                            ),
                          ),
                          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
                        ),
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
