import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/dev_functions/dev_print.dart';

part 'colors.dart';
part 'text_styles.dart';

/// App theme data. Always try to
class AppTheme {
  static bool _isInit = false;
  static const String _localeKey = 'AppTheme_theme';
  static final GetStorage _storage = GetStorage();

  static Future<void> get ____init async {
    if (_isInit) return;
    await GetStorage.init();
    _isInit = true;
  }

  /// Load preset brightness from local data when the app is starting
  static Future<ThemeMode> get loadLocalData async {
    await ____init;
    bool? isDarkMode;

    try {
      isDarkMode = _storage.read<bool>(_localeKey);
    } catch (e) {
      devPrint(
        'AppTheme: Unable to load local date. Reset Local Data. $e',
        color: DevPrintColorEnum.red,
      );
    }

    await update(isDarkMode: isDarkMode);
    return _getThemeMode(isDarkMode);
  }

  /// Used to update the locale
  static Future<void> update({bool? isDarkMode}) async {
    await _saveData(isDarkMode);
    Get.changeThemeMode(_getThemeMode(isDarkMode));
  }

  static ThemeMode _getThemeMode(bool? isDarkMode) {
    if (isDarkMode == null) return ThemeMode.system;

    return isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> _saveData(bool? isDarkMode) async {
    await ____init;
    await _storage.write(_localeKey, isDarkMode);
    devPrint(
      '''AppTheme: Theme brightness saved to ${isDarkMode == null ? 'System' : isDarkMode ? Brightness.light : Brightness.dark}.''',
      color: DevPrintColorEnum.green,
    );
  }

  /// Set safe area color
  static SystemUiOverlayStyle setSafeAreaColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
      );
    } else {
      return SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
      );
    }
  }

  /// Get App theme
  static ThemeData theme(
    BuildContext context, {
    Brightness brightness = Brightness.light,
  }) {
    return ThemeData(
      textTheme: AppTextStyles._textTheme(context),
      colorScheme: brightness == Brightness.light
          ? AppColors._lightScheme
          : AppColors._darkScheme,
    );
  }
}
