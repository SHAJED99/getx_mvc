import 'package:get/get.dart';

/// Handles app data
class AppDataController extends GetxController {
  /// Get SplashScreenController GetxController
  static AppDataController get find => Get.find();

  /// App data initialing function. This will be called from splash screen
  /// controller
  Future<void> init() async {
    await Future<void>.delayed(const Duration(seconds: 3));
  }
}
