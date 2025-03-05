import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:getx_mvc/src/controllers/screen_controllers/authentication_wrapper_screen_controller.dart';
import 'package:getx_mvc/src/utils/dev_functions/dev_scaffold.dart';
import 'package:getx_mvc/src/views/widgets/animated_size.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import 'package:on_text_input_widget/on_text_input_widget.dart';

import '../../../../components.dart';
import '../../../utils/dev_functions/dev_auto_fill_button.dart';
import '../../../utils/functions/form_validation.dart';
import '../../widgets/size.dart';
import '../../widgets/text.dart';

/// AuthenticationWrapperScreen
class AuthenticationWrapperScreen extends StatefulWidget {
  /// AuthenticationWrapperScreen Constructor
  const AuthenticationWrapperScreen({super.key});

  @override
  State<AuthenticationWrapperScreen> createState() =>
      _AuthenticationWrapperScreenState();
}

class _AuthenticationWrapperScreenState
    extends State<AuthenticationWrapperScreen> {
  late final AuthenticationWrapperScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AuthenticationWrapperScreenController());
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<AuthenticationWrapperScreenController>();
  }

  @override
  Widget build(BuildContext context) {
    return DevScaffold(
      floatingActionButton:
          DevAutoFillButton(onPressed: _controller.devFunctions),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(defaultPadding),
                  constraints: const BoxConstraints(
                    maxWidth: defaultMaxBoxWidth,
                  ),
                  child: CustomAnimatedSize(
                    alignment: Alignment.topCenter,
                    child: Form(
                      key: _controller.loginFormKey,
                      child: Material(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Obx(
                              () => CustomAnimatedSize(
                                alignment: _controller.isLogin.value ?? true
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: CustomTextDisplay.S(
                                    text: _controller.isLogin.value == null
                                        ? 'Reset password'
                                        : _controller.isLogin.value!
                                            ? 'Login'
                                            : 'Signup',
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () => CustomAnimatedSize(
                                widthFactor: 1,
                                alignment: Alignment.topCenter,
                                child: CustomTextTitle.S(
                                  text: _controller.isLogin.value == null
                                      ? 'Provide your email to reset the password. An email to reset password will be sent to the given email.'
                                      : "Provide email and password to ${_controller.isLogin.value! ? "login" : "signup"} into the app.",
                                ),
                              ),
                            ),
                            const CustomSize(),

                            //! Email
                            const _Heading('Email'),
                            OnTextInputWidgetUserField(
                              textEditingController: _controller.emailC,
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter your email',
                              svg: 'lib/assets/icons/message_icon.svg',
                              validator: (String? value) => emailValidation(
                                value,
                                showDetails: _controller.isLogin.value == false,
                              ),
                            ),

                            //! Password
                            Obx(
                              () => CustomAnimatedSize(
                                alignment: Alignment.topCenter,
                                widthFactor: 1,
                                child: _controller.isLogin.value == null
                                    ? null
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const _Heading('Password'),
                                          OnTextInputWidgetUserField(
                                            textEditingController:
                                                _controller.passwordC,
                                            obscureText: true,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            hintText: 'Enter your password',
                                            svg:
                                                'lib/assets/icons/lock_icon.svg',
                                            validator: (value) =>
                                                passwordValidation(
                                              value,
                                              showDetails:
                                                  _controller.isLogin.value ==
                                                      false,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const CustomSize(),

                            // Align(
                            //   child: Obx(
                            //     () => CustomAnimatedSize(
                            //       widthFactor: 1,
                            //       alignment: Alignment.bottomCenter,
                            //       child: _controller.isLogin.value == null
                            //           ? null
                            //           : CustomTOCAndPP(
                            //               value: _controller.isExcepted.value,
                            //               onChanged: (value) => _controller
                            //                   .isExcepted.value = value),
                            //     ),
                            //   ),
                            // ),

                            const CustomSize(),

                            //! Login Button
                            _Login(),
                            const CustomSize(fraction: 4),
                            _GroupButton(),

                            if (Platform.isAndroid)
                              Column(
                                children: <Widget>[
                                  const CustomSize(fraction: 3 / 4),
                                  CustomDividedBar.or(),
                                  const CustomSize(),
                                  _GoogleSignIn(),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: CustomTextTitle.L(text: text),
    );
  }
}

class _Login extends StatelessWidget {
  _Login();
  final AuthenticationWrapperScreenController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return OnProcessButtonWidget(
      expandedIcon: true,
      roundBorderWhenRunning: false,
      onDone: _controller.requestSuccess,
      onTap: () async {
        bool isValid =
            _controller.loginFormKey.currentState?.validate() ?? false;
        if (!isValid) return false;
        return await _controller.requestLoginSignup();
      },
      child: Obx(
        () => Text(
          _controller.isLogin.value == null
              ? 'Reset'
              : _controller.isLogin.value!
                  ? 'Login'
                  : 'Signup',
        ),
      ),
    );
  }
}

class _GroupButton extends StatelessWidget {
  _GroupButton();
  final AuthenticationWrapperScreenController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: defaultPadding / 4),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomAnimatedSize(
              alignment: Alignment.centerRight,
              child: _controller.isLogin.value == null
                  ? CustomTextButton(
                      onDone: (_) => _controller.isLogin.value = true,
                      child: const Text('Login'),
                    )
                  : !_controller.isLogin.value!
                      ? null
                      : CustomTextButton(
                          onDone: (_) => _controller.isLogin.value = null,
                          child: const Text('Forgot Password'),
                        ),
            ),
            Text(
              '/',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            if (_controller.isLogin.value != null)
              CustomTextButton(
                onDone: (_) {
                  _controller.isLogin.value = !_controller.isLogin.value!;
                  _controller.resetLogin();
                },
                child: Text(
                  _controller.isLogin.value!
                      ? 'Sign up'
                      : 'Already have an account?',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoogleSignIn extends StatelessWidget {
  _GoogleSignIn();
  final AuthenticationWrapperScreenController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Align(
      child: CustomAnimatedSize(
        child: OnProcessButtonWidget(
          // enable: false,
          onTap: () async => _controller.googleSignIn(),
          onDone: _controller.requestSuccess,
          borderRadius: BorderRadius.circular(10000),
          backgroundColor: Colors.transparent,
          expanded: false,
          iconColor: Theme.of(context).colorScheme.primary,
          child: SvgPicture.asset(
            'lib/assets/icons/google_icon.svg',
            height: defaultPadding,
          ),
        ),
      ),
    );
  }
}
