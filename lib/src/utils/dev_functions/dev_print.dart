// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Development Print
void devPrint(
  dynamic message, {
  DevPrintColorEnum color = DevPrintColorEnum.green,
}) {
  if (!kDebugMode) return;

  try {
    String message_ = message.toString().trim();
    List<String> stringList = message_.split('\n');

    for (final String string in stringList) {
      print('${color.code}[Log] - $string${DevPrintColorEnum.reset.code}');
    }
  } catch (_) {}
}

/// Enum representing ANSI escape codes for coloring and formatting console output.
///
/// Each value of [DevPrintColorEnum] corresponds to a specific ANSI escape code
/// that can be used to format text with colors or styles in supported terminals.
enum DevPrintColorEnum {
  /// Resets all text formatting to default.
  reset('\x1B[0m'),

  /// Sets the text color to red.
  red('\x1B[31m'),

  /// Sets the text color to green.
  green('\x1B[32m'),

  /// Sets the text color to yellow.
  yellow('\x1B[33m'),

  /// Sets the text color to blue.
  blue('\x1B[34m'),

  /// Sets the text color to magenta.
  magenta('\x1B[35m'),

  /// Sets the text color to cyan.
  cyan('\x1B[36m'),

  /// Sets the text color to white.
  white('\x1B[37m'),

  // --- Additional Formatting ---

  /// Makes the text bold.
  bold('\x1B[1m'),

  /// Underlines the text.
  underline('\x1B[4m');

  /// Constructor to associate an ANSI escape code with the enum value.
  ///
  /// Each enum value has a [code] property containing the escape code string.
  const DevPrintColorEnum(this.code);

  /// The ANSI escape code for this color or style.
  final String code;
}
