import 'package:flutter/material.dart';

import '../../../components.dart';

class CustomCircularProgressBar extends StatelessWidget {
  const CustomCircularProgressBar(
      {super.key, this.color, this.size, this.value});
  final Color? color;
  final double? size;
  final double? value;

  @override
  Widget build(BuildContext context) {
    double widgetSize = size ?? defaultPadding;
    return SizedBox(
      width: widgetSize,
      height: widgetSize,
      child: FittedBox(
        child: CircularProgressIndicator(
          color: color ?? Theme.of(context).colorScheme.primary,
          value: value == null ? null : value! / 100,
        ),
      ),
    );
  }
}

// LinearProgressIndicator

class CustomLinearProgressBar extends StatelessWidget {
  const CustomLinearProgressBar(
      {super.key, this.color, this.size, this.show = true, this.value})
      : _opacity = 10;
  final Color? color;
  final double? size;
  final bool show;
  final double? value;

  const CustomLinearProgressBar.small(
      {super.key, this.color, this.size = 2, this.show = true, this.value})
      : _opacity = 1;

  final int _opacity;

  @override
  Widget build(BuildContext context) {
    double widgetSize = size ?? defaultPadding;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widgetSize / 2),
      ),
      height: widgetSize,
      child: show
          ? LinearProgressIndicator(
              value: value == null ? null : value! / 100,
              backgroundColor: Colors.transparent,
              color: color ??
                  Theme.of(context).colorScheme.primary.withAlpha(_opacity),
            )
          : null,
    );
  }
}
