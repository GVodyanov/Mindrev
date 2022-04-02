import 'package:flutter/material.dart';

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
    return Container();
  }
}
