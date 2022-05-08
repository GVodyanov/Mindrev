import 'package:flutter/material.dart';

import 'package:mindrev/widgets/widgets.dart';

import 'package:string_splitter/string_splitter.dart';

class BulkImport extends StatefulWidget {
  const BulkImport({Key? key}) : super(key: key);

  @override
  State<BulkImport> createState() => _BulkImportState();
}

class _BulkImportState extends State<BulkImport> {
  List<Map> imported = [];
  String? stringToSplit;
  String sideSplit = '\t';
  String cardSplit = '\n';
  bool customSideSplit = false;
  bool customCardSplit = false;

  @override
  Widget build(BuildContext context) {
    Map? routeData = ModalRoute.of(context)?.settings.arguments as Map;

    var flashcards = routeData['flashcards'];
    var theme = routeData['theme'];
    //we need to determine that we need bulkImport here so that when we pushReplacementNamed
    //we still have text from previous page
    Map text = routeData['text']['bulkImport'];

    //in build as we need text
    List<DropdownMenuItem<String>> splitOptions = [
      DropdownMenuItem(
        child: Text(text['tab']),
        value: '\t',
      ),
      DropdownMenuItem(
        child: Text(text['newLine']),
        value: '\n',
      ),
      DropdownMenuItem(
        child: Text(text['slash']),
        value: '/',
      ),
      DropdownMenuItem(
        child: Text(text['comma']),
        value: ',',
      ),
      DropdownMenuItem(
        child: Text(text['semicolon']),
        value: ';',
      ),
      DropdownMenuItem(
        child: Text(text['colon']),
        value: ':',
      ),
      DropdownMenuItem(
        child: Text(text['space']),
        value: ' ',
      ),
      DropdownMenuItem(
        child: Text(text['point']),
        value: '.',
      ),
      DropdownMenuItem(
        child: Text(text['custom']),
        value: 'custom',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.primary,
      appBar: AppBar(
        foregroundColor: theme.secondaryText,
        title: Text(text['title']),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: theme.accentText,
        backgroundColor: theme.accent,
        child: const Icon(Icons.check),
        onPressed: () {
          //add new imported flashcards to old list and update previous page
          flashcards.cards.addAll(imported);
          routeData['flashcards'] = flashcards;
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/newFlashcards', arguments: routeData);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Material(
                  color: theme.primary,
                  elevation: 4,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(text['sideSplit'], style: defaultPrimaryTextStyle()),
                        DropdownButton<String>(
                          dropdownColor: theme.primary,
                          style: defaultPrimaryTextStyle(),
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down, color: theme.accent),
                          focusColor: theme.primary,
                          //if value isn't included in splitOptions show custom
                          value: splitOptions
                                      .indexWhere((element) => element.value == sideSplit) !=
                                  -1
                              ? sideSplit
                              : 'custom',
                          items: splitOptions,
                          onChanged: (String? value) {
                            setState(() {
                              if (value == 'custom') {
                                customSideSplit = true;
                              } else {
                                customSideSplit = false;
                              }
                              sideSplit = value ?? '\t';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                //if custom selected show a text field
                if (customSideSplit)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      cursorColor: theme.accent,
                      style: defaultPrimaryTextStyle(),
                      decoration: defaultPrimaryInputDecoration(''),
                      onChanged: (String? value) {
                        setState(() => sideSplit = value ?? 'custom');
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                Material(
                  color: theme.primary,
                  elevation: 4,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(text['cardSplit'], style: defaultPrimaryTextStyle()),
                        DropdownButton<String>(
                          dropdownColor: theme.primary,
                          style: defaultPrimaryTextStyle(),
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down, color: theme.accent),
                          focusColor: theme.primary,
                          //if value isn't included in splitOptions show custom
                          value: splitOptions
                                      .indexWhere((element) => element.value == cardSplit) !=
                                  -1
                              ? cardSplit
                              : 'custom',
                          items: splitOptions,
                          onChanged: (String? value) {
                            setState(() {
                              if (value == 'custom') {
                                customCardSplit = true;
                              } else {
                                customCardSplit = false;
                              }
                              cardSplit = value ?? '\t';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                //if custom selected show a text field
                if (customCardSplit)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      cursorColor: theme.accent,
                      style: defaultPrimaryTextStyle(),
                      decoration: defaultPrimaryInputDecoration(''),
                      onChanged: (String? value) {
                        setState(() => cardSplit = value ?? 'custom');
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  minLines: 5,
                  maxLines: 10,
                  cursorColor: theme.accent,
                  style: defaultPrimaryTextStyle(),
                  decoration: defaultPrimaryInputDecoration(text['importData']),
                  onChanged: (String? value) => setState(() => stringToSplit = value ?? ''),
                ),
                const SizedBox(height: 20),
                coloredButton(
                  text['split'],
                  () {
                    //first split string into cards
                    setState(() {
                      List initialSplit;
                      List<Map> secondarySplit = [];
                      if (stringToSplit != null) {
                        initialSplit = StringSplitter.split(
                          stringToSplit!,
                          splitters: [cardSplit],
                          trimParts: true,
                        );
                        //next for every string result split into front and back and overwrite
                        for (var i = 0; i < initialSplit.length; i++) {
                          secondarySplit.add({
                            'front': StringSplitter.split(
                              initialSplit[i],
                              splitters: [sideSplit],
                              trimParts: true,
                            )[0],
                            'back': StringSplitter.split(
                              initialSplit[i],
                              splitters: [sideSplit],
                              trimParts: true,
                            )[1],
                          });
                        }
                        imported = secondarySplit;
                      }
                    });
                  },
                  theme.accent,
                  theme.accentText,
                ),
                const SizedBox(height: 20),
                Text(
                  text['preview'],
                  style: TextStyle(
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(),
                if (imported.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.primaryText,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 500),
                      child: ListView.separated(
                        itemCount: imported.length,
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemBuilder: (BuildContext context, int i) {
                          return ListTile(
                            textColor: theme.primaryText,
                            leading: Text(imported[i]['front']),
                            trailing: Text(imported[i]['back']),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
