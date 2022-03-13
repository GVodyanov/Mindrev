import 'package:flutter/material.dart';

String colorToHex(Color? color) {
  String colorString = color.toString();
  const start = 'Color(0xff';
  const end = ')';
  final startIndex = colorString.indexOf(start);
  final endIndex = colorString.indexOf(end, startIndex + start.length);
  return '#' +
      colorString.substring(
        startIndex + start.length,
        endIndex,
      );
}
