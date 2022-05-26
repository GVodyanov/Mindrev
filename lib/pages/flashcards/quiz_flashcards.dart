import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:confetti/confetti.dart';

class QuizFlashcards extends StatefulWidget {
  const QuizFlashcards({Key? key}) : super(key: key);

  @override
  State<QuizFlashcards> createState() => _QuizFlashcardsState();
}

class _QuizFlashcardsState extends State<QuizFlashcards> {
  MindrevSettings? settings;

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

  //text field controller to be able to clear after every card
  final fieldController = TextEditingController();

  //confetti controller
  late ConfettiController _confettiController;

  //final score list
  List<Map> score = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
    local.getSettings().then((value) => setState(() => settings = value));
  }

  //dispose
  @override
  void dispose() {
    super.dispose();
    fieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    var theme = routeData['theme'];
    var flashcards = routeData['flashcards'];
    Map text = routeData['text'];

    if (settings != null) {
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
          'answer': i[routeData['reverse'] ? 'front' : 'back'],
          //needed later for displaying score details
          'questionText': i[routeData['reverse'] ? 'back' : 'front'],
        });
      }

      shuffledCards ??= shuffle(displayCards);

      //check if there are cards to display and in case index too high quit
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        //also make sure we only pop once
        if (displayCards.isEmpty && !popped) {
          Navigator.pop(context);
          popped = true;
        }
        if (index > shuffledCards!.length - 1 && !popped) {
          Alert(
            context: context,
            title: text['results'],
            style: defaultAlertStyle(),
            content: Column(
              children: [
                //show a material containing details on every question
                for (Map i in score)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: theme.primary,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            //icon
                            if (i['result'] == 'perfect')
                              ListTile(
                                leading: Icon(Icons.done_all, color: theme.primaryText),
                                trailing: Text(
                                  text['perfect'],
                                  style: defaultPrimaryTextStyle(),
                                ),
                              ),
                            if (i['result'] == 'right')
                              ListTile(
                                leading: Icon(Icons.done, color: theme.primaryText),
                                trailing:
                                    Text(text['right'], style: defaultPrimaryTextStyle()),
                              ),
                            if (i['result'] == 'wrong')
                              ListTile(
                                leading: Icon(Icons.close, color: theme.primaryText),
                                trailing:
                                    Text(text['wrong'], style: defaultPrimaryTextStyle()),
                              ),
                            //asked question
                            Text(
                              text['question'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryText,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              i['question'] ?? ' ',
                              style: defaultPrimaryTextStyle(),
                            ),
                            //what user responded and correct answer, if needed
                            if (i['result'] == 'right' || i['result'] == 'wrong') ...[
                              const SizedBox(height: 20),
                              Text(
                                text['responded'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryText,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                i['responded'] ?? ' ',
                                style: defaultPrimaryTextStyle(),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              text['correctAnswer'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryText,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              i['correctAnswer'] ?? ' ',
                              style: defaultPrimaryTextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            buttons: [
              coloredDialogButton(
                text['close'],
                context,
                () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                theme.accent,
                theme.accentText,
              )
            ],
          ).show();
          _confettiController.play();
          popped = true;
        }
      });

      return Scaffold(
        backgroundColor: theme.secondary,
        appBar: AppBar(
          foregroundColor: theme.secondaryText,
          title: Text(text['title']),
          elevation: 4,
          centerTitle: true,
          backgroundColor: theme.secondary,
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
                    const SizedBox(height: 50),
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.2,
                      gravity: 0.95,
                      shouldLoop: false,
                    ),
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
                                    cursorColor: theme.accent,
                                    style: defaultSecondaryTextStyle(),
                                    decoration: defaultSecondaryInputDecoration(
                                      text[routeData['reverse'] ? 'term' : 'def'],
                                    ),
                                    controller: fieldController,
                                  ),
                                ),
                                //note to self maybe remove old flip cards from list
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      num similarity = StringSimilarity.compareTwoStrings(
                                        shuffledCards![index]['answer'],
                                        fieldController.text,
                                      );

                                      if (shuffledCards![index]['answer'].toLowerCase() ==
                                          fieldController.text.toLowerCase()) {
                                        //what we do if answer is identical
                                        score.add({
                                          'result': 'perfect',
                                          'question': shuffledCards![index]['questionText'],
                                          'correctAnswer': shuffledCards![index]['answer'],
                                          'responded': null,
                                        });
                                      } else if (similarity >= 0.82) {
                                        //what we do if answer is largely correct
                                        score.add({
                                          'result': 'right',
                                          'question': shuffledCards![index]['questionText'],
                                          'correctAnswer': shuffledCards![index]['answer'],
                                          'responded': fieldController.text,
                                        });
                                      } else {
                                        //here is what we do if the answer is wrong
                                        score.add({
                                          'result': 'wrong',
                                          'question': shuffledCards![index]['questionText'],
                                          'correctAnswer': shuffledCards![index]['answer'],
                                          'responded': fieldController.text,
                                        });
                                      }
                                      index++;
                                    });
                                    //clear the input field
                                    fieldController.clear();
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
  }
}
