import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Custom SVG widget
class CustomSVG extends StatelessWidget {
  /// Custom SVG widget
  const CustomSVG(
    this.svgLink, {
    super.key,
    this.color,
    this.onPrimary = false,
  });

  /// SVG asset link
  final String svgLink;

  /// Color of the SVG
  final Color? color;

  /// If the color is on primary
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme c = Theme.of(context).colorScheme;
    return SvgPicture.asset(
      svgLink,
      colorFilter: ColorFilter.mode(
        color ?? (onPrimary ? c.onPrimary : c.onSurface),
        BlendMode.srcIn,
      ),
    );
  }
}
