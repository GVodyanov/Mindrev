import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

class LearnFlashcards extends StatefulWidget {
  const LearnFlashcards({Key? key}) : super(key: key);

  @override
  State<LearnFlashcards> createState() => _LearnFlashcardsState();
}

class _LearnFlashcardsState extends State<LearnFlashcards> {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    shuffledCards = shuffle(routeData['flashcards']!.displayCards(routeData['reverse']));
  }

  @override
  Widget build(BuildContext context) {
    //route data to get class information
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;

    var theme = routeData['theme'];
    var flashcards = routeData['flashcards'];
    Map text = routeData['text'];
    bool? reverse = routeData['reverse'];

    //check if there are cards to display and in case index too high quit
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      //also make sure we only pop once
      if (flashcards.displayCards(reverse).isEmpty && !popped) {
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
        foregroundColor: theme.secondaryText,
        title: Text(text['title']),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
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
              if (shuffledCards != null && index <= shuffledCards!.length - 1)
                Flexible(
                  child: shuffledCards![index],
                ),
              const SizedBox(height: 50),
              if (index <= shuffledCards!.length - 1)
                Flexible(
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
  }
}
