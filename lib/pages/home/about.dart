import 'package:flutter/material.dart';

import 'package:mindrev/widgets/widgets.dart';
import 'package:mindrev/extra/theme.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_svg/flutter_svg.dart';

//simple function that displays an alert with about information, to be used in home.dart
void showAbout (Map text, var context) {
  Alert(
    context: context,
    style: defaultAlertStyle(),
    title: text['title'],
    content: Column (
      mainAxisAlignment: MainAxisAlignment.center,
			children: [
				const SizedBox(height: 20),
        SvgPicture.asset('assets/logo.svg', color: theme.accent, width: 80),
        Text(
          'Mindrev',
          style: TextStyle(
            color: theme.accent,
            fontSize: 24,
          ),
        ),
        ListTile(
					title: Text(text['version'], style: defaultSecondaryTextStyle()),
					trailing: Text(text['versionNumber'], style: defaultSecondaryTextStyle()),
				),
        ListTile(
					title: Text(text['author'], style: defaultSecondaryTextStyle()),
					trailing: Text('ScratchX98', style: defaultSecondaryTextStyle()),
				),
        ListTile(
					title: Text(text['source'], style: defaultSecondaryTextStyle()),
					trailing: SelectableLinkify(text: 'https://github.com/ScratchX98/Mindrev', options: const LinkifyOptions(humanize: true), style: defaultSecondaryTextStyle(),),
				),
        ListTile(
					title: Text(text['license'], style: defaultSecondaryTextStyle()),
					trailing: Text('AGPLv3 + Common clause', style: defaultSecondaryTextStyle()),
				),
			],
    ),
    buttons: [
      defaultDialogButton(text['close'], context, (){Navigator.pop(context);}),
    ],
  ).show();
}

