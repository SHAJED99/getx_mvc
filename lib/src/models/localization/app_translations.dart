import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../utils/dev_functions/dev_print.dart';

part 'string_enum.dart';

/// App localization
class AppTranslations extends Translations {
  static bool _isInit = false;
  static const String _localeKey = 'AppTranslations_locale';
  static final GetStorage _storage = GetStorage();

  /// Supported language for app
  // TODO: Add language
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
  ];

  @override
  Map<String, Map<String, String>> get keys {
    return <String, Map<String, String>>{
      // TODO: Add language
      'en': _generateTranslations((TextEnum e) => e._en),
      'bn': _generateTranslations((TextEnum e) => e._bn),
    };
  }

  static Future<void> get ____init async {
    if (_isInit) return;
    await GetStorage.init();
    _isInit = true;
  }

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
    await ____init;
    Locale? result;

    try {
      final String? localCode = _storage.read<String>(_localeKey);

      if (localCode == null) throw Exception('No locale found.');

      for (final Locale locale in supportedLocales) {
        if (locale.languageCode == localCode) {
          result = locale;
          break;
        }
      }

      if (result == null) throw Exception('Locale encrypted.');
    } catch (e) {
      devPrint(
        'AppTranslations: Unable to load local date. Reset Local Data. $e',
        color: DevPrintColorEnum.red,
      );

      result = supportedLocales.first;
      _saveData(result);
    }
    devPrint(
      'AppTranslations: Locale set to ${result.languageCode}.',
      color: DevPrintColorEnum.green,
    );
    return result;
  }

  /// Used to update the locale
  static Future<void> update({required Locale locale}) async {
    await _saveData(locale);
    Get.updateLocale(locale);
  }

  static Future<void> _saveData(Locale locale) async {
    await ____init;
    await _storage.write(_localeKey, locale.languageCode);
    devPrint(
      'AppTranslations: Locale saved to ${locale.languageCode}.',
      color: DevPrintColorEnum.green,
    );
  }
}
