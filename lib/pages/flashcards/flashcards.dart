import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/text.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hexcolor/hexcolor.dart';

class Flashcards extends StatefulWidget {
  const Flashcards({ Key? key }) : super(key: key);

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  //open box
  var box = Hive.lazyBox('mindrev');
  
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('materials');
  Map routeData = {};

	Future<MindrevFlashcards> getFlashcards (String materialName, String topicName, String className) async {
  	return await box.get('$className/$topicName/$materialName');
	}
  
  @override
  Widget build(BuildContext context) {
    //route data to get class information
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;
    print (routeData);

    return FutureBuilder(
      future: Future.wait([
        futureText,
        getFlashcards(routeData['name'], routeData['topicName'], routeData['className']),
      ]),
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data![0];
          MindrevFlashcards flashcards = snapshot.data![1];
          List displayCards = flashcards.displayCards() ?? []; 
          return Column (
            children: [
							for (Widget i in displayCards) i
            ],
          );
        } else {
          return loading();
        }
      },
    );
  }
}
