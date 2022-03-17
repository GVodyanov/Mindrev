import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/models/mindrev_material.dart';
import 'package:mindrev/pages/home/home.dart';
import 'package:mindrev/pages/home/new_class.dart';
import 'package:mindrev/pages/home/settings.dart';
import 'package:mindrev/pages/topics/topics.dart';
import 'package:mindrev/pages/topics/new_topic.dart';
import 'package:mindrev/pages/materials/materials.dart';
import 'package:mindrev/pages/materials/new_material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';

//main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //hive
  if (Platform.isLinux) {
    var dir = await getApplicationSupportDirectory();
    Hive.init(dir.path);
  } else {
    await Hive.initFlutter();
  }
  //register adapters
  Hive.registerAdapter(MindrevClassAdapter());
  Hive.registerAdapter(MindrevTopicAdapter());
  Hive.registerAdapter(MindrevMaterialAdapter());

  //open box
  await Hive.openLazyBox('mindrev');

  await getTheme();

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      //routes for navigation
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
        '/newClass': (context) => const NewClass(),
        '/settings': (context) => const Settings(),
        '/topics': (context) => const Topics(),
        '/newTopic': (context) => const NewTopic(),
        '/materials': (context) => const Materials(),
        '/newMaterial': (context) => const NewMaterial(),
      },
    ),
  );
}
