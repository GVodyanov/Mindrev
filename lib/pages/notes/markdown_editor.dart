import 'package:flutter/material.dart';

import 'package:mindrev/pages/notes/markdown_text_input/markdown_text_input.dart';
import 'package:mindrev/pages/notes/markdown_text_input/format_markdown.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/services/text.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({Key? key}) : super(key: key);

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool edit = false;

  //controller for hiding/showing appBar
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;

    var theme = routeData['theme'];
    var notes = routeData['notes'];
    // Map text = routeData['text'];

    if (notes.content == '') edit = true;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.primary,
      appBar: ScrollAppBar(
        controller: scrollController,
        foregroundColor: theme.secondaryText,
        title: Text(notes.name),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              routeData['text'] = await readText('materialExtra');
              Navigator.pushNamed(context, '/materialExtra', arguments: routeData);
            },
          ),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: edit
              ? MarkdownTextInput(
                  (String value) => setState(() {
                    //update notes when modified
                    notes.content = value;
                    local.updateMaterialData(
                      notes,
                      routeData['topic'],
                      routeData['class'],
                    );
                  }),
                  notes.content,
                  maxLines: null,
                  actions: MarkdownType.values,
                  controller: controller,
                  theme: theme,
                  scrollController: scrollController,
                )
              : Markdown(
                  controller: scrollController,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(color: theme.primaryText, fontSize: 25),
                    h1Align: WrapAlignment.center,
                    h2: TextStyle(color: theme.primaryText, fontSize: 23),
                    h3: TextStyle(color: theme.primaryText, fontSize: 21),
                    h4: TextStyle(color: theme.primaryText, fontSize: 19),
                    h5: TextStyle(color: theme.primaryText, fontSize: 17),
                    h6: TextStyle(color: theme.primaryText, fontSize: 15.5),
                    listBullet: TextStyle(color: theme.primaryText),
                    p: TextStyle(color: theme.primaryText, fontSize: 14.5),
                    a: TextStyle(color: theme.accent, decoration: TextDecoration.underline),
                    tableBody: TextStyle(color: theme.primaryText),
                    tableHead: TextStyle(color: theme.primaryText),
                    codeblockDecoration: const BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    code: TextStyle(
                      color: theme.primaryText,
                      backgroundColor: Colors.transparent,
                      fontFamily: 'SourceCodePro',
                    ),
                    blockquoteAlign: WrapAlignment.center,
                    blockquoteDecoration: const BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onTapLink: (String text, String? href, String title) {
                    launchUrlString(href!);
                  },
                  data: notes.content,
                  shrinkWrap: true,
                ),
        ),
      ),
    );
  }
}
