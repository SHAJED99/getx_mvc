# Architecture deep dive

How this app actually works, subsystem by subsystem. Derived from reading every file under `lib/`
and probing runtime behaviour on the pinned SDK (Flutter 3.27.4). Where behaviour was measured
rather than inferred, the measurement is shown.

Companion documents: `CLAUDE.md` (orientation) and `docs/getx-mvc-template.md` (how to add code).

---

## 1. Boot sequence

`main()` runs four things before any widget exists:

```
WidgetsFlutterBinding.ensureInitialized()
└─ SystemChrome.setPreferredOrientations([portraitUp])   // portrait lock
└─ await Environment.init      // dotenv.load() → apiBaseUrl
└─ await AppTranslations.init  // GetStorage → Locale   (default: en)
└─ await AppTheme.init         // GetStorage → ThemeMode (default: system)
└─ runApp(DevicePreview(enabled: !kReleaseMode, ...))
```

Each `init` is a static getter that reads persisted state and falls back to a default, so the app
already knows its locale and theme before the first frame — no flash of wrong theme.

The widget tree above the app is:

```
DevicePreview (debug only)
└─ ScreenUtilInit (designSize 360x690, fontSizeResolver = identity)
   └─ GetMaterialApp (theme, darkTheme, themeMode, translations, initialBinding)
      └─ AnnotatedRegion<SystemUiOverlayStyle>   // transparent system bars
         └─ SplashScreen
```

`_InitializedBinding` registers the two global controllers via `Get.put`: `AppDataController` and
`AuthController`.

### Startup timing

`SplashScreen` starts two independent async chains and navigates only when both complete:

| chain | work | delay |
|---|---|---|
| `_splashScreenShow()` | none | `defaultSplashScreenShowDuration` = **3s** |
| `_initializeControllers()` | `AppDataController.init()` → `PackageInfo.fromPlatform()` | **+3s** hardcoded |
| | `AuthController.init()` → read session from storage | **+3s** hardcoded |

The two controller inits run **sequentially**, so the gate is `max(3s, 3s + 3s)` = **~6 seconds of
deliberate delay on every cold start**. The real work (reading package info and a storage key) takes
milliseconds. These are `Future.delayed` calls left in from scaffolding, sitting in the critical
path.

`__gotoNextScreen()` requires both flags, then routes to `DashboardWrapperScreen` if
`AuthController.user.value != null`, else `AuthenticationWrapperScreen`.

---

## 2. Code architecture

Each feature is **one Dart library** assembled with `part` / `part of`:

```
views/screens/authentication/authentication_wrapper_screen.dart   ← library head, owns all imports
├── part controllers/screen_controllers/authentication/controller.dart
├── part controllers/screen_controllers/authentication/repository.dart
└── part controllers/screen_controllers/authentication/use_case.dart
```

Every class in the part files is private (`_AuthenticationScreenController`, etc.). Because Dart
privacy is per-library and the four files form one library, they see each other while nothing
outside can reach them.

Call chain: **View → Controller → UseCase → Repository → Model**.

Two consequences follow directly from this choice:

- **Part files cannot declare imports.** Every import for all four files lives in the screen file.
- **Private classes cannot be imported by tests.** Controllers, use cases, and repositories are
  structurally unreachable from `test/`. This is why the project has no unit tests.

The same `part` technique is reused for infrastructure: `http_repository.dart` owns
`http_client.dart` + `http_error_handler.dart`; `app_theme.dart` owns `colors.dart` +
`text_styles.dart`; `app_translations.dart` owns `string_enum.dart`.

Note that despite the `UseCase` / `Repository` names, this is **not** Clean Architecture: use cases
construct concrete repositories directly (`final _XRepository _repository = _XRepository();`), there
are no interfaces, no injection, and no domain entities distinct from the DTOs.

---

## 3. Navigation

There is **no route table** — no `GetPage`, no named routes, no middleware, no deep linking. All
navigation pushes widgets directly:

```dart
Get.to(() => const SomeScreen());     // push
Get.offAll(() => const SomeScreen()); // replace stack
```

Auth gating is imperative, in two places:

1. `_SplashScreenController.__gotoNextScreen()` picks the landing screen at startup.
2. `AuthController._userTask()` — a listener on `user` — calls `Get.offAll(SplashScreen)` whenever
   `user` becomes `null`.

That second mechanism means **logout is a side effect of assignment**. Setting
`AuthController.find.user.value = null` anywhere — including the 401 branch of the HTTP error
handler, several layers deep in a repository — wipes storage and navigates globally. Convenient, but
action at a distance: navigation originates from code that has no idea it is navigating.

---

## 4. State management and DI

GetX provides both reactivity and service location. Two controller tiers:

**Data controllers** (`controllers/data_controllers/`) — public, global, registered in
`_InitializedBinding`, never deleted:

- `AuthController` — `Rxn<UserModel> user`, the single source of truth for the session. Writing a
  value persists it; writing `null` clears storage and navigates.
- `AppDataController` — `Rxn<PackageInfo>`, used for the version string on the splash screen.

**Screen controllers** (`controllers/screen_controllers/<feature>/`) — private, per-screen:

```dart
final _XController _controller = Get.put(_XController());   // in State field
@override void dispose() { super.dispose(); Get.delete<_XController>(); }
```

Reached from nested private widgets via `static _XController get find => Get.find();` rather than
constructor parameters.

Reactivity is `.obs` / `Rxn` fields read inside `Obx(() => ...)`. An idiom worth knowing: several
classes use a quadruple-underscore `____init` async getter as an idempotent init guard. Dart gives
no extra privacy for extra underscores — it is purely a naming signal.

---

## 5. Theming

`AppTheme` owns lifecycle, persistence, and `ThemeData` assembly:

```dart
ThemeData theme(BuildContext context, {Brightness brightness = Brightness.light}) => ThemeData(
      textTheme: AppTextStyles._textTheme(context),
      buttonTheme: ButtonThemeData(height: defaultButtonHeight),
      colorScheme: brightness == Brightness.light
          ? AppColors._lightScheme
          : AppColors._darkScheme,
    );
```

`AppColors._lightScheme` / `_darkScheme` / `AppTextStyles._textTheme` are private to the
`app_theme.dart` library — unreachable from widgets by design. Widgets go through
`Theme.of(context)`, so there is exactly one path to a color.

Switching themes at runtime goes through `AppTheme.update(themeMode:)`, which persists to
`GetStorage` (key `AppTheme_theme`) **and** calls `Get.changeThemeMode`. Calling
`Get.changeThemeMode` directly would apply the theme but lose it on restart.

`AppTheme.setSafeAreaColor(context)` returns transparent system bars with brightness-appropriate
icons; `main.dart` applies it app-wide via `AnnotatedRegion`.

### Colour scheme

Both schemes are full Material 3 `ColorScheme`s generated by the Material Theme Builder. All nine
on-colour pairs pass WCAG AA in both schemes (measured 4.54:1 – 16.29:1). Primary is green
(`#076d35` light, `#81d995` dark).

Two defects:

- **Dark `tertiary` is `0xffffffff`.** The file's own pattern is that dark `<role>` equals
  `<role>FixedDim` — true for primary (`81d995`) and secondary (`99d774`), broken for tertiary,
  where `tertiaryFixedDim` is `0xffdac495` but dark `tertiary` is pure white. Dormant: `tertiary`
  is currently unused.
- **Six container roles are byte-identical across light and dark** — `primaryContainer`,
  `onPrimaryContainer`, `secondaryContainer`, `onSecondaryContainer`, `errorContainer`,
  `onErrorContainer`. M3 containers normally invert. This one is live; see §11.

### Text theme

`AppTextStyles._textTheme(context)`:

```dart
TextTheme base = Theme.of(context).textTheme.apply(fontSizeFactor: 1.sp);
TextTheme bodyTextTheme    = GoogleFonts.poppinsTextTheme(base);
TextTheme displayTextTheme = GoogleFonts.poppinsTextTheme(base);
return displayTextTheme.copyWith(/* body* and label* slots from bodyTextTheme */);
```

Three observations:

1. **The two-font split is currently a no-op.** Both themes are Poppins, so copying six slots from
   one into an identical other changes nothing. The structure exists so two typefaces can be paired
   later; as written it calls `poppinsTextTheme` twice per theme, four times per app rebuild.
2. **`fontSizeFactor: 1.sp` does nothing.** `main.dart` passes
   `fontSizeResolver: (fontSize, _) => fontSize.toDouble()`, making `.sp` an identity function.
   Measured sizes are exactly the Material defaults (`bodyMedium` 14.0, `titleLarge` 22.0). It reads
   like text scales with screen width, but it does not — and removing that resolver would multiply
   every font size by the width ratio (2.22x at 800px).
3. **The dark text theme carries light-mode colours.** `Theme.of(context)` is resolved from the
   `ScreenUtilInit` builder context, which sits *above* `GetMaterialApp` — so there is no app theme
   ancestor and it returns the light fallback, whose `TextStyle`s have near-black colours baked in.
   `ThemeData` then does `defaultTextTheme.merge(providedTextTheme)` and those non-null colours win
   over `Typography.white`. Measured:

   ```
   LIGHT bodyMedium color = #1d1b20
   DARK  bodyMedium color = #1d1b20     ← identical
   DARK  onSurface        = #dfe4dc     ← what it should be
   CONTRAST dark text on dark surface = 1.08:1   (should be 14.31:1)
   ```

   Masked today because every `Custom*` text widget overrides colour explicitly. Exposed for any
   plain `Text(...)` — e.g. the dev drawer buttons.

---

## 6. Localization

`AppTranslations extends Translations` builds GetX's translation map from an **enum**, not string
keys:

```dart
enum TextEnum {
  login(en: 'Login', bn: 'লগইন'),
  ...
}
```

`keys` maps each locale code to `{ enumValue.name: translation }`, and `TextEnum` exposes
`String get tr => name.tr;` so call sites read `TextEnum.login.tr`. A typo'd key is a compile error,
which is the main win over string-keyed maps.

Note the constructor signature: `const TextEnum({required String en, String? bn}) : _bn = bn ?? en`.
Only `en` is required — `bn` falls back to English when omitted. So a missing translation degrades
gracefully rather than failing the build. If you want the compiler to enforce completeness for a new
locale, declare it `required`; as written it does not.

Supported locales are `en` and `bn`; the choice persists under `AppTranslations_locale` and applies
through `Get.updateLocale`.

**Coverage is partial.** 17 `TextEnum` entries and 20 `.tr` call sites across only 4 files. Strings
that bypass the system entirely:

- All 22 `HTTPErrorEnum.errorMessage` values (every user-visible API error) — English only.
- `'Error'` — the snackbar title in `http_error_handler.dart:45`.
- `'Text copied'`, `'Opening browser'`, `'Unable to launch'` — `string_conversion.dart`.
- `'Terms and Conditions'`, `'Privacy Policy'` — `toc_and_pp.dart`, even though the surrounding
  sentence is translated.
- `'or'` (`divided_bar.dart` default), `'Undo'` (`snackbar.dart`), `'Message'` (`showToast`).

The clearest illustration is in one file: `controller.dart:48` shows
`TextEnum.pleaseCheckBox.tr`, while `controller.dart:88` hardcodes the identical message as
`'Please check the box'`.

---

## 7. API layer

```dart
abstract class HttpRepository {
  final _HttpClient httpClient = _HttpClient();
  final _HttpErrorHandler errorHandler = _HttpErrorHandler();
}
```

`_HttpClient` wraps Dio and, in its constructor, sets JSON headers, a 30s connect/receive timeout,
`validateStatus: (_) => true` (so non-2xx responses return normally instead of throwing), and a
response interceptor that captures `set-cookie`. Each request:

- prepends `Environment.apiBaseUrl` (overridable per call via `customBaseLink`)
- attaches `Authorization: Bearer <token>` from `AuthController.user.value.token`
- optionally attaches the captured cookie
- logs request and response through `devPrint` (URL, status, headers, body, data)
- in debug, fires a toast with the URL on every call

Repository methods follow a fixed shape — wrap in the error handler, throw the response on failure,
return the model or `null`:

```dart
Future<UserModel?> login(...) async {
  UserModel? result;
  await errorHandler.errorHandler(function: () async {
    final dio.Response<Map<String, dynamic>> response =
        await httpClient.post('auth/login', body: <String, dynamic>{...});
    if (response.statusCode != 200 || response.data == null) throw response;
    result = UserModel.fromMap(response.data!);
  });
  return result;
}
```

Callers check for `null`; exceptions never escape the repository.

**`httpClient` is an instance field**, so every repository constructs its own `Dio` with its own
interceptors and its own `String _cookie`. Repositories are created per use case, per controller,
per screen — so cookies captured by one repository are invisible to every other, and each screen
builds a fresh client.

---

## 8. Error handling

`_HttpErrorHandler.errorHandler` is the single funnel. It catches, in order:

| caught | mapped to |
|---|---|
| `DioException` with `connectionError` | `socketException` |
| `DioException` with connect/send/receive timeout | `requestTimeOut` |
| `DioException` (other) | matched on `response.statusCode` |
| `TypeError` | `parseError` |
| `FormatException` | `parseError` |
| thrown `dio.Response` | matched on `statusCode` |
| thrown `String` | shown verbatim as the server message |
| anything else | `unknown` |

`HTTPErrorEnum` carries a human message and an optional HTTP code; status matching is a linear scan
over its values. On success it returns `HTTPErrorEnum.done`.

Every failure then: shows an error snackbar (suppressible via `showError: false`), logs red through
`devPrint`, and — for `unauthorized` (401) — sets `AuthController.find.user.value = null`, which
triggers the global logout-and-navigate described in §3.

A commented-out escape hatch at the top of the method lets you bypass all handling while debugging a
stack trace.

---

## 9. Persistence

Everything uses `GetStorage`, and **all four consumers share the default unnamed box**:

| owner | key |
|---|---|
| `AuthController` | `AuthController` (serialized `UserModel`) |
| `AppTheme` | `AppTheme_theme` |
| `AppTranslations` | `AppTranslations_locale` |
| `BaseUseCase` | caller-supplied |

Because the box is shared, `erase()` would wipe theme and locale along with the session — so logout
removes only its own key. `BaseUseCase` exposes static `saveData({key, value})` / `readData({key})`
for features needing simple string persistence.

`UserModel` follows the house model shape: `fromMap`/`fromJson`, `toMap`/`toJson`, `copyWith`,
value equality, and a `toString()` that truncates the token via `String.customCutString`. `fromMap`
throws `FormatException` when `accessToken` is missing, so a malformed response or a session written
by an older build is rejected and cleared rather than silently producing a `"null"` token.

---

## 10. Widget kit

All widgets live in `views/widgets/` and read colours from `colorScheme`, sizes from
`components.dart`.

**Text** — five families, each with three constructors mapping onto the Material text scale:

| widget | default | `.L` | `.S` |
|---|---|---|---|
| `CustomTextDisplay` | `displayMedium` | `displayLarge` | `displaySmall` |
| `CustomTextHeading` | `headlineMedium` | `headlineLarge` | `headlineSmall` |
| `CustomTextTitle` | `titleMedium` | `titleLarge` | `titleSmall` |
| `CustomTextBody` | `bodyMedium` | `bodyLarge` | `bodySmall` |
| `CustomTextLabel` | `labelMedium` | `labelLarge` | `labelSmall` |

Shared params: `text`, `onPrimary` (picks `onPrimary` vs `onSurface`), `color` (overrides),
`isBold`, `maxLine` (enables ellipsis), `textAlign`. All of them `copyWith` an explicit colour,
which is what masks the dark-theme text bug in §5.

**Others**

- `CustomSize({fraction})` — `SizedBox` of `defaultPadding / fraction`; sets *both* height and width.
- `CustomAnimatedSize` — `FractionallySizedBox` + `AnimatedSize`. Its `curve` parameter is accepted
  and documented but never used; `build()` hardcodes `Curves.easeInOut`.
- `CustomSVG(path)` — `SvgPicture.asset` with a `ColorFilter` tinting to `onSurface`/`onPrimary`.
- `CustomDividedBar` / `.or` — hairline rule (`defaultPadding / 16`) optionally split around a
  centred label. Tinted `onPrimaryContainer.withAlpha(127)`, one of the non-flipping colours.
- `CustomTextButton` — thin wrapper over `OnProcessButtonWidget` with transparent background.
- `CustomTOCAndPP` — checkbox plus a rich-text consent line. Renders links by drawing the text
  `Colors.transparent` and painting it via an offset `Shadow`, with a real `underline` decoration.
- `CustomCircularProgressBar` / `CustomLinearProgressBar`.

Buttons throughout are `OnProcessButtonWidget` (async `onTap` returning `bool?`, plus `onDone`);
text fields are `OnTextInputWidgetUserField`. Both are the author's own pub packages.

---

## 11. Dev tooling

All `kDebugMode`-gated and stripped from release:

- **`devPrint(message, heading:, color:)`** — ANSI-coloured console logger, pretty-prints Maps/Lists
  and JSON strings, draws divider rules, widths to the terminal. Used instead of `print` (which the
  linter bans). Note its arguments are evaluated *before* the debug gate, so a throwing expression
  inside a `devPrint` call still throws in release.
- **`DevScaffold`** — wraps a screen's `Scaffold`; in release returns the child untouched. In debug
  adds an end-drawer with one button per locale, one per `ThemeMode`, and a logout button.
- **`DevAutoFillButton`** — a row of numbered buttons that fill forms from a controller's
  `devFunctions` list (the auth controller ships three test logins).
- **`DevicePreview`** — wraps the whole app when not in release.

---

## 12. Known defects

Collected from reading and measurement. Items 1–3 share a root cause: a value that should vary by
theme but does not.

| # | Where | Issue | Impact |
|---|---|---|---|
| 1 | `text_styles.dart:7` | Dark text theme carries light-mode colours (`#1d1b20`) | Plain `Text` at **1.08:1** in dark mode; masked for kit widgets |
| 2 | `colors.dart` + `snackbar.dart:76,80` | `info` uses `primaryContainer`, `warning` uses `onErrorContainer` — neither flips | Info icon **1.77:1** in light; warning icon **1.55:1** in dark |
| 3 | `colors.dart` + `divided_bar.dart:108` | Divider uses `onPrimaryContainer` (`#004921` both themes) at 50% alpha | Weak divider on dark surfaces |
| 4 | `colors.dart:70` | Dark `tertiary` is `#ffffff`, breaking the `FixedDim` pattern | Dormant — `tertiary` unused |
| 5 | `splash_screen/controller.dart` + both data controllers | Two sequential hardcoded `Future.delayed(3s)` | **~6s** forced cold start |
| 6 | `http_repository.dart:25` | `_HttpClient` is an instance field | One Dio per repository; fragmented cookie jar |
| 7 | `animated_size.dart:28,61` | `curve` parameter accepted but ignored | Callers cannot change the curve |
| 8 | `string_enum.dart` + various | Partial i18n; errors and several UI strings hardcoded | Non-English users see mixed languages |
| 9 | `repository.dart` | `login`/`signup` post hardcoded credentials to a mock endpoint | Auth flow is a mock (`// TODO`) |
| 10 | project-wide | Private part-file classes cannot be imported by tests | No unit tests are possible |

---

## 13. Conventions worth respecting

- Run Flutter through **`fvm`** (`.fvmrc` pins 3.27.4). A newer SDK rewrites `pubspec.lock` with a
  Dart constraint the pinned toolchain cannot satisfy.
- The analyzer is strict: `always_specify_types`, `public_member_api_docs`, `prefer_single_quotes`,
  `require_trailing_commas`, `lines_longer_than_80_chars`, `avoid_print`, no implicit casts or
  dynamic.
- Never call `GetStorage().erase()` — the box is shared.
- Never hardcode a `Color`; add the role to the `ColorScheme`.
- Never hardcode a display string; add a `TextEnum` value.
- `README.md` describes an architecture this project does not have. Treat it as marketing.
