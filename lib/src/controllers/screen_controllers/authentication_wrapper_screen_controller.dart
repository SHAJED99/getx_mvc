// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/user_message/snackbar.dart';

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
          passwordC.text = 'Signup123!';
        },
        () {
          // isLogin.value = true;
          emailC.text = 'kajiraj.raj@gmail.com';
          passwordC.text = 'signup123';
        }
      ];

  resetLogin() {}

  Future<bool> requestLoginSignup() async {
    if (isLogin.value != null && !isExcepted.value) {
      showToast(message: 'Please check the box');
      return false;
    }
    // return await _controller.loginSignupReset(
    //   emailC.text.trim(),
    //   passwordC.text.trim(),
    //   isLogin.value,
    // );
    return true;
  }

  Future<void> requestSuccess(bool? isSuccess) async {
    if (isSuccess != true) return;

    if (isLogin.value == null) {
      isLogin.value = true;
      return;
    }

    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) return;

    // if (user.emailVerified) {
    //   Get.offAll(() => const DashboardWrapperScreen());
    // } else {
    //   Get.offAll(() => const AccountVerificationScreen());
    // }
  }

  Future<bool> googleSignIn() async {
    if (isLogin.value != null && !isExcepted.value) {
      showToast(message: 'Please check the box');
      return false;
    }
    // return await _controller.googleSignIn();
    return true;
  }
}
