import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:getx_mvc/src/models/localization/app_translations.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import 'package:on_text_input_widget/on_text_input_widget.dart';

import '../../../../components.dart';
import '../../../controllers/screen_controllers/authentication_wrapper_screen_controller.dart';
import '../../../utils/dev_functions/dev_auto_fill_button.dart';
import '../../../utils/dev_functions/dev_scaffold.dart';
import '../../../utils/functions/form_validation.dart';
import '../../widgets/animated_size.dart';
import '../../widgets/button.dart';
import '../../widgets/divided_bar.dart';
import '../../widgets/size.dart';
import '../../widgets/text.dart';
import '../../widgets/toc_and_pp.dart';

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
                                        ? TextEnum.resetPassword.tr
                                        : _controller.isLogin.value!
                                            ? TextEnum.login.tr
                                            : TextEnum.signup.tr,
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () {
                                String message = '';
                                if (_controller.isLogin.value == null) {
                                  message =
                                      TextEnum.provideEmailResetPassword.tr;
                                } else {
                                  message = _controller.isLogin.value!
                                      ? TextEnum.provideEmailPasswordLoginApp.tr
                                      : TextEnum
                                          .provideEmailPasswordSignupApp.tr;
                                }
                                return CustomAnimatedSize(
                                  widthFactor: 1,
                                  alignment: Alignment.topCenter,
                                  child: CustomTextTitle.S(
                                    text: message,
                                  ),
                                );
                              },
                            ),
                            const CustomSize(),

                            //! Email
                            _Heading(TextEnum.email.tr),
                            OnTextInputWidgetUserField(
                              textEditingController: _controller.emailC,
                              showDetailError: true,
                              keyboardType: TextInputType.emailAddress,
                              hintText: TextEnum.enterYourEmail.tr,
                              svg: 'lib/assets/svg/icons/message_icon.svg',
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
                                          _Heading(TextEnum.password.tr),
                                          OnTextInputWidgetUserField(
                                            textEditingController:
                                                _controller.passwordC,
                                            obscureText: true,
                                            showDetailError: true,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            hintText:
                                                TextEnum.enterYourPassword.tr,
                                            svg:
                                                'lib/assets/svg/icons/lock_icon.svg',
                                            validator: (String? value) =>
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

                            Align(
                              child: Obx(
                                () => CustomAnimatedSize(
                                  widthFactor: 1,
                                  alignment: Alignment.bottomCenter,
                                  child: _controller.isLogin.value == null
                                      ? null
                                      : CustomTOCAndPP(
                                          value: _controller.isExcepted.value,
                                          onChanged: (bool value) => _controller
                                              .isExcepted.value = value,
                                        ),
                                ),
                              ),
                            ),

                            const CustomSize(),

                            //! Login Button
                            _Login(),
                            const CustomSize(fraction: 4),
                            _GroupButton(),

                            if (Platform.isAndroid)
                              Column(
                                children: <Widget>[
                                  const CustomSize(fraction: 3 / 4),
                                  const CustomDividedBar.or(),
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
              ? TextEnum.reset.tr
              : _controller.isLogin.value!
                  ? TextEnum.login.tr
                  : TextEnum.signup.tr,
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
                      child: Text(TextEnum.login.tr),
                    )
                  : !_controller.isLogin.value!
                      ? null
                      : CustomTextButton(
                          onDone: (_) => _controller.isLogin.value = null,
                          child: Text(TextEnum.forgotPassword.tr),
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
                      ? TextEnum.signup.tr
                      : TextEnum.alreadyHaveAccount.tr,
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
