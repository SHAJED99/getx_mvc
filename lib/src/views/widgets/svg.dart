import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSVG extends StatelessWidget {
  const CustomSVG(this.svgLink,
      {super.key, this.color, this.onPrimary = false});
  final String svgLink;
  final Color? color;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme c = Theme.of(context).colorScheme;
    return SvgPicture.asset(
      svgLink,
      colorFilter: ColorFilter.mode(
          color ?? (onPrimary ? c.onPrimary : c.onSurface), BlendMode.srcIn),
    );
  }
}
