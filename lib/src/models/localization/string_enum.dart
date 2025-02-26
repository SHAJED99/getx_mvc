// ignore_for_file: public_member_api_docs
part of 'app_translations.dart';

/// App text for different language
enum TextEnum {
  version(en: 'Version', bn: 'সংস্করণ'),
  // TODO: Add more entries as required
  ;

  const TextEnum({required String en, String? bn})
      : _en = en,
        _bn = bn ?? en;

  final String _en;
  final String _bn;

  String get tr => name.tr;
}
