import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/models/mindrev_notes.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/widgets/widgets.dart';

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
  Map? routeData;

  @override
  void initState() {
    super.initState();
    local.getSettings().then((MindrevSettings settings) => setState(() => this.settings = settings));
  }

  @override
  void didChangeDependencies() {
    routeData = ModalRoute.of(context)?.settings.arguments as Map;
    local
        .getMaterialData(routeData!['material'], routeData!['topic'], routeData!['class'])
        .then((value) => setState(() => notes = value));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (settings != null && notes != null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) async {
        routeData!['notes'] = notes;
        if (settings?.markdownEdit == true) {
          Navigator.pushReplacementNamed(context, '/markdownEditor', arguments: routeData);
        } else {
          Navigator.pushReplacementNamed(context, '/normalEditor', arguments: routeData);
        }
      });
    }
    return loading();
  }
}
