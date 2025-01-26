import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../utils/dev_functions/dev_print.dart';
import 'string_enum.dart';

class AppTranslations extends Translations {
  static const String _localeKey = 'AppTranslations_locale';
  static final GetStorage _storage = GetStorage();

  /// Supported language for app
  // TODO: Add language
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
  ];

  /// Finds and returns a [Locale] that matches the given [languageCode].
  ///
  /// If the [languageCode] matches any locale in [supportedLocales], it returns
  /// the matching [Locale]. Otherwise, it returns the first [Locale].
  static Locale getLocaleFromLanguageCode(String languageCode) {
    return supportedLocales.firstWhere(
      (Locale locale) => locale.languageCode == languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  @override
  Map<String, Map<String, String>> get keys {
    return <String, Map<String, String>>{
      // TODO: Add language
      'en': _generateTranslations((TextEnum e) => e.en),
      'bn': _generateTranslations((TextEnum e) => e.bn),
    };
  }

  static Map<String, String> _generateTranslations(
    String Function(TextEnum) translationMapper,
  ) {
    return Map<String, String>.fromEntries(
      TextEnum.values.map(
        (TextEnum e) => MapEntry<String, String>(e.name, translationMapper(e)),
      ),
    );
  }

  /// Load preset locale from local data when the app is starting
  static Future<Locale> get loadLocalData async {
    await GetStorage.init();
    Locale? result;

    try {
      final String? localCode = _storage.read<String>(_localeKey);

      if (localCode == null) throw Exception('No locale found.');

      for (final Locale local in supportedLocales) {
        if (local.languageCode == localCode) {
          result = local;
          break;
        }
      }

      if (result == null) throw Exception('Locale encrypted.');
    } catch (e) {
      devPrint(
        '''AppTranslations: Unable to load locale date. Reset Locale. Error: $e''',
      );

      result = supportedLocales.first;
      _setData(result);
    }

    return result;
  }

  /// Used to update the locale
  static Future<void> update({required Locale locale}) async {
    await _setData(locale);
    Get.updateLocale(locale);
  }

  static Future<void> _setData(Locale locale) async {
    await _storage.write(_localeKey, locale.languageCode);
    devPrint('AppTranslations: Locale set to ${locale.languageCode}.');
  }
}
