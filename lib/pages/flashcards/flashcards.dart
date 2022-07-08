import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/db.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

//add parameter called flashcards
class Flashcards extends StatefulWidget {
  const Flashcards({Key? key}) : super(key: key);

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  //values determined in initState
  Map? text;
  MindrevFlashcards? flashcards;

  //key for scroll snap list and focused int
  GlobalKey<ScrollSnapListState> scrollKey = GlobalKey();
  int focused = 0;

  @override
  initState() {
    super.initState();
    readText('flashcards').then((value) => setState(() => text = value));
  }

  @override
  void didChangeDependencies() {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;

    local
        .getMaterialData(routeData['material'])
        .then((value) => setState(() => flashcards = value));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    var theme = routeData['theme'];

    if (!(flashcards == null || text == null)) {
      routeData['flashcards'] = flashcards;
      return Scaffold(
        backgroundColor: theme.primary,

        //appbar
        appBar: AppBar(
          foregroundColor: theme.secondaryText,
          title: Text(flashcards!.name),
          elevation: 4,
          centerTitle: true,
          backgroundColor: theme.secondary,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () async {
                routeData['text'] = await readText('materialExtra');
                Navigator.pushNamed(context, '/materialExtra', arguments: routeData);
              },
            ),
          ],
        ),

        //new flashcard button
        floatingActionButton: FloatingActionButton.extended(
          foregroundColor: theme.accentText,
          icon: const Icon(
            Icons.add,
          ),
          label: Text(
            text?['new'],
          ),
          backgroundColor: theme.accent,
          onPressed: () {
            routeData['text'] = text!['newFlashcards'];
            Navigator.pushNamed(context, '/newFlashcards', arguments: routeData);
          },
        ),

        body: SingleChildScrollView(
          child: Center(
            child: flashcards!.cards!.isNotEmpty
                ? Column(
                    children: [
                      //section for previewing different flashcards
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
                                    itemCount: flashcards!.displayCards(false)!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        child: flashcards!.displayCards(false)![index],
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
                                  focused =
                                      (focused == flashcards!.displayCards(false)!.length)
                                          ? flashcards!.displayCards(false)!.length
                                          : focused + 1;
                                  scrollKey.currentState!.focusToItem(focused);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      //section for different flashcard actions
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
                                      color: theme.accent,
                                    ),
                                    title:
                                        Text(text?['learn'], style: defaultPrimaryTextStyle()),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: theme.primaryText,
                                    ),
                                    onTap: () {
                                      Alert(
                                        context: context,
                                        style: defaultAlertStyle(),
                                        title: text?['termOrDef'],
                                        desc: text?['termOrDefDesc'],
                                        buttons: [
                                          coloredDialogButton(
                                            text?['term'],
                                            context,
                                            () {
                                              routeData['text'] = text!['learnFlashcards'];
                                              routeData['reverse'] = false;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/learnFlashcards',
                                                arguments: routeData,
                                              );
                                            },
                                            theme.accent,
                                            theme.accentText,
                                          ),
                                          coloredDialogButton(
                                            text?['def'],
                                            context,
                                            () {
                                              routeData['text'] = text!['learnFlashcards'];
                                              routeData['reverse'] = true;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/learnFlashcards',
                                                arguments: routeData,
                                              );
                                            },
                                            theme.accent,
                                            theme.accentText,
                                          )
                                        ],
                                      ).show();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.fitness_center,
                                      color: theme.accent,
                                    ),
                                    title: Text(
                                      text?['practice'],
                                      style: defaultPrimaryTextStyle(),
                                    ),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: theme.primaryText,
                                    ),
                                    onTap: () {
                                      Alert(
                                        context: context,
                                        style: defaultAlertStyle(),
                                        title: text?['termOrDef'],
                                        desc: text?['termOrDefDesc'],
                                        buttons: [
                                          coloredDialogButton(
                                            text?['term'],
                                            context,
                                            () {
                                              routeData['text'] = text!['practiceFlashcards'];
                                              routeData['reverse'] = false;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/practiceFlashcards',
                                                arguments: routeData,
                                              );
                                            },
                                            theme.accent,
                                            theme.accentText,
                                          ),
                                          coloredDialogButton(
                                            text?['def'],
                                            context,
                                            () {
                                              routeData['text'] = text!['practiceFlashcards'];
                                              routeData['reverse'] = true;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/practiceFlashcards',
                                                arguments: routeData,
                                              );
                                            },
                                            theme.accent,
                                            theme.accentText,
                                          )
                                        ],
                                      ).show();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.quiz, color: theme.accent),
                                    title:
                                        Text(text?['quiz'], style: defaultPrimaryTextStyle()),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: theme.primaryText,
                                    ),
                                    onTap: () {
                                      Alert(
                                        context: context,
                                        style: defaultAlertStyle(),
                                        title: text?['termOrDef'],
                                        desc: text?['termOrDefDesc'],
                                        buttons: [
                                          coloredDialogButton(
                                            text?['term'],
                                            context,
                                            () {
                                              routeData['text'] = text!['quizFlashcards'];
                                              routeData['reverse'] = false;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/quizFlashcards',
                                                arguments: routeData,
                                              );
                                            },
                                            theme.accent,
                                            theme.accentText,
                                          ),
                                          coloredDialogButton(
                                            text?['def'],
                                            context,
                                            () {
                                              routeData['text'] = text!['quizFlashcards'];
                                              routeData['reverse'] = true;
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                '/quizFlashcards',
                                                arguments: routeData,
                                              );
                                            },
                                            theme.accent,
                                            theme.accentText,
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
                    ],
                  )
                : empty(text?['create']),
          ),
        ),
      );
    } else {
      return loading();
    }
  }
}
