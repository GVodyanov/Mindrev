import 'package:flutter/material.dart';
import 'package:mindrev/pages/home/home.dart';
import 'package:mindrev/pages/home/new_class.dart';
import 'package:mindrev/pages/topics/topics.dart';
import 'package:mindrev/pages/topics/new_topic.dart';
import 'package:mindrev/pages/materials/materials.dart';
import 'package:mindrev/pages/materials/new_material.dart';

//main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    //routes for navigation
    initialRoute: '/home',
    routes: {
      '/home': (context) => const Home(),
      '/newClass': (context) => const NewClass(),
      '/topics': (context) => const Topics(),
      '/newTopic': (context) => const NewTopic(),
      '/materials': (context) => const Materials(),
      '/newMaterial': (context) => const NewMaterial(),
    },
  ));
}
