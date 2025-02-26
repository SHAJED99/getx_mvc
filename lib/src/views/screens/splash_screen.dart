import 'package:flutter/material.dart';
import 'package:getx_mvc/src/utils/dev_functions/dev_scaffold.dart';

/// Splash Screen
class SplashScreen extends StatefulWidget {
  /// Splash Screen
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return const DevScaffold(
      child: Scaffold(
        body: Center(
          child: Text('Splash Screen'),
        ),
      ),
    );
  }
}
