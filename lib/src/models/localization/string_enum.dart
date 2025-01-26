// ignore_for_file: public_member_api_docs
part of 'app_translations.dart';

/// App text for different language
enum TextEnum {
  appName(en: 'Flutter Demo', bn: 'ফ্লাটার ডেমো'),
  // TODO: Add more entries as required
  ;

  const TextEnum({required String en, required String bn})
      : _en = en,
        _bn = bn;

  final String _en;
  final String _bn;

  String get tr => name.tr;
}
