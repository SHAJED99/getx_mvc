// ignore_for_file: public_member_api_docs

import 'package:get/get.dart';

/// App text for different language
enum TextEnum {
  appName(en: 'Flutter Demo', bn: 'ফ্লাটার ডেমো'),
  // TODO: Add more entries as required
  ;

  const TextEnum({required this.en, required this.bn});

  final String en;
  final String bn;

  String get tr => name.tr;
}
