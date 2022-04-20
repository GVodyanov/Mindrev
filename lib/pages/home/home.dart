import 'package:flutter/material.dart';

import 'package:mindrev/models/mindrev_structure.dart';
import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/pages/home/about.dart';

import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MindrevStructure? structure; //structure that contains all classes
  MindrevSettings? settings; //settings for uiColors route argument

  //different texts we need for different sections
  Map? text;
  Map? sidebar;
  Map? about;

  @override
  initState() {
    super.initState();
    //wait for our async functions and then setState
    Future.wait([
      local.getStructure(),
      local.getSettings(),
      readText('home'),
      readText('sidebar'),
      readText('about'),
    ]).then(
      (value) => setState(() {
        structure = value[0] as MindrevStructure?;
        settings = value[1] as MindrevSettings?;
        text = value[2] as Map?;
        sidebar = value[3] as Map?;
        about = value[4] as Map?;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (structure != null) {
      return Scaffold(
        backgroundColor: theme.primary,

        //appbar
        appBar: AppBar(
          foregroundColor: theme.secondaryText,
          title: Text(
            'Mindrev',
            style: TextStyle(
              color: theme.accent,
              fontSize: 24,
            ),
          ),
          elevation: 4,
          centerTitle: true,
          backgroundColor: theme.secondary,
        ),

        //button to add new class
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(
            Icons.add,
            color: theme.accentText,
          ),
          label: Text(
            text?['new'],
            style: TextStyle(color: theme.accentText, fontSize: 14),
          ),
          backgroundColor: theme.accent,
          onPressed: () => Navigator.pushNamed(
            context,
            '/newClass',
            arguments: {'text': text?['newClass']},
          ),
        ),

        //drawer with navigation menu
        drawer: Drawer(
          backgroundColor: theme.secondary,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: theme.secondary,
                    ),
                    child: SvgPicture.asset('assets/logo.svg', color: theme.accent),
                  ),
                  ListTile(
                    title: Text(sidebar?['home'], style: defaultSecondaryTextStyle()),
                    leading: Icon(Icons.home, color: theme.secondaryText),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(sidebar?['settings'], style: defaultSecondaryTextStyle()),
                    leading: Icon(Icons.settings, color: theme.secondaryText),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    title: Text(sidebar?['help'], style: defaultSecondaryTextStyle()),
                    leading: Icon(Icons.help, color: theme.secondaryText),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(sidebar?['about'], style: defaultSecondaryTextStyle()),
                    leading: Icon(Icons.info, color: theme.secondaryText),
                    onTap: () {
                      showAbout(about!, context);
                    },
                  ),
                  const Divider(endIndent: 5, indent: 5),
                  ListTile(
                    leading: Icon(Icons.close, color: theme.secondaryText),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        ),

        //body with everything
        body: SingleChildScrollView(
          child: Center(
            //check if there are any classes, and if there are display them
            child: structure!.classes.isNotEmpty
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          for (Widget i in structure!.displayClasses(
                            context,
                            structure!,
                            settings!.uiColors,
                          ))
                            i
                        ],
                      ).toList(),
                    ),
                  )
                : empty(text?['create']),
          ),
        ),
      );
    } else {
      return loading();
    }
  }
}
