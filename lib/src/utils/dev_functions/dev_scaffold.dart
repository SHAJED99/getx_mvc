import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';

import '../../models/localization/app_translations.dart';
import '../../models/theme/app_theme.dart';
import 'dev_button.dart';

const double _defaultPadding = 24.0;

/// Scaffold for development. Has EndDrawer with necessary development tools.
class DevScaffold extends StatefulWidget {
  /// Scaffold for development. Has EndDrawer with necessary development tools.
  const DevScaffold({
    super.key,
    required this.child,
    this.floatingActionButton,
  });

  /// Child widget. When in development mode it will be wrap a Scaffold with
  /// EndDrawer. This endDrawer have some development tools.
  /// Otherwise it will be directly return the child.
  final Widget child;

  /// Floating action button for the Scaffold. It will be shown in the
  /// development. Necessary for providing auto input (Like: Login credential)
  /// for the development.
  ///
  /// Example:
  ///
  ///     List<Function> get devFunctions {
  ///       return [
  ///         () {
  ///           emailTextController.text = "email@gmail.com";
  ///           passwordTextController.text = "password";
  ///         }
  ///       ];
  ///     }
  ///
  /// Usages:
  ///
  ///     DevScaffold(
  ///       floatingActionButton: DevAutoFillButton(onPressed: devFunctions),
  ///       ...
  ///     )
  final Widget? floatingActionButton;

  @override
  State<DevScaffold> createState() => _DevScaffoldState();
}

class _DevScaffoldState extends State<DevScaffold> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _onPress(String text, Function onTap) {
    return OnProcessButtonWidget(
      margin: const EdgeInsets.symmetric(vertical: _defaultPadding / 4),
      onDone: (bool? isSuccess) => onTap,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return Scaffold(
        key: _key,
        body: widget.child,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (kIsWeb)
              DevButton(
                onTap: () async {
                  _key.currentState?.openEndDrawer();
                  return;
                },
                child: const Text('EndDrawer'),
              ),
            if (widget.floatingActionButton != null)
              widget.floatingActionButton!,
          ],
        ),
        endDrawer: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(_defaultPadding),
          margin: const EdgeInsets.only(left: _defaultPadding),
          child: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).padding.top),
              //! ------------------------------------------------------- Locale
              for (final Locale locale in AppTranslations.supportedLocales)
                _onPress(
                  'Change Language ${locale.languageCode}',
                  () async => await AppTranslations.update(locale: locale),
                ),

              //! -------------------------------------------------------- Theme
              for (final ThemeMode themeMode in ThemeMode.values)
                _onPress(
                  'Change Theme - $themeMode',
                  () => AppTheme.update(themeMode: themeMode),
                ),

              //! ----------------------------------------- Additional functions
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
