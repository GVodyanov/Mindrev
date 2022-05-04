import 'package:flutter/material.dart';

import 'package:super_editor/super_editor.dart';

class NormalEditor extends StatefulWidget {
  const NormalEditor({Key? key}) : super(key: key);

  @override
  State<NormalEditor> createState() => _NormalEditorState();
}

class _NormalEditorState extends State<NormalEditor> {
  // A MutableDocument is an in-memory Document. Create the starting
// content that you want your editor to display.
//
// Your MutableDocument does not need to contain any content/nodes.
// In that case, your editor will initially display nothing.
  final myDoc = deserializeMarkdownToDocument(
    '''hi
  ''',
  );

// With a MutableDocument, create a DocumentEditor, which knows how
// to apply changes to the MutableDocument.

// Next: pass the docEditor to your Editor widget.

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    var notes = routeData['notes'];
    // Map text = routeData['text'];
    var theme = routeData['theme'];

    final docEditor = DocumentEditor(document: myDoc);

    return Scaffold(
      backgroundColor: theme.primary,
      appBar: AppBar(
        foregroundColor: theme.secondaryText,
        title: Text(notes.name),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: theme.secondaryText,
            ),
            onPressed: () async {},
          )
        ],
      ),
      body: SuperEditor(
        customStylePhases: const [
          // defaultPrimaryTextStyle()
        ],
        editor: docEditor,
        autofocus: true,
        // stylesheet: Stylesheet(
        //   documentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 200),
        //   rules: [],
        //   inlineTextStyler: (idk, sad) {
        //
        //   }
        // ),
      ),
    );
  }
}
