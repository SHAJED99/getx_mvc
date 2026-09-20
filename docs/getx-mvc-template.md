---
name: getx-mvc-template
description: >-
  How to build features in this GetX MVC Flutter template: the screen/controller/use-case/repository
  part-file pattern, HTTP calls through HttpRepository, enum-based translations, the theming system
  (color schemes, dark mode, fonts, text scale), and the Custom* widget kit. Use this skill whenever
  you are adding or changing a screen, controller, API call, validator, translated string, color,
  font, theme, or widget anywhere under `lib/`, even when the request sounds
  like ordinary Flutter or GetX work. This codebase deliberately departs from conventional GetX
  layouts (no named routes, no Bindings list, private classes in `part` files), so writing idiomatic
  GetX here produces code that does not compile or does not match the surrounding architecture.
---

# Working in the GetX MVC template

This repository is a Flutter boilerplate built on GetX. Its layout looks conventional from the
directory names but is not: screens, controllers, use cases, and repositories are bound together
into a single Dart library using `part`/`part of`, and almost every feature class is private.

Read this before writing code. The single most common failure mode is generating textbook GetX
(named routes, `Bindings` classes, public `HomeController` in its own file with its own imports) —
none of which matches this project and some of which will not compile here.

## Orientation

Do not trust `README.md`. Its "Project Structure" section describes an aspirational layout
(`app/`, `data/`, `domain/`, `presentation/`, `GetPage` route tables) that does not exist in the
code. `CLAUDE.md` at the repo root and this file describe what is actually implemented.

Actual layout under `lib/`:

```
lib/
├── components.dart                  # app-wide constants (spacing, durations, app name)
└── src/
    ├── controllers/
    │   ├── data_controllers/        # global singletons (AuthController, AppDataController)
    │   └── screen_controllers/      # per-screen private controllers, as `part` files
    ├── core/
    │   ├── environment/             # .env loading
    │   ├── http/                    # HttpRepository + private client/error handler
    │   ├── localization/            # AppTranslations + TextEnum
    │   ├── theme/                   # AppTheme + colors + text styles
    │   └── use_case/                # BaseUseCase (GetStorage key/value helpers)
    ├── models/data/app_models/      # UserModel and friends
    ├── utils/
    │   ├── dev_functions/           # devPrint, DevScaffold (debug-only)
    │   ├── functions/               # validators, string extensions
    │   └── user_message/            # snackbar/toast
    └── views/
        ├── screens/<feature>/       # the screen file owns the whole feature library
        └── widgets/                 # Custom* shared widget kit
```

## The mental model

A feature is **one Dart library** made of four files. The screen file is the library head; the
controller, use case, and repository are `part` files of it.

```
View (screen file, public)
  └─> _Controller   UI state: .obs fields, form keys, TextEditingControllers
        └─> _UseCase    business rules; writes shared state (e.g. AuthController.find.user)
              └─> _Repository   extends HttpRepository; performs the actual API call
```

Why it is built this way: bundling the layers into one library lets every class stay private
(`_`-prefixed) so a feature cannot leak into other features, while still splitting the code across
readable files. The tradeoff you must respect is that **`part` files cannot declare their own
imports** — every import for the whole feature lives in the screen file.

Two kinds of controllers exist, and conflating them is a real bug:

- **Data controllers** (`lib/src/controllers/data_controllers/`) are public, app-wide singletons
  registered once in `_InitializedBinding` in `main.dart` and never deleted. `AuthController.user`
  is the single source of truth for the session: assigning `null` logs the user out and navigates
  to the splash screen; assigning a value persists it.
- **Screen controllers** are private, created with `Get.put` in the screen's `State` and removed
  with `Get.delete` in `dispose()`.

## Recipe: add a new screen

Follow the `authentication` feature as the reference implementation. Create four files.

**1. The screen file** — `lib/src/views/screens/profile/profile_wrapper_screen.dart`

This file owns all imports for the feature and declares the `part` directives.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;          // repositories need the `dio` alias

import '../../../../components.dart';
import '../../../controllers/data_controllers/auth_controller.dart';
import '../../../core/http/http_repository.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/use_case/use_case.dart';
import '../../../models/data/app_models/user_model.dart';
import '../../../utils/dev_functions/dev_scaffold.dart';
import '../../widgets/text.dart';

part '../../../controllers/screen_controllers/profile/controller.dart';
part '../../../controllers/screen_controllers/profile/repository.dart';
part '../../../controllers/screen_controllers/profile/use_case.dart';

/// Profile Wrapper Screen
class ProfileWrapperScreen extends StatefulWidget {
  /// Profile Wrapper Screen
  const ProfileWrapperScreen({super.key});

  @override
  State<ProfileWrapperScreen> createState() => _ProfileWrapperScreenState();
}

class _ProfileWrapperScreenState extends State<ProfileWrapperScreen> {
  final _ProfileScreenController _controller =
      Get.put(_ProfileScreenController());

  @override
  void dispose() {
    super.dispose();
    Get.delete<_ProfileScreenController>();
  }

  @override
  Widget build(BuildContext context) {
    return DevScaffold(
      child: Scaffold(
        body: SafeArea(
          child: Obx(
            () => CustomTextBody(text: _controller.title.value),
          ),
        ),
      ),
    );
  }
}
```

Wrap the real `Scaffold` in `DevScaffold`. In release builds it is a passthrough; in debug it adds
an end-drawer for switching theme/locale and logging out.

**2. The controller** — `lib/src/controllers/screen_controllers/profile/controller.dart`

```dart
// ignore_for_file: public_member_api_docs

part of '../../../views/screens/profile/profile_wrapper_screen.dart';

/// Handles the profile screen
class _ProfileScreenController extends GetxController {
  /// Get [_ProfileScreenController] GetxController
  static _ProfileScreenController get find => Get.find();

  final RxString title = ''.obs;
  final TextEditingController nameC = TextEditingController();

  final _ProfileScreenUseCase _useCase = _ProfileScreenUseCase();

  @override
  void onClose() {
    super.onClose();
    nameC.dispose();
  }

  Future<bool> load() => _useCase.load();
}
```

The `static ... get find => Get.find();` getter is how nested private widgets in the screen file
reach the controller without prop-drilling. Dispose every `TextEditingController` in `onClose`.

The `// ignore_for_file: public_member_api_docs` line is conventional here because the analyzer
still demands doc comments on members of private classes.

**3. The use case** — `lib/src/controllers/screen_controllers/profile/use_case.dart`

```dart
part of '../../../views/screens/profile/profile_wrapper_screen.dart';

/// Handles profile screen business rules
class _ProfileScreenUseCase extends BaseUseCase {
  final _ProfileScreenRepository _repository = _ProfileScreenRepository();

  Future<bool> load() async {
    final UserModel? result = await _repository.load();
    if (result == null) return false;

    AuthController.find.user.value = result;
    return true;
  }
}
```

Extend `BaseUseCase` when the feature needs simple local persistence; it exposes static
`saveData({key, value})` and `readData({key})` over `GetStorage`.

**4. The repository** — `lib/src/controllers/screen_controllers/profile/repository.dart`

See the HTTP recipe below.

**5. Navigate to it.** There is no route table. Push the widget directly:

```dart
Get.to(() => const ProfileWrapperScreen());      // push
Get.offAll(() => const ProfileWrapperScreen());  // replace the stack
```

## Recipe: call an API

Extend `HttpRepository` to inherit `httpClient` and `errorHandler`. Wrap the request in
`errorHandler.errorHandler(...)`, throw the response on a non-success status, and return `null` on
failure — callers check for `null` rather than catching exceptions.

```dart
part of '../../../views/screens/profile/profile_wrapper_screen.dart';

class _ProfileScreenRepository extends HttpRepository {
  /// [load]
  Future<UserModel?> load() async {
    UserModel? result;

    await errorHandler.errorHandler(
      function: () async {
        final String url = 'user/me';
        final dio.Response<Map<String, dynamic>> response =
            await httpClient.get(url);

        if (response.statusCode != 200 || response.data == null) {
          throw response;
        }

        result = UserModel.fromMap(response.data!);
      },
    );

    return result;
  }
}
```

What `errorHandler` does for you, so you do not reimplement it: maps `DioException`, `TypeError`,
`FormatException`, and thrown `Response` objects onto `HTTPErrorEnum`; shows an error snackbar
(pass `showError: false` to suppress); logs via `devPrint`; and **logs the user out automatically
on a 401** by nulling `AuthController.find.user`.

`httpClient.get`/`post` already attach the bearer token from `AuthController`, prepend
`Environment.apiBaseUrl`, set a 30s timeout, and log the request and response. Do not build a
`Dio` instance yourself.

Add new failure categories to `HTTPErrorEnum` (`lib/src/core/http/http_error_enum.dart`) rather
than returning bare strings.

## Recipe: add user-facing text

Never hardcode display strings. Add a value to `TextEnum` in
`lib/src/core/localization/string_enum.dart` with a translation for every supported locale:

```dart
  /// Edit profile
  editProfile(
    en: 'Edit profile',
    bn: 'প্রোফাইল সম্পাদনা করুন',
  ),
```

Reference it as `TextEnum.editProfile.tr` — the enum exposes `String get tr => name.tr;`, so
`AppTranslations` picks new values up automatically.

Only `en` is required by the constructor (`String? bn` falls back to `en`), so omitting a
translation silently ships English rather than breaking the build. Adding a whole language means
adding a `Locale` to `AppTranslations.supportedLocales`, a matching branch in `keys`, and a field on
`TextEnum`; declare that field `required` if you want missing translations to be a compile error.
Search for `// TODO: Add language`.

## Theming

`lib/src/core/theme/app_theme.dart` is a library head with two `part` files, mirroring the feature
pattern:

```
app_theme.dart      # AppTheme: lifecycle, persistence, ThemeData assembly
├── colors.dart     # AppColors._lightScheme / _darkScheme (full Material 3 ColorScheme)
└── text_styles.dart# AppTextStyles._textTheme(context)
```

`AppColors._lightScheme`, `AppColors._darkScheme`, and `AppTextStyles._textTheme` are **private to
that library**. You cannot reach them from a widget — attempting `AppColors._lightScheme` will not
compile outside `app_theme.dart`. Widgets read the resolved theme through `Theme.of(context)`
instead, which is the point: there is exactly one path to a color.

**Lifecycle.** `main.dart` awaits `AppTheme.init`, which reads the persisted `ThemeMode` from
`GetStorage` (key `AppTheme_theme`, defaulting to `ThemeMode.system`) and hands it to
`GetMaterialApp`. `AppTheme.theme(context)` and `AppTheme.theme(context, brightness:
Brightness.dark)` build the light and dark `ThemeData`, each combining `AppTextStyles._textTheme`,
a `buttonTheme` whose height is `defaultButtonHeight`, and the matching `ColorScheme`.

**Switching the theme at runtime** — persists the choice and rebuilds:

```dart
await AppTheme.update(themeMode: ThemeMode.dark);
```

Do not call `Get.changeThemeMode` directly; `AppTheme.update` does that *and* writes the choice to
storage, so bypassing it means the theme resets on next launch. The debug end-drawer in
`DevScaffold` uses this to offer one button per `ThemeMode`.

**Consuming the theme in widgets:**

```dart
final ThemeData theme = Theme.of(context);
final Color primary = theme.colorScheme.primary;
final TextStyle? title = theme.textTheme.titleMedium;
final double buttonHeight = theme.buttonTheme.height;   // == defaultButtonHeight
```

Never hardcode `Color(0xff...)` in a widget. If a color is missing, add it to the `ColorScheme` in
`colors.dart` rather than inlining it — otherwise it will not adapt to dark mode.

**Changing the palette.** Both schemes are generated from the
[Material Theme Builder](https://material-foundation.github.io/material-theme-builder/). Regenerate
or hand-edit `_lightScheme` and `_darkScheme` **in tandem** — editing only one leaves the other
theme visibly wrong, and nothing in the analyzer will catch it.

**Changing fonts.** `AppTextStyles._textTheme` starts from `Theme.of(context).textTheme` scaled by
`fontSizeFactor: 1.sp`, then wraps it in `GoogleFonts.poppinsTextTheme`. It deliberately builds two
themes — `bodyTextTheme` and `displayTextTheme` — and merges the body/label slots from the first
into the second. Both currently use Poppins; to pair two typefaces, swap the `GoogleFonts` call for
one of them and the split does the rest.

**System bars.** `AppTheme.setSafeAreaColor(context)` returns a `SystemUiOverlayStyle` with
transparent status and navigation bars and brightness-appropriate icons. `main.dart` already applies
it app-wide through an `AnnotatedRegion` in the `GetMaterialApp` builder, so individual screens do
not need to.

## Text, widgets, and layout

The `Custom*` text widgets in `lib/src/views/widgets/text.dart` are the intended way to render text
— they wire the text theme and color scheme together so you never pass a raw `TextStyle`. Five
families map onto the Material text scale, each with three constructors:

| Widget | default | `.L` | `.S` |
|---|---|---|---|
| `CustomTextDisplay` | `displayMedium` | `displayLarge` | `displaySmall` |
| `CustomTextHeading` | `headlineMedium` | `headlineLarge` | `headlineSmall` |
| `CustomTextTitle` | `titleMedium` | `titleLarge` | `titleSmall` |
| `CustomTextBody` | `bodyMedium` | `bodyLarge` | `bodySmall` |
| `CustomTextLabel` | `labelMedium` | `labelLarge` | `labelSmall` |

All five share the same parameters: `text` (required), `onPrimary` (picks `onPrimary` instead of
`onSurface` for the color — use it on colored backgrounds), `color` (overrides both), `isBold`,
`maxLine` (which also enables ellipsis overflow), and `textAlign`.

```dart
CustomTextTitle.L(text: TextEnum.editProfile.tr, isBold: true)
CustomTextBody.S(text: subtitle, maxLine: 2, onPrimary: true)
```

Other kit widgets: `CustomSize` (theme-scaled spacer, `fraction:` divides `defaultPadding`),
`CustomAnimatedSize`, `CustomSVG`, `CustomDividedBar`, `CustomTextButton`, `CustomTOCAndPP`,
`CustomCircularProgressBar`, `CustomLinearProgressBar`.

Remaining layout conventions:

- Pull spacing, durations, and app metadata from `lib/components.dart` (`defaultPadding`,
  `defaultButtonHeight`, `defaultDuration`, `defaultMaxBoxWidth`, `appName`). Check it before
  introducing a magic number.
- Sizes use `flutter_screenutil` (`.sp`) against a 360x690 design size.
- Buttons are `OnProcessButtonWidget` (from `on_process_button_widget`), which takes an async
  `onTap` returning `bool?` and an `onDone` callback. Text fields are `OnTextInputWidgetUserField`.

## Conventions that will bite you

**Use the pinned SDK.** `.fvmrc` pins Flutter 3.27.4. Run `fvm flutter analyze`, `fvm flutter run`,
`fvm flutter test`. Running a newer Flutter from `PATH` rewrites `pubspec.lock` with a Dart SDK
constraint the pinned toolchain cannot satisfy, which breaks `pub get` for everyone else. If you
see `pubspec.lock` or `*/flutter/generated_plugin_registrant.*` in `git status` after running a
Flutter command, you used the wrong SDK — revert those files.

**The analyzer is strict.** `analysis_options.yaml` enables `always_specify_types`,
`prefer_single_quotes`, `require_trailing_commas`, `public_member_api_docs`,
`lines_longer_than_80_chars`, `avoid_print`, and disallows implicit casts and implicit dynamic.
In practice: write `final String x = ...` not `final x = ...`, write `<String, dynamic>{}` not
`{}`, add a `///` comment to every public member, keep lines under 80 characters, and use
`devPrint` instead of `print`. Run `fvm flutter analyze` before declaring work finished.

**`GetStorage` is one shared box.** `AuthController`, `AppTheme`, `AppTranslations`, and
`BaseUseCase` all construct `GetStorage()` with no container name, so they share the default box.
Never call `erase()` — it would wipe the user's theme and locale along with the session. Remove the
specific key instead.

**Logging out is a side effect of assignment.** Setting `AuthController.find.user.value = null`
anywhere clears storage and calls `Get.offAll(() => const SplashScreen())`. Do not also navigate
manually, and be careful assigning it during app initialization.

**Debug-only tooling.** `devPrint(message, heading:, color:)` is a `kDebugMode`-gated colorized
logger — but note its arguments are evaluated before the gate, so do not put throwing expressions
inside a `devPrint` call. `DevAutoFillButton` takes a list of closures that prefill forms with test
credentials; expose them from the controller as `devFunctions`.

## Known unfinished work

Do not mistake these for intentional behavior:

- `_AuthenticationScreenRepository.login`/`signup` POST hardcoded test credentials
  (`emilys`/`emilyspass`) to a mock endpoint and ignore the `email`/`password` arguments; `signup`
  targets `auth/login` because the mock backend has no signup route. Marked with
  `// TODO: Simulate a network request`.
- There is no test suite; `test/widget_test.dart` is entirely commented out. Validators, string
  extensions, and model serialization in `lib/src/utils/functions/` and
  `lib/src/models/` are pure functions and are the natural place to start adding tests.
- `README.md` documents an architecture the code does not have.
