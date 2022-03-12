import 'package:flutter/material.dart';

import 'package:mindrev/services/text.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //futures that will be awaited by FutureBuilder
  Future futureText = readText('settings');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureText,
      builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
        //only show page when data is loaded
        if (snapshot.hasData) {
          //data loaded with FutureBuilder
          Map text = snapshot.data;

          return Scaffold(
            //appbar
            appBar: AppBar(
              foregroundColor: theme.secondaryText,
              title: Text(text['title']),
              centerTitle: true,
              elevation: 10,
              backgroundColor: theme.secondary,
            ),

            //button to save
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(
                Icons.save,
              ),
              label: Text(
                text['save'],
              ),
              foregroundColor: theme.accentText,
              backgroundColor: theme.accent,
              onPressed: () {},
            ),

            //body with everything
            body: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text['ui'],
                          style: TextStyle(color: theme.primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(text['uiColors'], style: defaultPrimaryTextStyle),
                          leading: Icon(Icons.palette, color: theme.accent),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: theme.accent,
                          ),
                      	)
                      ],
                    ),
                  ),
                ),
              ),
            ),),
          );
        } else {
          return Scaffold(
            //loading screen to be shown until Future is found
            body: loading,
          );
        }
      },
    );
  }
}
