import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getx_mvc/src/controllers/data_controllers/auth_controller.dart';

import 'components.dart';
import 'src/controllers/data_controllers/app_data_controller.dart';
import 'src/models/environment_model/environment_model.dart';
import 'src/models/localization/app_translations.dart';
import 'src/models/theme/app_theme.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  //! ------------------------------------------------ App supported orientation
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );

  //! -------------------------------------------- Initializing Environment data
  await EnvironmentModel.init;

  //! -------------------------------------------------- Initializing local data
  Locale locale = await AppTranslations.init;
  ThemeMode themeMode = await AppTheme.init;

  Widget app = _MyApp(
    locale: locale,
    themeMode: themeMode,
  );

  runApp(DevicePreview(enabled: !kReleaseMode, builder: (_) => app));
}

class _MyApp extends StatelessWidget {
  const _MyApp({
    required this.locale,
    required this.themeMode,
  });

  final Locale locale;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      fontSizeResolver: (num fontSize, _) => fontSize.toDouble(),
      ensureScreenSize: true,
      designSize: defaultBaseScreenSize,
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) => GetMaterialApp(
        theme: AppTheme.theme(context),
        darkTheme: AppTheme.theme(context, brightness: Brightness.dark),
        themeMode: themeMode,
        locale: locale,
        fallbackLocale: AppTranslations.supportedLocales.first,
        translations: AppTranslations(),
        debugShowCheckedModeBanner: false,
        initialBinding: _InitializedBinding(),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: <PointerDeviceKind>{
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        home: child!,
        builder: (BuildContext context, Widget? child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.setSafeAreaColor(context),
            child: child!,
          );
        },
      ),
      child: const Scaffold(),
    );
  }
}

/// App Initialize binding
class _InitializedBinding extends Bindings {
  /// App Initialize binding
  _InitializedBinding();

  @override
  void dependencies() {
    Get.put(AppDataController());
    Get.put(AuthController());
  }
}
