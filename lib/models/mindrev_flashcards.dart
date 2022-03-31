import 'package:flutter/material.dart';

import 'package:flip_card/flip_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';

part 'mindrev_flashcards.g.dart';

//flashcards material model
@HiveType(typeId: 3)
class MindrevFlashcards {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  String date = DateTime.now().toIso8601String();

  @HiveField(2)
  List<Map>? cards = [];

  //constructor
  MindrevFlashcards(this.name);

  //method to give a list of all the flashcards
  List<Widget>? displayCards() {
    List<Widget> result = [];
    for (Map i in cards ??= []) {
      result.add(
        FlipCard(
          /// TODO add support for images and various other material
          fill: Fill.fillBack,
          speed: 200,
          front: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: theme.primary,
            ),
            width: 200,
            height: 200,
            child: Center(
              child: Text(i['front'], style: defaultPrimaryTextStyle()),
            ),
          ),
          back: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: theme.primary,
            ),
            width: 200,
            height: 200,
            child: Center(
              child: Text(i['back'], style: defaultPrimaryTextStyle()),
            ),
          ),
        ),
      );
    }
    return result;
  }

  //method to add a card
  void newCard(String front, String back) {
    cards!.add({'front': front, 'back': back});
  }
}
