import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flash_card/flash_card.dart';

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
        FlashCard(
          /// TODO add support for images and various other material
          // honestly not sure why front and back are inverted
          frontWidget: Text(i['back']),
          backWidget: Text(i['front']),
        ),
      );
    }
    return result;
  }

  //method to add a card
  void newCard(String front, String back) {
    cards!.add({
      'front': front,
      'back': back
    });
  }
}
