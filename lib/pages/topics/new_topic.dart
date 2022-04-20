import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/db.dart';

class NewTopic extends StatefulWidget {
  const NewTopic({Key? key}) : super(key: key);

  @override
  State<NewTopic> createState() => _NewTopicState();
}

class _NewTopicState extends State<NewTopic> {
  //controllers
  final TextEditingController _topicNameController = TextEditingController();

  @override
  dispose() {
    //dispose controller
    _topicNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    //calling it mClass as class is reserved
    var mClass = routeData['class'];
    var theme = routeData['theme'];
    Map text = routeData['text'];

    return Scaffold(
      backgroundColor: theme.primary,
      appBar: AppBar(
        foregroundColor: theme.secondaryText,
        title: Text(
          text['title'],
          style: defaultSecondaryTextStyle(),
        ),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
      ),

      //body with everything
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                TextField(
                  controller: _topicNameController,
                  cursorColor: theme.accent,
                  style: defaultPrimaryTextStyle(),
                  decoration: defaultPrimaryInputDecoration(
                    text['label'],
                  ),
                ),
                const SizedBox(height: 30),
                coloredButton(
                  text['submit'],
                  (() async {
                    //check if class name is empty
                    if (_topicNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(defaultSnackbar(text['errorNoText']));
                    } else {
                      //if not go ahead and create class
                      await local.newTopic(
                        MindrevTopic(
                          _topicNameController.text,
                        ),
                        mClass,
                        routeData['structure'],
                      );
                      Navigator.pop(context);
                      //update routeData and go back to topics page
                      routeData['class'] = mClass;
                      Navigator.pushReplacementNamed(context, '/topics', arguments: routeData);
                    }
                  }),
                  theme.accent,
                  theme.accentText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
