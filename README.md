# 🏗️ GetX MVC Flutter Template

> A Flutter starter built on GetX, with batteries included: HTTP + error handling, enum-based
> localization, persisted theming, and a shared widget kit.

![Flutter](https://img.shields.io/badge/Flutter-3.27.4-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.6-0175C2?style=flat-square&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![GetX](https://img.shields.io/badge/GetX-4.7-blue?style=flat-square)

Clone it, point `.env` at your API, and start building screens. The cross-cutting infrastructure —
networking, error taxonomy, translations, theme persistence, debug tooling — is already wired.

---

## ✨ What's inside

- 🧩 **Feature-as-a-library pattern** — each screen bundles its controller, use case, and repository
  into one Dart library via `part`, keeping every feature class private and non-leaky
- 🌐 **HTTP layer** — Dio wrapper with automatic bearer-token injection, request/response logging,
  30s timeouts, and cookie capture
- 🚦 **Centralized error handling** — every failure maps onto a typed `HTTPErrorEnum`, surfaces a
  snackbar, and auto-logs-out on 401
- 🌍 **Enum-based localization** — translations are enum values, not string keys, so a typo is a
  compile error. Ships `en` + `bn`
- 🎨 **Material 3 theming** — full light/dark `ColorScheme`s, Google Fonts, persisted `ThemeMode`
- 💾 **Persistence** — `GetStorage` for session, theme, and locale, restored before first frame
- 🧪 **Debug tooling** — in-app drawer for switching theme/locale, form auto-fill buttons, and a
  colorized logger. All stripped from release builds
- 📱 **Platform ready** — Android, iOS, Web, macOS, Windows, Linux

---

## 📦 Getting started

This project pins its Flutter version in `.fvmrc`. Using [FVM](https://fvm.app/) is strongly
recommended — a newer SDK will rewrite `pubspec.lock` with a Dart constraint the pinned toolchain
can't satisfy.

```bash
# Clone
git clone https://github.com/SHAJED99/getx_mvc.git your_project_name
cd your_project_name

# Use the pinned SDK (3.27.4)
fvm install
fvm flutter pub get

# Configure the API base URL — required, the app throws on startup without it
echo "API_BASE_URL=https://your.api/" > .env

# Run
fvm flutter run
```

Useful commands:

```bash
fvm flutter analyze      # strict lint set, see analysis_options.yaml
fvm flutter test
dart format lib test
```

---

## 🗂️ Project structure

```
lib/
├── components.dart                 # app-wide constants: spacing, durations, app name, URLs
├── main.dart                       # bootstrap, GetMaterialApp, global bindings
└── src/
    ├── controllers/
    │   ├── data_controllers/       # global singletons: AuthController, AppDataController
    │   └── screen_controllers/     # per-feature private controller/use_case/repository
    │       ├── authentication/
    │       └── splash_screen/
    ├── core/
    │   ├── environment/            # .env loading
    │   ├── http/                   # HttpRepository, Dio client, error handler, error enum
    │   ├── localization/           # AppTranslations + TextEnum
    │   ├── theme/                  # AppTheme + colors + text styles
    │   └── use_case/               # BaseUseCase (GetStorage helpers)
    ├── models/data/app_models/     # UserModel
    ├── utils/
    │   ├── dev_functions/          # devPrint, DevScaffold
    │   ├── functions/              # validators, String extensions
    │   └── user_message/           # snackbar & toast
    └── views/
        ├── screens/                # splash, authentication, dashboard
        └── widgets/                # Custom* widget kit
```

---

## 🧱 Architecture

The organizing idea: **one feature = one Dart library**. The screen file is the library head and
declares its controller, use case, and repository as `part` files.

```
views/screens/authentication/authentication_wrapper_screen.dart   ← owns all imports
├── part → controllers/screen_controllers/authentication/controller.dart
├── part → controllers/screen_controllers/authentication/repository.dart
└── part → controllers/screen_controllers/authentication/use_case.dart
```

Because Dart privacy is per-library, every class inside can be `_`-private — so
`_AuthenticationScreenController` is genuinely unreachable from any other feature. Deleting a
feature is four files and cannot leave dangling references.

Flow: **View → Controller → UseCase → Repository → Model**

| layer | responsibility |
|---|---|
| View | widgets; wraps its `Scaffold` in `DevScaffold` |
| Controller | UI state (`.obs`, form keys, text controllers); `Get.put` in `State`, `Get.delete` in `dispose` |
| UseCase | business rules; writes shared state such as `AuthController.user` |
| Repository | extends `HttpRepository`; performs the API call, returns a model or `null` |

Two things to know before writing code:

1. **`part` files cannot declare imports** — every import for the feature lives in the screen file.
2. **Navigation is direct, not named.** There is no route table; push widgets with
   `Get.to(() => const Screen())` / `Get.offAll(...)`.

Controllers come in two tiers: global **data controllers** registered once in `main.dart`'s
`_InitializedBinding`, and private **screen controllers** scoped to a single screen.

> 📖 Full walkthrough with copy-ready file templates: **[docs/getx-mvc-template.md](docs/getx-mvc-template.md)**

---

## 🎨 Theming

`AppTheme` owns the lifecycle; colors and text styles are `part` files of it, so they're private and
widgets can only reach them through `Theme.of(context)`.

```dart
// Read
final ColorScheme scheme = Theme.of(context).colorScheme;
final TextStyle? title = Theme.of(context).textTheme.titleMedium;

// Switch at runtime — persists AND applies
await AppTheme.update(themeMode: ThemeMode.dark);
```

Both schemes are full Material 3 `ColorScheme`s generated with the
[Material Theme Builder](https://material-foundation.github.io/material-theme-builder/), defined in
`lib/src/core/theme/colors.dart`. Edit `_lightScheme` and `_darkScheme` **in tandem**. Never
hardcode a `Color` in a widget — add the role to the scheme instead, or it won't adapt to dark mode.

Text goes through the `Custom*` widgets, which wire the text theme and color scheme together:

| widget | default | `.L` | `.S` |
|---|---|---|---|
| `CustomTextDisplay` | `displayMedium` | `displayLarge` | `displaySmall` |
| `CustomTextHeading` | `headlineMedium` | `headlineLarge` | `headlineSmall` |
| `CustomTextTitle` | `titleMedium` | `titleLarge` | `titleSmall` |
| `CustomTextBody` | `bodyMedium` | `bodyLarge` | `bodySmall` |
| `CustomTextLabel` | `labelMedium` | `labelLarge` | `labelSmall` |

```dart
CustomTextTitle.L(text: TextEnum.login.tr, isBold: true)
CustomTextBody.S(text: subtitle, maxLine: 2, onPrimary: true)
```

---

## 🌍 Localization

Strings are enum values rather than map keys, so they're autocompleted and typo-proof.

```dart
// lib/src/core/localization/string_enum.dart
enum TextEnum {
  login(en: 'Login', bn: 'লগইন'),
  email(en: 'Email', bn: 'ইমেল'),
}
```

```dart
Text(TextEnum.login.tr)
await AppTranslations.update(locale: const Locale('bn'));
```

Only `en` is required — a missing `bn` falls back to English rather than breaking the build. Adding
a language means extending `supportedLocales`, the `keys` map, and `TextEnum`.

---

## 🌐 Networking

Extend `HttpRepository` to inherit a configured client and the shared error handler.

```dart
class _ProfileRepository extends HttpRepository {
  Future<UserModel?> load() async {
    UserModel? result;

    await errorHandler.errorHandler(
      function: () async {
        final dio.Response<Map<String, dynamic>> response =
            await httpClient.get('user/me');

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

The handler maps `DioException`s, timeouts, parse failures, and thrown responses onto
`HTTPErrorEnum`, shows an error snackbar, logs the failure, and clears the session on `401`.
Repository methods return `null` on failure — callers check for `null` rather than catching.

The base URL, bearer token, timeouts, and logging are all applied automatically. Don't construct
`Dio` yourself.

---

## 🧪 Debug tooling

Everything here compiles out of release builds:

- **`DevScaffold`** — wrap a screen's `Scaffold`; adds a drawer to switch locale, switch theme, and
  log out
- **`DevAutoFillButton`** — numbered buttons that fill forms from a controller's `devFunctions`
- **`devPrint(...)`** — colorized logger that pretty-prints JSON (use instead of `print`)
- **`DevicePreview`** — active whenever not in release

---

## 📚 Documentation

| document | purpose |
|---|---|
| [docs/getx-mvc-template.md](docs/getx-mvc-template.md) | How to add screens, API calls, strings, and styling |
| [docs/architecture-deep-dive.md](docs/architecture-deep-dive.md) | How every subsystem works, plus measured behavior and known defects |
| [CLAUDE.md](CLAUDE.md) | Orientation for AI coding agents |

---

## 🚧 Project status

This is a working starter, not a hardened framework. Before shipping on top of it, be aware:

- The authentication repository still posts **hardcoded credentials to a mock endpoint** — wire it
  to your real API (`// TODO` markers in `screen_controllers/authentication/repository.dart`)
- Cold start carries roughly **6 seconds of scaffolding `Future.delayed`** in the splash chain
- There is **no test suite**, and the `part`-file privacy pattern means feature classes can't be
  imported by tests as written
- A handful of theme and localization gaps are catalogued in
  [the deep dive](docs/architecture-deep-dive.md#12-known-defects)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📄 License

```
MIT License
Copyright (c) 2024 Shajedur Rahman Panna
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/SHAJED99">Shajedur Rahman Panna</a>
</p>
