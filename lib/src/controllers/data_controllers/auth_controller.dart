import 'package:get/get.dart';
import 'package:getx_mvc/src/models/data/app_models/user_model.dart';

/// Handles user authentication status. This will not use to call Login API or
/// similar types of operations
class AuthController extends GetxController {
  /// Get SplashScreenController GetxController
  static AuthController get to => Get.find();

  /// Authentication initialing function. This will be called from splash screen
  /// controller
  Future<void> init() async {
    await Future<void>.delayed(const Duration(seconds: 3));
  }

  /// User model
  final Rxn<UserModel> user = Rxn<UserModel>();
}
