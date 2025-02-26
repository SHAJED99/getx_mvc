import 'package:flutter/material.dart';

//! -------------------------------------------------------------------- Heading
class CustomTextHeading extends StatelessWidget {
  const CustomTextHeading({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = null;
  const CustomTextHeading.L({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = true;
  const CustomTextHeading.S({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = false;

  final bool onPrimary;
  final String text;
  final TextAlign textAlign;
  final Color? color;
  final bool? _isBig;
  final bool isBold;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? textStyle = _isBig == null
        ? textTheme.headlineMedium
        : _isBig
            ? textTheme.headlineLarge
            : textTheme.headlineSmall;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: maxLine == null ? null : TextOverflow.ellipsis,
      style: textStyle?.copyWith(
        color: color ??
            (onPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface),
        fontWeight: !isBold ? null : FontWeight.bold,
      ),
    );
  }
}

//! ---------------------------------------------------------------------- Title
class CustomTextTitle extends StatelessWidget {
  const CustomTextTitle({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = null;
  const CustomTextTitle.L({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = true;
  const CustomTextTitle.S({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = false;

  final bool onPrimary;
  final String text;
  final TextAlign textAlign;
  final Color? color;
  final bool? _isBig;
  final bool isBold;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? textStyle = _isBig == null
        ? textTheme.titleMedium
        : _isBig
            ? textTheme.titleLarge
            : textTheme.titleSmall;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: maxLine == null ? null : TextOverflow.ellipsis,
      style: textStyle?.copyWith(
        color: color ??
            (onPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface),
        fontWeight: !isBold ? null : FontWeight.bold,
      ),
    );
  }
}

//! ----------------------------------------------------------------------- Body
class CustomTextBody extends StatelessWidget {
  const CustomTextBody({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = null;
  const CustomTextBody.L({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = true;
  const CustomTextBody.S({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = false;

  final bool onPrimary;
  final String text;
  final TextAlign textAlign;
  final Color? color;
  final bool? _isBig;
  final bool isBold;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? textStyle = _isBig == null
        ? textTheme.bodyMedium
        : _isBig
            ? textTheme.bodyLarge
            : textTheme.bodySmall;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: maxLine == null ? null : TextOverflow.ellipsis,
      style: textStyle?.copyWith(
        color: color ??
            (onPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface),
        fontWeight: !isBold ? null : FontWeight.bold,
      ),
    );
  }
}

//! ---------------------------------------------------------------------- Label
class CustomTextLabel extends StatelessWidget {
  const CustomTextLabel({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = null;
  const CustomTextLabel.L({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = true;
  const CustomTextLabel.S({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = false;

  final bool onPrimary;
  final String text;
  final TextAlign textAlign;
  final Color? color;
  final bool? _isBig;
  final bool isBold;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? textStyle = _isBig == null
        ? textTheme.labelMedium
        : _isBig
            ? textTheme.labelLarge
            : textTheme.labelSmall;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: maxLine == null ? null : TextOverflow.ellipsis,
      style: textStyle?.copyWith(
        color: color ??
            (onPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface),
        fontWeight: !isBold ? null : FontWeight.bold,
      ),
    );
  }
}

//! -------------------------------------------------------------------- Display
class CustomTextDisplay extends StatelessWidget {
  const CustomTextDisplay({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = null;
  const CustomTextDisplay.L({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = true;
  const CustomTextDisplay.S({
    super.key,
    this.onPrimary = false,
    required this.text,
    this.textAlign = TextAlign.start,
    this.color,
    this.isBold = false,
    this.maxLine,
  }) : _isBig = false;

  final bool onPrimary;
  final String text;
  final TextAlign textAlign;
  final Color? color;
  final bool? _isBig;
  final bool isBold;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme tT = theme.textTheme;
    final TextStyle? textStyle = _isBig == null
        ? tT.displayMedium
        : _isBig
            ? tT.displayLarge
            : tT.displaySmall;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: maxLine == null ? null : TextOverflow.ellipsis,
      style: textStyle?.copyWith(
        color: color ??
            (onPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface),
        fontWeight: !isBold ? null : FontWeight.bold,
      ),
    );
  }
}
