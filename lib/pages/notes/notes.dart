import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/models/mindrev_notes.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:notus_to_html_to_notus/notus_to_html_to_notus.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {

  //what this file does is determine whether we want to edit with markdown or zefyrka, as
  //defined in settings, and route to correct editor
  MindrevSettings? settings;
  MindrevNotes? notes;

  @override
  void initState() {
    super.initState();
    local.getSettings().then((MindrevSettings settings) => setState(() => this.settings = settings));
    ///TODO fetch notes and route
  }

  @override
  Widget build(BuildContext context) {
    if (settings != null) {
      if (settings?.markdownEdit == true) {
        print('markdown');
      } else {
        print('zefyrka');
      }
    }
    return loading();
  }
}
