import 'package:toml/toml.dart';
import 'package:flutter/services.dart';

Future<Map?> readText(String section) async {
  String lang = 'en';
  var text = TomlDocument.parse(await rootBundle.loadString('text/$lang.toml'))
      .toMap();
  return text[section];
}
