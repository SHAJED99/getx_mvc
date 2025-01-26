import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/dev_functions/dev_print.dart';

part 'colors.dart';
part 'text_styles.dart';

/// App theme data. Always try to
class AppTheme {
  static const String _localeKey = 'AppTheme_theme';
  static final GetStorage _storage = GetStorage();

  /// Load preset brightness from local data when the app is starting
  static Future<void> get loadLocalData async {
    await GetStorage.init();
    bool? isDarkMode;

    try {
      isDarkMode = _storage.read<bool>(_localeKey);
    } catch (e) {
      devPrint(
        '''AppTheme: Unable to load locale date. Reset Locale. Error: $e''',
      );
    }

    await update(isDarkMode: isDarkMode);
  }

  /// Used to update the locale
  static Future<void> update({bool? isDarkMode}) async {
    await _setData(isDarkMode);

    if (isDarkMode == null) {
      Get.changeThemeMode(ThemeMode.system);
    } else {
      Get.changeThemeMode(
        isDarkMode ? ThemeMode.light : ThemeMode.dark,
      );
    }
  }

  static Future<void> _setData(bool? isDarkMode) async {
    await _storage.write(_localeKey, isDarkMode);
    devPrint(
      '''AppTheme: Theme brightness set to ${isDarkMode == null ? 'System' : isDarkMode ? Brightness.light : Brightness.dark}.''',
    );
  }
}
