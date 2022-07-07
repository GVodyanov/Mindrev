import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/models/mindrev_structure.dart';
import 'package:mindrev/models/mindrev_class.dart';
import 'package:mindrev/models/mindrev_topic.dart';
import 'package:mindrev/models/mindrev_material.dart';
import 'package:mindrev/models/mindrev_settings.dart';
import 'package:mindrev/models/mindrev_flashcards.dart';
import 'package:mindrev/models/mindrev_notes.dart';
import 'package:mindrev/pages/home/home.dart';
import 'package:mindrev/pages/home/new_class.dart';
import 'package:mindrev/pages/home/settings.dart';
import 'package:mindrev/pages/topics/topics.dart';
import 'package:mindrev/pages/topics/new_topic.dart';
import 'package:mindrev/pages/topics/class_extra.dart';
import 'package:mindrev/pages/materials/materials.dart';
import 'package:mindrev/pages/materials/new_material.dart';
import 'package:mindrev/pages/materials/topic_extra.dart';
import 'package:mindrev/pages/materials/material_extra.dart';
import 'package:mindrev/pages/flashcards/flashcards.dart';
import 'package:mindrev/pages/flashcards/new_flashcards.dart';
import 'package:mindrev/pages/flashcards/learn_flashcards.dart';
import 'package:mindrev/pages/flashcards/practice_flashcards.dart';
import 'package:mindrev/pages/flashcards/quiz_flashcards.dart';
import 'package:mindrev/pages/flashcards/bulk_import.dart';
import 'package:mindrev/pages/notes/markdown_editor.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:page_transition/page_transition.dart';


///TODO general import
///TODO rename path of web images when renaming higher path

//main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.linux) {
    try {
      var dir = await getApplicationSupportDirectory();
      Hive.init(dir.path);
      // ignore: empty_catches
    } catch (e) {}
  } else {
    await Hive.initFlutter();
  }
  //register adapters
  Hive.registerAdapter(MindrevStructureAdapter());
  Hive.registerAdapter(MindrevClassAdapter());
  Hive.registerAdapter(MindrevTopicAdapter());
  Hive.registerAdapter(MindrevMaterialAdapter());
  Hive.registerAdapter(MindrevSettingsAdapter());
  Hive.registerAdapter(MindrevFlashcardsAdapter());
  Hive.registerAdapter(MindrevNotesAdapter());

  //open box
  await Hive.openLazyBox('mindrev');

  await getTheme();

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'SourceSansPro',
      ),
      //custom routes
      onGenerateRoute: (settings) {
        Widget widget = const Home();
        switch (settings.name) {
          case '/home':
            widget = const Home();
            break;
          case '/newClass':
            widget = const NewClass();
            break;
          case '/settings':
            widget = const Settings();
            break;
          case '/topics':
            widget = const Topics();
            break;
          case '/newTopic':
            widget = const NewTopic();
            break;
          case '/classExtra':
            widget = const ClassExtra();
            break;
          case '/materials':
            widget = const Materials();
            break;
          case '/newMaterial':
            widget = const NewMaterial();
            break;
          case '/topicExtra':
            widget = const TopicExtra();
            break;
          case '/materialExtra':
            widget = const MaterialExtra();
            break;
          case '/flashcards':
            widget = const Flashcards();
            break;
          case '/newFlashcards':
            widget = const NewFlashcards();
            break;
          case '/learnFlashcards':
            widget = const LearnFlashcards();
            break;
          case '/practiceFlashcards':
            widget = const PracticeFlashcards();
            break;
          case '/quizFlashcards':
            widget = const QuizFlashcards();
            break;
          case '/bulkImport':
            widget = const BulkImport();
            break;
          case '/notes':
            widget = const MarkdownEditor();
            break;
        }
        List<String> specialTransitionList = [
          '/topics',
          '/materials',
          '/notes',
          '/flashcards',
        ];
        if (specialTransitionList.contains(settings.name)) {
          return PageTransition(
            child: widget,
            type: PageTransitionType.rightToLeft,
            settings: settings,
            duration: const Duration(milliseconds: 150),
          );
        } else {
          return PageTransition(
            child: widget,
            type: PageTransitionType.fade,
            settings: settings,
            duration: const Duration(milliseconds: 150),
          );
        }
      },
      initialRoute: '/home',
    ),
  );
}
