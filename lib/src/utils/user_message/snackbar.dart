import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../components.dart';

/// Displays a snackbar with the specified parameters.
///
/// The snackbar will display the provided [title] and [message].
/// An optional [completer] can be passed to control the completion of the
/// snackbar.
/// The [animationDuration] specifies the duration of the snackbar animation.
/// The [icon] is displayed alongside the message.
/// The [snackPosition] specifies the position of the snackbar.
/// The [padding] specifies the padding inside the snackbar.
/// The [mainButton] is an optional button displayed inside the snackbar.
///
/// Parameters:
/// - [title]: The title of the snackbar.
/// - [message]: The message content of the snackbar.
/// - [icon]: The icon displayed alongside the message.
/// - [snackPosition]: The position of the snackbar.
/// - [snackbarStatus]: Callback for snackbar status changes.
/// - [mainButton]: An optional button displayed inside the snackbar.
/// - [duration]: The duration the snackbar is displayed.
/// - [animationDuration]: The duration of the snackbar animation.
/// - [completer]: An optional completer to control the snackbar's completion.
/// - [padding]: The padding inside the snackbar.
/// - [margin]: The margin around the snackbar.
/// - [child]: An optional widget to display inside the snackbar.
Future<void> showSnackBar({
  required String title,
  required String message,
  Widget? icon,
  SnackPosition snackPosition = SnackPosition.TOP,
  void Function(SnackbarStatus? status)? snackbarStatus,
  TextButton? mainButton,
  Duration duration = const Duration(seconds: 5),
  Duration? animationDuration,
  Completer<void>? completer,
  EdgeInsets? padding,
  EdgeInsets? margin,
  Widget? child,
}) async {
  final Completer<void> c = completer ?? Completer<void>();
  if (Get.isSnackbarOpen) Get.closeAllSnackbars();

  final ThemeData theme = Get.theme;
  final ColorScheme colorScheme = theme.colorScheme;
  final TextTheme textTheme = theme.textTheme;

  Get.snackbar(
    title,
    message,
    messageText: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        if (child != null)
          Padding(
            padding: EdgeInsets.only(top: defaultPadding / 4),
            child: child,
          ),
      ],
    ),
    icon: icon,
    borderRadius: defaultPadding / 2,
    padding: padding ?? EdgeInsets.all(defaultPadding),
    margin: margin ?? EdgeInsets.all(defaultPadding),
    snackPosition: snackPosition,
    snackbarStatus: (SnackbarStatus? status) async {
      if (snackbarStatus != null) snackbarStatus(status);
      if (status == SnackbarStatus.CLOSED && !c.isCompleted) {
        c.complete();
      }
    },
    colorText: theme.colorScheme.onPrimaryContainer,
    maxWidth: defaultMaxBoxWidth,
    backgroundColor: theme.colorScheme.primaryContainer.withAlpha(200),
    mainButton: mainButton,
    duration: duration,
    animationDuration: animationDuration,
  );

  await c.future;
}

/// Displays a toast message.
///
/// The toast will display the provided [title] and [message].
/// The toast is displayed on Android, iOS, and Web platforms.
/// On other platforms, a snackbar is displayed instead.
///
/// Parameters:
/// - [title]: The title of the toast.
/// - [message]: The message content of the toast.
void showToast({String? title, required String message}) {
  bool isAndroid = (Platform.isAndroid || kIsWeb);
  bool isIOS = Platform.isIOS;
  bool isWeb = kIsWeb;

  if (isAndroid || isIOS || isWeb) {
    Fluttertoast.showToast(
      msg: "${title == null ? "" : "$title:"} $message",
      toastLength: Toast.LENGTH_LONG,
    );
  } else {
    showSnackBar(title: title ?? 'Message', message: message);
  }
}

/// Displays a confirmation message using a snackbar.
///
/// The snackbar will display the [heading] and [message] provided.
/// An optional [completer] can be passed to control the completion of the
/// snackbar.
///
/// The snackbar will have an "Undo" button which, when pressed, will set the
/// return value to `false` and close the snackbar.
///
/// Returns `true` if the snackbar is not dismissed by the "Undo" button,
/// otherwise returns `false`.
///
/// Parameters:
/// - [heading]: The title of the snackbar.
/// - [message]: The message content of the snackbar.
/// - [completer]: An optional completer to control the snackbar's completion.
Future<bool> showConfirmationMessage({
  required String heading,
  required String message,
  Completer<void>? completer,
}) async {
  final Completer<bool> resultCompleter = Completer<bool>();
  await showSnackBar(
    completer: completer,
    animationDuration: const Duration(milliseconds: 100),
    icon: const Icon(Icons.info),
    title: heading,
    message: message,
    snackPosition: SnackPosition.BOTTOM,
    padding: EdgeInsets.symmetric(
      horizontal: defaultPadding / 2,
      vertical: defaultPadding,
    ),
    mainButton: TextButton(
      onPressed: () {
        resultCompleter.complete(false);
        Get.closeCurrentSnackbar();
      },
      child: const Text(
        'Undo',
        style: TextStyle(color: Colors.green),
      ),
    ),
  );

  if (!resultCompleter.isCompleted) {
    resultCompleter.complete(true);
  }

  return resultCompleter.future;
}
