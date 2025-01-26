import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dev_button.dart';

/// Button that is used in development auto fill purpose.
///
/// Functions will be showed according to their index
class DevAutoFillButton extends StatelessWidget {
  /// Button that is used in development. Takes onPress function list
  const DevAutoFillButton({
    super.key,
    this.onPressed = const <void Function()>[],
  });

  /// OnPressed function list
  final List<void Function()> onPressed;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox();

    return SizedBox(
      height: Theme.of(context).buttonTheme.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          for (int i = 0; i < onPressed.length; i++)
            DevButton(
              onTap: () {
                onPressed.elementAt(i)();
                return;
              },
              child: Text(i.toString()),
            ),
        ],
      ),
    );
  }
}
