import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Handles additional(Optional) app data
/// Optional Data like App Version
class AppDataController extends GetxController {
  /// Get SplashScreenController GetxController
  static AppDataController get find => Get.find();

  /// Package information
  Rxn<PackageInfo> packageInformation = Rxn<PackageInfo>();

  /// App data initialing function. This will be called from splash screen
  /// controller
  Future<void> init() async {
    packageInformation.value = await PackageInfo.fromPlatform();

    await Future<void>.delayed(const Duration(seconds: 3));
  }
}
