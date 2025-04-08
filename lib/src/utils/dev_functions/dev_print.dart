// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';

/// Development Print. It will only print in debug mode.
/// With color and style.
void devPrint(
  dynamic message, {
  String heading = '',
  DevPrintColorEnum? color,
  bool isBold = false,
  bool isUnderline = false,
}) {
  if (!kDebugMode) return;

  String resetColor = '\x1B[0m';
  String bold = isBold ? '\x1B[1m' : '';
  String underline = isUnderline ? '\x1B[4m' : '';

  String log = '${DevPrintColorEnum.white.code}[Log] - $resetColor';

  try {
    String message_ = message.toString().trim();
    List<String> stringList = message_.split('\n');

    int count = 80;
    try {
      count = stdout.terminalColumns; // Getting terminal width
      count = count - heading.length - 2;
    } catch (_) {}
    String coloredString = '$log$bold$underline${color?.code ?? ''}';

    String lingDash = '-' * count;
    bool printDash = stringList.length > 1 || heading.isNotEmpty;
    if (printDash) {
      print(
        '''$coloredString$lingDash ${DevPrintColorEnum.yellow.code}$heading$resetColor''',
      );
    }

    for (final String string in stringList) {
      print('$coloredString$string$resetColor');
    }

    if (printDash) print('$coloredString$lingDash');
  } catch (e) {
    print('$log${DevPrintColorEnum.red.code}${e.toString()}$resetColor');
  }
}

/// Enum representing ANSI escape codes for coloring and formatting console
/// output.
///
/// Each value of [DevPrintColorEnum] corresponds to a specific ANSI escape code
/// that can be used to format text with colors in supported terminals.
enum DevPrintColorEnum {
  /// 🔴 Sets the text color to red. `ERROR`
  red('\x1B[31m'),

  /// 🟢 Sets the text color to green. `SUCCESSFUL`
  green('\x1B[32m'),

  /// 🟡 Sets the text color to yellow. `WARNING`
  yellow('\x1B[33m'),

  /// 🔵 Sets the text color to blue.
  blue('\x1B[34m'),

  /// 🟣 Sets the text color to magenta.
  magenta('\x1B[35m'),

  /// ⚫ Sets the text color to black.
  black('\x1B[30m'),

  /// ⚪ Sets the text color to white.
  white('\x1B[37m'),
  ;

  /// Constructor to associate an ANSI escape code with the enum value.
  ///
  /// Each enum value has a [code] property containing the escape code string.
  const DevPrintColorEnum(this.code);

  /// The ANSI escape code for this color or style.
  final String code;
}
