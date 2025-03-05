import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_mvc/src/controllers/screen_controllers/authentication_wrapper_screen_controller.dart';
import 'package:getx_mvc/src/utils/dev_functions/dev_scaffold.dart';

import '../../../../components.dart';

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
  @override
  void initState() {
    super.initState();
    Get.put(AuthenticationWrapperScreenController());
  }

  @override
  Widget build(BuildContext context) {
    return DevScaffold(
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
                  child: Column(
                    children: <Widget>[],
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
