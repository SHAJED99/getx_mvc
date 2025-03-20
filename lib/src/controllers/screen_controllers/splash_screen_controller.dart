import 'package:get/get.dart';

import '../../../components.dart';
import '../../views/screens/authentication/authentication_wrapper_screen.dart';
import '../data_controllers/app_data_controller.dart';
import '../data_controllers/auth_controller.dart';

/// SplashScreenController class
class SplashScreenController extends GetxController {
  /// Get SplashScreenController GetxController
  static SplashScreenController get find => Get.find();

  bool __isSplashScreenShown = false;
  bool __isInitialized = false;

  /// SplashScreenController init function
  /// This function will be called from splash screen
  /// This will initialize all the necessary controllers
  Future<void> init() async {
    _splashScreenShow();
    _initializeControllers();
  }

  Future<void> _splashScreenShow() async {
    await Future<void>.delayed(defaultSplashScreenShowDuration);
    __isSplashScreenShown = true;
    __gotoNextScreen();
  }

  Future<void> _initializeControllers() async {
    //! -------------------------------------------- Initialize controllers here
    await AppDataController.find.init();
    await AuthController.find.init();

    __isInitialized = true;
    __gotoNextScreen();
  }

  void __gotoNextScreen() {
    if (!__isSplashScreenShown || !__isInitialized) return;

    // ---------------------------------------------------- Route to next screen
    if (AuthController.find.user.value == null) {
      Get.offAll(() => const AuthenticationWrapperScreen());
    }
  }
}
