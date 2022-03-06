import 'package:flutter/material.dart';

import 'package:mindrev/extra/theme.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

AlertStyle defaultAlert = AlertStyle(
  animationType: AnimationType.grow,
  isCloseButton: true,
  isOverlayTapDismiss: true,
  animationDuration: const Duration(milliseconds: 300),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    side: const BorderSide(),
  ),
  backgroundColor: theme.secondary,
  titleStyle: TextStyle(
    color: theme.secondaryText,
  ),
);

DialogButton defaultDialogButton(String text, context, Function onPressed) {
  return DialogButton(
    child: Text(
      text,
      style: TextStyle(fontSize: 20, color: theme.accentText),
    ),
    onPressed: () => onPressed(),
    color: theme.accent,
  );
}

ElevatedButton defaultButton(String text, Function onPressed) {
  return ElevatedButton(
    child: Text(text, style: TextStyle(color: theme.accentText)),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(20),
      primary: theme.accent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
    onPressed: () => onPressed(),
  );
}

ElevatedButton coloredButton(String text, Function onPressed, Color color, Color textColor) {
  return ElevatedButton(
    child: Text(text, style: TextStyle(color: textColor)),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(20),
      primary: color,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
    onPressed: () => onPressed(),
  );
}

InputDecoration defaultPrimaryInputDecoration(String text) {
  return InputDecoration(
    labelStyle: TextStyle(color: theme.primaryText),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.primaryText ??= Colors.white,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.primaryText ??= Colors.white,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.primaryText ??= Colors.white,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.primaryText ??= Colors.white,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.primaryText ??= Colors.white,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.primaryText ??= Colors.white,
      ),
    ),
    fillColor: theme.primary,
    labelText: text,
  );
}

InputDecoration defaultSecondaryInputDecoration(String text) {
  return InputDecoration(
    labelStyle: TextStyle(color: theme.secondaryText),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.secondaryText ??= Colors.white,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.secondaryText ??= Colors.white,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.secondaryText ??= Colors.white,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.secondaryText ??= Colors.white,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.secondaryText ??= Colors.white,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: theme.secondaryText ??= Colors.white,
      ),
    ),
    fillColor: theme.secondary,
    labelText: text,
  );
}

Center loading = Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  Text('Mindrev', style: TextStyle(color: theme.accent, fontFamily: 'Comfortaa-Bold', fontWeight: FontWeight.bold, fontSize: 40)),
  const SizedBox(height: 30),
  SpinKitFadingGrid(
    color: theme.accent,
    size: 50.0,
  )
]));

TextStyle defaultPrimaryTextStyle = TextStyle(color: theme.primaryText);

TextStyle defaultSecondaryTextStyle = TextStyle(color: theme.secondaryText);