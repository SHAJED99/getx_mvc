// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_mvc/src/core/theme/app_theme.dart';

/// Relative luminance per WCAG 2.1.
double _luminance(Color c) {
  double channel(double v) => v <= 0.03928
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two opaque colors.
double _contrastRatio(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Renders a [Scaffold] under the app theme and returns the theme actually
/// resolved below `MaterialApp`, which is where `ThemeData.localize` has
/// applied the text geometry.
Future<ThemeData> _resolveTheme(
  WidgetTester tester,
  ThemeMode themeMode,
) async {
  late ThemeData resolved;

  await tester.pumpWidget(
    ScreenUtilInit(
      // Mirrors main.dart, where this makes `.sp` an identity function.
      fontSizeResolver: (num fontSize, _) => fontSize.toDouble(),
      designSize: const Size(360, 690),
      builder: (BuildContext context, Widget? child) => MaterialApp(
        theme: AppTheme.theme(),
        darkTheme: AppTheme.theme(brightness: Brightness.dark),
        themeMode: themeMode,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext inner) {
              resolved = Theme.of(inner);
              return const Text('probe');
            },
          ),
        ),
      ),
    ),
  );
  // MaterialApp animates theme changes through AnimatedTheme, so a single
  // pump would observe an interpolated theme when this runs twice in one test.
  await tester.pumpAndSettle();

  return resolved;
}

void main() {
  group('AppTheme text legibility', () {
    // Regression guard: the text theme used to be seeded from
    // `Theme.of(context)` resolved above GetMaterialApp, which is the light
    // fallback theme. Its baked-in near-black colors then overrode the dark
    // theme's typography, leaving dark-mode body text at 1.08:1.
    for (final (String label, ThemeMode mode, Brightness brightness) in <
        (String, ThemeMode, Brightness)>[
      ('light', ThemeMode.light, Brightness.light),
      ('dark', ThemeMode.dark, Brightness.dark),
    ]) {
      testWidgets('$label theme text is readable on its own surface', (
        WidgetTester tester,
      ) async {
        final ThemeData theme = await _resolveTheme(tester, mode);

        expect(theme.brightness, brightness);

        final ColorScheme scheme = theme.colorScheme;
        final Map<String, TextStyle?> slots = <String, TextStyle?>{
          'displayLarge': theme.textTheme.displayLarge,
          'titleLarge': theme.textTheme.titleLarge,
          'bodyMedium': theme.textTheme.bodyMedium,
          'labelSmall': theme.textTheme.labelSmall,
        };

        for (final MapEntry<String, TextStyle?> slot in slots.entries) {
          final TextStyle? style = slot.value;
          expect(style, isNotNull, reason: '${slot.key} is missing');

          // Geometry is applied by ThemeData.localize below MaterialApp.
          expect(
            style!.fontSize,
            isNotNull,
            reason: '${slot.key} has no font size',
          );

          expect(
            style.color,
            isNotNull,
            reason: '${slot.key} has no color',
          );

          expect(
            _contrastRatio(style.color!, scheme.surface),
            greaterThanOrEqualTo(4.5),
            reason: '${slot.key} fails WCAG AA against the $label surface',
          );
        }
      });
    }

    testWidgets('each theme uses its own onSurface, not the other\'s', (
      WidgetTester tester,
    ) async {
      final ThemeData light = await _resolveTheme(tester, ThemeMode.light);
      final Color lightColor = light.textTheme.bodyMedium!.color!;
      final Color lightOnSurface = light.colorScheme.onSurface;

      final ThemeData dark = await _resolveTheme(tester, ThemeMode.dark);
      final Color darkColor = dark.textTheme.bodyMedium!.color!;
      final Color darkOnSurface = dark.colorScheme.onSurface;

      expect(lightColor, lightOnSurface);
      expect(darkColor, darkOnSurface);
      expect(lightColor, isNot(darkColor));
    });
  });
}
