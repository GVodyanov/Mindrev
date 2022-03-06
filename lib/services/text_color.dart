import 'package:flutter/material.dart';

//contains a function that determines whether it makes more sense to use white or black as a foreground for a certain hexcolor
Color textColor(String color) {
  int red = int.parse(color.substring(1, 3), radix: 16);
  int green = int.parse(color.substring(3, 5), radix: 16);
  int blue = int.parse(color.substring(5, 7), radix: 16);

  if (red * 0.299 + green * 0.587 + blue * 0.114 > 160) {
    return Colors.black87;
  } else {
    return Colors.white;
  }
}
