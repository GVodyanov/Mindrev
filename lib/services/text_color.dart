import 'package:flutter/material.dart';

//contains a function that determines whether it makes more sense to use white or black as a foreground for a certain hexcolor
Color textColor(dynamic color) {
  //convert Color into hex string
  color = color.toString();
  const start = 'Color(0xff';
  const end = ')';
  final startIndex = color.indexOf(start);
  final endIndex = color.indexOf(end, startIndex + start.length);
  color = '#' +
      color.substring(
        startIndex + start.length,
        endIndex,
      );
  int red = int.parse(color.substring(1, 3), radix: 16);
  int green = int.parse(color.substring(3, 5), radix: 16);
  int blue = int.parse(color.substring(5, 7), radix: 16);

  if (red * 0.299 + green * 0.587 + blue * 0.114 > 160) {
    return Colors.black87;
  } else {
    return Colors.white;
  }
}
