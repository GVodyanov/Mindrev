import 'package:flutter/material.dart';

import 'package:mindrev/pages/notes/markdown_text_input/markdown_text_input.dart';
import 'package:mindrev/pages/notes/markdown_text_input/format_markdown.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({Key? key}) : super(key: key);

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {

	bool edit = false;

  TextEditingController controller = TextEditingController();

	@override
	void dispose() {
  	super.dispose();
  	controller.dispose;
	}

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;

    var theme = routeData['theme'];
    var notes = routeData['notes'];
    // Map text = routeData['text'];

    if (notes.content == '') edit = true;

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
              edit == true ? Icons.check : Icons.edit,
              color: theme.secondaryText,
            ),
            onPressed: () async {
							setState(() {
  							edit = !edit;
							});
            },
          )
        ],
      ),
      // body: SingleChildScrollView(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800, minHeight: 800),
              child: MarkdownTextInput(
                (String value) => setState(() => notes.content = value),
                notes.content ,
                maxLines: null,
                actions: MarkdownType.values,
                controller: controller,
                theme: theme,
              ),
            ),
          ),

        ),
      // ),
    );
  }
}
