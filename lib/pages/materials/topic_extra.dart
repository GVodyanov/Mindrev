import 'package:flutter/material.dart';

import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/services/db.dart';

import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TopicExtra extends StatefulWidget {
  const TopicExtra({Key? key}) : super(key: key);

  @override
  State<TopicExtra> createState() => _TopicExtraState();
}

class _TopicExtraState extends State<TopicExtra> {
  final TextEditingController _newNameController = TextEditingController();

  @override
  dispose() {
    _newNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)?.settings.arguments as Map;
    Map text = routeData['text'];
    var theme = routeData['theme'];
    var topic = routeData['topic'];
    _newNameController.text = topic.name;

    //how we format our date
    DateFormat dateFormat = DateFormat('H:m\nE d/M/y');

    return Scaffold(
      backgroundColor: theme.primary,
      appBar: AppBar(
        foregroundColor: theme.secondaryText,
        title: Text(topic.name),
        elevation: 4,
        centerTitle: true,
        backgroundColor: theme.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //date created
                ListTile(
                  textColor: theme.primaryText,
                  leading: Icon(Icons.calendar_today, color: theme.accent),
                  title: Text(text['creationDate'], style: defaultPrimaryTextStyle()),
                  trailing: Text(
                    dateFormat.format(DateTime.parse(topic!.date)),
                    style: defaultPrimaryTextStyle(),
                  ),
                ),
                const SizedBox(height: 30),
                //rename class
                Text(
                  text['rename'],
                  style: TextStyle(
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newNameController,
                        cursorColor: theme.accent,
                        style: defaultSecondaryTextStyle(),
                        decoration: defaultSecondaryInputDecoration(
                          text['newName'],
                        ),
                      ),
                    ),
                    //note to self maybe remove old flip cards from list
                    IconButton(
                      onPressed: () async {
                        if (_newNameController.text.isNotEmpty) {
                          //go back to home page
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          await local.updateTopic(
                            topic,
                            routeData['class'],
                            routeData['structure'],
                            _newNameController.text,
                          );
                          //update again
                          Navigator.pushNamed(context, '/topics', arguments: routeData);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(defaultSnackbar(text['errorNoText']));
                        }
                      },
                      icon: Icon(Icons.check, color: theme.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                //delete class
                Row(
                  children: [
                    Text(
                      text['delete'],
                      style: TextStyle(
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.warning, color: theme.primaryText),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                coloredButton(
                  text['delete'],
                  () {
                    Alert(
                      context: context,
                      style: defaultAlertStyle(),
                      title: text['sure'] + ' ' + topic.name + '?',
                      buttons: [
                        coloredDialogButton(
                          text['confirm'],
                          context,
                          () async {
                            //go back to home page
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            await local.deleteTopic(
                              topic,
                              routeData['class'],
                              routeData['structure'],
                            );
                            //update again
                            Navigator.pushReplacementNamed(
                              context,
                              '/topics',
                              arguments: routeData,
                            );
                          },
                          theme.accent,
                          theme.accentText,
                        ),
                        coloredDialogButton(
                          text['cancel'],
                          context,
                          () => Navigator.pop(context),
                          theme.accent,
                          theme.accentText,
                        )
                      ],
                    ).show();
                  },
                  theme.accent,
                  theme.accentText,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
