import 'package:flutter/material.dart';

class MindrevTheme {
  Color? primary;
  Color? primaryText;
  Color? secondary;
  Color? secondaryText;
  Color? accent;
  Color? accentText;

  MindrevTheme(
    this.primary,
    this.primaryText,
    this.secondary,
    this.secondaryText,
    this.accent,
    this.accentText
  );
}

var theme = MindrevTheme(Colors.white, Colors.black87, Colors.grey[900], Colors.white, Colors.lightBlue, Colors.white);

