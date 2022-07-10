import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:mindrev/widgets/widgets.dart';

import 'package:download/download.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> export (String name, String type, Map content, context, String find) async {

  Map mainMap = {'type' : type, 'content' : content};
  String mainString = jsonEncode(mainMap);

  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    Directory? downloadDir = await getDownloadsDirectory();

    File file = File('${downloadDir?.path}/$name.mr');
    file.writeAsString(mainString);

    ScaffoldMessenger.of(context).showSnackBar(defaultSnackbar('$find ${downloadDir?.path}/$name.mr'));
  } else if (kIsWeb) {
    final stream = Stream.fromIterable(mainString.codeUnits);
    download(stream, '$name.mr');
  } else if (Platform.isAndroid) { //android and iOS
    Directory? downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) downloadDir = await getExternalStorageDirectory();

    File file = File('${downloadDir?.path}/$name.mr');
    file.writeAsString(mainString);

    ScaffoldMessenger.of(context).showSnackBar(defaultSnackbar('$find ${downloadDir?.path}/$name.mr'));
  } else if (Platform.isIOS) {
    Directory? downloadDir = await getApplicationDocumentsDirectory();

    File file = File('${downloadDir.path}/$name.mr');
    file.writeAsString(mainString);

    ScaffoldMessenger.of(context).showSnackBar(defaultSnackbar('$find ${downloadDir.path}/$name.mr'));
  }
  return true;
}