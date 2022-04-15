import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:confetti/confetti.dart';

class PracticeFlashcards extends StatefulWidget {
  const PracticeFlashcards({Key? key}) : super(key: key);

  @override
  State<PracticeFlashcards> createState() => _PracticeFlashcardsState();
}

class _PracticeFlashcardsState extends State<PracticeFlashcards> {
  //open box
  var box = Hive.lazyBox('mindrev');

  //futures that will be awaited by FutureBuilder
  Future futureText = readText('practiceFlashcards');
  Map routeData = {};

  Future<MindrevFlashcards> getFlashcards(
    String materialName,
    String topicName,
    String className,
  ) async {
    return await box.get('$className/$topicName/$materialName');
  }

  //function to get settings
  Future getSettings() async {
    return await box.get('settings');
  }

  //function to shuffle list
  List<Map>? shuffle(List<Map>? list) {
    for (var i = list!.length - 1; i > 0; i--) {
      final j = Random().nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  //index for flashcard list (shuffledCards)
  int index = 0;

  //list of flashcards to ask
  List? shuffledCards;

  //so as to not pop multiple times when finished
  bool popped = false;

  //answer input
  String? input;

  //text field controller to be able to clear after every card
  final fieldController = TextEditingController();

  //confetti controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
  }

  //dispose
  @override
  void dispose() {
    super.dispose();
    fieldController.dispose();
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

    return FutureBuilder(
      future: Future.wait([
        futureText,
        getFlashcards(routeData['name'], routeData['topicName'], routeData['className']),
        getSettings(),
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          MindrevFlashcards flashcards = snapshot.data![1];
          bool confetti = snapshot.data![2]['confetti'] ?? true;

          //get cards to display and shuffle
          List<Map> displayCards = [];
          for (Map i in flashcards.cards ?? []) {
            displayCards.add({
              //add a widget which will be our question
              'question': Material(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: theme.primary,
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  height: 200,
                  width: 200,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        i[routeData['reverse'] ? 'back' : 'front'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.primaryText,
                          //we want text to be bigger if we only have to show the term
                          fontSize: routeData['reverse'] ? 18 : 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //add a String which will be the correct answer
              'answer': i[routeData['reverse'] ? 'front' : 'back']
            });
          }

          shuffledCards ??= shuffle(displayCards);

          //snackbar to show when correct and perfect
          SnackBar? perfect;
          SnackBar? correct;

          if (shuffledCards != null && index <= shuffledCards!.length - 1) {
            perfect = SnackBar(
              content: Text(text['perfect'], style: defaultSecondaryTextStyle()),
              backgroundColor: theme.secondary,
              elevation: 20,
              duration: const Duration(milliseconds: 1500),
            );

            correct = SnackBar(
              content: Text(
                text['right'] + ': ' + shuffledCards![index]['answer'],
                style: defaultSecondaryTextStyle(),
              ),
              backgroundColor: theme.secondary,
              elevation: 20,
              duration: const Duration(milliseconds: 2500),
            );
          }

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
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //here we also want to check that we haven't finished the index yet
                        //seeing as build happens before condition to pop
                        if (shuffledCards != null && index <= shuffledCards!.length - 1)
                          Flexible(
                            child: shuffledCards![index]['question'],
                          ),
                        ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          emissionFrequency: 0.2,
                          gravity: 0.95,
                          shouldLoop: false,
                        ),
                        const SizedBox(height: 50),
                        if (index <= shuffledCards!.length - 1)
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600, minWidth: 50),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        cursorColor: routeData['accentColor'],
                                        style: defaultSecondaryTextStyle(),
                                        decoration: defaultSecondaryInputDecoration(
                                          text[routeData['reverse'] ? 'term' : 'def'],
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            input = value;
                                          });
                                        },
                                        controller: fieldController,
                                      ),
                                    ),
                                    //note to self maybe remove old flip cards from list
                                    IconButton(
                                      onPressed: () {
                                        //clear text
                                        fieldController.clear();
                                        setState(() {
                                          num similarity = StringSimilarity.compareTwoStrings(
                                            shuffledCards![index]['answer'],
                                            input,
                                          );

                                          if (shuffledCards![index]['answer'] == input) {
                                            //what we do if answer is identical
                                            if (confetti) {
                                              _confettiController.play();
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(perfect!);
                                          } else if (similarity >= 0.82) {
                                            //what we do if answer is largely correct
                                            if (confetti) {
                                              _confettiController.play();
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(correct!);
                                          } else {
                                            //here is what we do if the answer is wrong
                                            //add wrong question to the list to be reviewed
                                            shuffledCards!.add(
                                              shuffledCards![index],
                                            );

                                            Alert(
                                              context: context,
                                              style: defaultAlertStyle(),
                                              title: text['wrong'],
                                              desc: text['correctAnswer'] +
                                                  ': ' +
                                                  shuffledCards![index]['answer'],
                                              buttons: [
                                                coloredDialogButton(
                                                  text['next'],
                                                  context,
                                                  () {
                                                    Navigator.pop(context);
                                                  },
                                                  routeData['accentColor'],
                                                  contrastAccentColor!,
                                                ),
                                              ],
                                            ).show();
                                          }

                                          index++;
                                        });
                                      },
                                      icon: Icon(Icons.check, color: theme.secondaryText),
                                    ),
                                  ],
                                ),
                              ),
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
