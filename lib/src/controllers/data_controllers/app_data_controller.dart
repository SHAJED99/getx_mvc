import 'package:get/get.dart';

/// Handles app data
class AppDataController extends GetxController {
  /// App data initialing function. This will be called from splash screen
  /// controller
  Future<void> init() async {
    await Future<void>.delayed(const Duration(seconds: 3));
  }
}
