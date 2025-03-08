import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components.dart';
import '../../controllers/screen_controllers/splash_screen_controller.dart';
import '../../models/localization/app_translations.dart';
import '../../utils/dev_functions/dev_scaffold.dart';
import '../widgets/loading_bar.dart';
import '../widgets/svg.dart';
import '../widgets/text.dart';

/// Splash Screen
class SplashScreen extends StatefulWidget {
  /// Splash Screen
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashScreenController _controller = Get.put(SplashScreenController());

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return DevScaffold(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        body: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: const Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _AppDetails(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _AppStatus(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppDetails extends StatelessWidget {
  const _AppDetails();

  final TextAlign textAlign = TextAlign.center;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Logo
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: theme.buttonTheme.height * 4),
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomSVG(
                'lib/assets/svg/logos/logo.svg',
                color: color,
              ),
            ),
          ),
          SizedBox(height: defaultPadding / 2),

          // Heading
          CustomTextHeading.S(
            text: appName,
            textAlign: textAlign,
            isBold: true,
            color: color,
          ),
          SizedBox(height: defaultPadding / 4),

          // Subheading
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: defaultMaxBoxWidth,
            ),
            child: CustomTextBody(
              text: appDescription,
              textAlign: textAlign,
              isBold: true,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppStatus extends StatelessWidget {
  const _AppStatus();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CustomCircularProgressBar(color: color),
        SizedBox(height: defaultPadding / 2),
        CustomTextBody.S(
          text: '${TextEnum.version.tr}: 1.0.0',
          isBold: true,
          color: color,
        ),
      ],
    );
  }
}
