import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Handles authentication screens
class AuthenticationWrapperScreenController extends GetxController {
  /// Get AuthenticationWrapperScreenController GetxController
  static AuthenticationWrapperScreenController get to => Get.find();

  final RxnBool isLogin = RxnBool(true);
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final RxBool isExcepted = false.obs;

  @override
  void onClose() {
    super.onClose();
    emailC.dispose();
    passwordC.dispose();
  }

  List<void Function()> get devFunctions => <void Function()>[
        () {
          // isLogin.value = true;
          emailC.text = 'shajedurrahmanpanna@gmail.com';
          passwordC.text = 'signup123';
        },
        () {
          // isLogin.value = true;
          emailC.text = 'shajedurrahmanpanna.panna@gmail.com';
          passwordC.text = 'signup123';
        },
        () {
          // isLogin.value = true;
          emailC.text = 'kajiraj.raj@gmail.com';
          passwordC.text = 'signup123';
        }
      ];
}
