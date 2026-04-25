# 🏗️ GetX MVC Flutter Template

> A production-ready Flutter boilerplate using GetX pattern with Clean Architecture — the fastest way to start a new Flutter project.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![GetX](https://img.shields.io/badge/GetX-3.0.0-blue?style=flat-square)

🚀 **Start your next Flutter project in seconds, not hours.** This template follows GetX MVC architecture with clean separation of concerns, route management, dependency injection, and production-best practices baked in.

---

## ✨ Features

- 🏗️ **Clean Architecture** — Presentation / Domain / Data layers properly separated
- 🎮 **GetX MVC Pattern** — Controllers, Bindings, Views with reactive state management
- 🧭 **Route Management** — Centralized routing with `GetMaterialApp` and named routes
- 💉 **Dependency Injection** — Built-in `Get.put()` / `Get.lazyPut()` / `Get.find()` DI
- 🔄 **Reactive State** — `.obs` observables with `Obx()` widgets for UI updates
- 🌐 **API Integration Ready** — Base API client with interceptors and error handling
- 🔐 **Auth Guard** — Authentication middleware protecting routes
- 🎨 **Theming** — Light/dark theme switching with `Get.isDarkMode`
- 📝 **Forms & Validation** — Input validation patterns with real-time feedback
- 📱 **Platform Ready** — Android, iOS, Web, macOS, Windows, Linux

---

## 📦 Installation

```bash
# Clone the template
git clone https://github.com/SHAJED99/getx_mvc.git your_project_name

# Navigate to project
cd your_project_name

# Get dependencies
flutter pub get

# Run it
flutter run
```

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── app/
│   ├── app.dart                 # GetMaterialApp configuration
│   ├── routes/
│   │   ├── app_pages.dart       # Route definitions
│   │   └── app_routes.dart      # Route name constants
│   ├── bindings/
│   │   ├── initial_binding.dart # Global DI bindings
│   │   └── home_binding.dart    # Feature-specific bindings
│   ├── theme/
│   │   ├── app_theme.dart       # Light + dark theme data
│   │   └── app_colors.dart      # Color palette
│   └── core/
│       ├── constants/
│       │   ├── api_constants.dart
│       │   └── app_constants.dart
│       ├── utils/
│       │   ├── validators.dart   # Input validators
│       │   └── helpers.dart      # Utility functions
│       └── widgets/
│           ├── loading_widget.dart
│           └── error_widget.dart
├── data/
│   ├── models/
│   │   └── user_model.dart      # Data models
│   ├── providers/
│   │   └── api_provider.dart    # HTTP client (Dio/Http)
│   └── repositories/
│       └── user_repository.dart # Data layer
├── domain/
│   └── entities/
│       └── user.dart            # Domain entities
└── presentation/
    ├── home/
    │   ├── controllers/
    │   │   └── home_controller.dart
    │   ├── bindings/
    │   │   └── home_binding.dart
    │   └── views/
    │       ├── home_view.dart
    │       └── widgets/
    │           └── some_widget.dart
    └── auth/
        ├── controllers/
        │   └── auth_controller.dart
        ├── bindings/
        │   └── auth_binding.dart
        └── views/
            ├── login_view.dart
            └── register_view.dart
```

---

## 🚀 Quick Start

### 1. Define a Route
```dart
// app_routes.dart
abstract class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const profile = '/profile/:userId';
}
```

### 2. Create a Controller
```dart
class HomeController extends GetxController {
  final isLoading = false.obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  Future<void> fetchUser() async {
    isLoading.value = true;
    try {
      final repo = UserRepository();
      final user = await repo.getUser();
      userName.value = user.name;
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 3. Create a View
```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Center(child: Text('Hello, ${controller.userName.value}'));
      }),
    );
  }
}
```

### 4. Register the Binding
```dart
abstract class HomeBindings extends Bindings {
  @override
  Widget dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

---

## 🎛️ Key Patterns

### Reactive State with `.obs`
```dart
final count = 0.obs;
void increment() => count.value++;
```

```dart
Obx(() => Text('Count: ${controller.count.value}'));
```

### Get.put() for Global Singletons
```dart
Get.put(AuthController());  // Available everywhere with Get.find()
```

### Get.lazyPut() for On-Demand Services
```dart
Get.lazyPut<ApiProvider>(() => ApiProvider());
```

### Route with Parameters
```dart
// Navigate with data
Get.toNamed(AppRoutes.profile, arguments: {'userId': 123});

// Access in controller
final userId = Get.arguments['userId'];
```

### Auth Guard
```dart
GetMaterialApp(
  initialRoute: AppRoutes.splash,
  getPages: [
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: HomeBindings(),
      middlewares: [AuthMiddleware()],
    ),
  ],
)
```

---

## 🎨 Theming

```dart
// Light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF6C63FF),
  scaffoldBackgroundColor: Colors.white,
);

// Dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF6C63FF),
  scaffoldBackgroundColor: Color(0xFF121212),
);
```

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
