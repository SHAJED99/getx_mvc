part of 'app_theme.dart';

/// App theme text style. Text style will be added there.
/// Use
class AppTextStyles {
  /// Builds the text theme for [colorScheme].
  ///
  /// The base is taken from [Typography] rather than `Theme.of(context)`,
  /// because this runs while the theme is still being constructed — the only
  /// ancestor theme available there is the light fallback, whose text styles
  /// carry baked-in near-black colors that would then override the dark
  /// theme's own typography.
  static TextTheme _textTheme(ColorScheme colorScheme) {
    final Typography typography = Typography.material2021(
      colorScheme: colorScheme,
    );

    TextTheme baseTextTheme = (colorScheme.brightness == Brightness.dark
            ? typography.white
            : typography.black)
        .apply(fontSizeFactor: 1.sp);

    TextTheme bodyTextTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);
    TextTheme displayTextTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);

    TextTheme textTheme = displayTextTheme.copyWith(
      bodyLarge: bodyTextTheme.bodyLarge,
      bodyMedium: bodyTextTheme.bodyMedium,
      bodySmall: bodyTextTheme.bodySmall,
      labelLarge: bodyTextTheme.labelLarge,
      labelMedium: bodyTextTheme.labelMedium,
      labelSmall: bodyTextTheme.labelSmall,
    );
    return textTheme;
  }
}
