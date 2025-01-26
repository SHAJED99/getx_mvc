import 'package:flutter/material.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';

const double _defaultPadding = 24.0;

/// Button that is used in development
class DevButton extends StatelessWidget {
  /// Takes Widget and a onTap function
  const DevButton({super.key, this.child, this.onTap});

  /// Widget that will be showed in devButton
  final Widget? child;

  /// Function that will run when the devButton is precessed
  final Future<bool?>? Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return OnProcessButtonWidget(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: Alignment.center,
      constraints: const BoxConstraints(
        minHeight: _defaultPadding * 1.5,
        maxWidth: _defaultPadding * 1.5,
      ),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      child: child,
    );
  }
}
