# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Flutter app using GetX for state management/DI, built as a "GetX MVC" boilerplate. Pinned Flutter version is `3.27.4` (see `.fvmrc`) — use FVM (`fvm flutter ...`) if installed, otherwise plain `flutter` must match that version.

## Commands

```bash
flutter pub get              # install dependencies
flutter run                  # run on a connected device/emulator
flutter analyze              # static analysis (uses analysis_options.yaml)
dart format lib test         # format code
flutter test                 # run tests
flutter test test/widget_test.dart   # run a single test file
flutter build apk|ios|web|windows|linux|macos   # platform builds
```

There is currently no real test suite — `test/widget_test.dart` is entirely commented out.

`analysis_options.yaml` enables a strict lint set on top of `flutter_lints`, notably `always_specify_types`, `public_member_api_docs`, `lines_longer_than_80_chars`, and disallows implicit casts/dynamic. New code should follow these (explicit types everywhere, doc comments on public members).

The `.env` file (loaded via `flutter_dotenv`, listed as a pubspec asset) must define `API_BASE_URL`. It's read once in `Environment.init` (`lib/src/core/environment/environment.dart`) during app startup.

## Architecture

**Important:** `README.md`'s "Project Structure" section describes a generic/aspirational GetX layout (`app/`, `data/`, `domain/`, `presentation/`, named routes via `GetPage`). The actual code under `lib/` does **not** follow that — there is no routing table, no `GetPage`/`Bindings` list, no `data`/`domain`/`presentation` split. Trust the structure described below, which reflects what's actually implemented.

### Screen files bundle controller/repository/use_case via `part`/`part of`

Each screen lives at `lib/src/views/screens/<feature>/<feature>_screen.dart` and declares its controller/repository/use_case as `part` files rather than importing them:

```dart
part '../../../controllers/screen_controllers/<feature>/controller.dart';
part '../../../controllers/screen_controllers/<feature>/repository.dart';
part '../../../controllers/screen_controllers/<feature>/use_case.dart';
```

Those part files live under `lib/src/controllers/screen_controllers/<feature>/` and contain **private** classes (`_AuthenticationScreenController`, `_AuthenticationScreenRepository`, `_AuthenticationScreenUseCase`), scoped to that screen only — they cannot be used elsewhere. This is the pattern to follow when adding a new screen/feature (see `authentication_wrapper_screen.dart` + its three part files as the reference example).

The call chain is **View → Controller → UseCase → Repository**: the screen controller is a `GetxController` created with `Get.put(...)` in the widget's `State` and removed with `Get.delete<...>()` in `dispose()` (never registered globally). It's accessed elsewhere with a static `find` getter (`static _AuthenticationScreenController get find => Get.find();`). The controller holds UI state (`.obs`/`Rxn`, form keys, text controllers) and delegates business logic to the use case. The use case calls the repository and updates shared state (e.g. writing to `AuthController.find.user`). The repository extends `HttpRepository` and makes the actual API calls.

### Two kinds of controllers

- **Data controllers** (`lib/src/controllers/data_controllers/`): app-wide, long-lived singletons (`AuthController`, `AppDataController`). Registered once in `_InitializedBinding` in `main.dart` via `Get.put(...)` and never deleted. `AuthController.user` (an `Rxn<UserModel>`) is the single source of truth for auth state — setting it to `null` anywhere logs the user out (this also triggers `Get.offAll(() => SplashScreen())`), and setting it to a value persists it to `GetStorage`.
- **Screen controllers** (`lib/src/controllers/screen_controllers/<feature>/`): private, per-screen, scoped as described above.

### Navigation

No named routes. Navigation is done by pushing widgets directly, e.g. `Get.offAll(() => const DashboardWrapperScreen())`. Flow is `SplashScreen` → (`AuthenticationWrapperScreen` or `DashboardWrapperScreen`) based on `AuthController.find.user.value`.

### HTTP layer (`lib/src/core/http/`)

`http_repository.dart` defines `abstract class HttpRepository` with two `part` files: `http_client.dart` (private `_HttpClient`, wraps `Dio`, injects auth bearer token from `AuthController`, logs requests/responses via `devPrint`) and `http_error_handler.dart` (private `_HttpErrorHandler`). Any repository that needs to call the API extends `HttpRepository` to get `httpClient` and `errorHandler` for free.

Error handling convention: wrap the actual request in `errorHandler.errorHandler(function: () async { ... throw response; ... })`. It catches `DioException`/`TypeError`/thrown responses, maps them to an `HTTPErrorEnum` (`lib/src/core/http/http_error_enum.dart`), shows a snackbar by default, and — importantly — **automatically logs the user out** (`AuthController.find.user.value = null`) on a `401`. Repository methods return the parsed model (or `null` on failure); callers check for `null`, not exceptions.

### Local persistence

- `AuthController` and `AppTheme`/`AppTranslations` each manage their own `GetStorage` instance directly for their specific data (user session, theme mode, locale).
- `BaseUseCase` (`lib/src/core/use_case/use_case.dart`) provides generic `saveData`/`readData` string helpers over `GetStorage` for use cases that need simple key/value persistence — extend it the way `_AuthenticationScreenUseCase` does.

### Theming & localization

- `AppTheme` (`lib/src/core/theme/app_theme.dart`, with `part` files `colors.dart`/`text_styles.dart`) persists `ThemeMode` to storage and applies it via `Get.changeThemeMode`.
- `AppTranslations` (`lib/src/core/localization/app_translations.dart`, `part` file `string_enum.dart`) defines all strings as a `TextEnum` with `en`/`bn` fields per entry; `keys` builds GetX's translation map from the enum's `.name`. Add new UI strings as new `TextEnum` values, referenced in widgets via `TextEnum.someKey.tr`. Adding a language means adding both a `Locale` to `supportedLocales` and a field on every `TextEnum` value (search for `// TODO: Add language`).

### Dev-only tooling

`lib/src/utils/dev_functions/`: `devPrint` (colorized, `kDebugMode`-gated console logging used throughout controllers/HTTP layer instead of `print`) and `DevScaffold`/`DevAutoFillButton` (a debug-only wrapper `Scaffold` with an end-drawer for toggling theme/locale and logging out, plus a floating row of buttons that auto-fill forms with test credentials — see `devFunctions` in `_AuthenticationScreenController`). Every screen's build wraps its real `Scaffold` in `DevScaffold`; in release builds it's a no-op passthrough.

### Shared widgets & constants

- `lib/components.dart` holds cross-app constants (`defaultPadding`, `defaultButtonHeight`, `defaultDuration`, `appName`, etc.) and is imported by relative path (`../../../../components.dart`) from deeply nested screens — check it before hardcoding a spacing/duration value.
- `lib/src/views/widgets/` holds the reusable UI kit, all prefixed `Custom*` (`CustomTextTitle`/`CustomTextBody`/`CustomTextHeading`, `CustomSize`, `CustomAnimatedSize`, `CustomSVG`, `CustomDividedBar`, `CustomTextButton`, `CustomTOCAndPP`) — prefer these over raw Material widgets for consistency with the rest of the app.

### Models

Data models (`lib/src/models/data/app_models/`, currently just `UserModel`) follow a consistent shape: `fromMap`/`fromJson` factories, `toMap`/`toJson`, `copyWith`, value-based `==`/`hashCode`, and a `toString()` that redacts sensitive fields via `String.customCutString` (`lib/src/utils/functions/string_conversion.dart`).

Note: `_AuthenticationScreenRepository.login`/`signup` currently POST hardcoded test credentials to a mock endpoint (marked `// TODO: Simulate a network request`) rather than the real `email`/`password` args — this is unfinished scaffolding, not intentional behavior.
