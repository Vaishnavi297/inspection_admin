import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/constants/app_colors.dart';
import '../utils/extensions/context_extension.dart';

class LoaderView extends StatelessWidget {
  final double size;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? color;
  final Color? background;
  final bool withBackground;
  final String title;

  const LoaderView({
    super.key,
    this.size = 45,
    this.titleFontSize,
    this.titleFontWeight,
    this.color,
    this.background,
    this.withBackground = false,
    this.title = "",
  });

  @override
  Widget build(BuildContext context) {
    if (!withBackground) {
      return SpinKitWave(
        color: color ?? appColors.primaryColor,
        size: size,
        type: SpinKitWaveType.start,
      );
    } else {
      return Container(
        color: background ?? Colors.black38,
        height: context.height(),
        width: context.width(),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(
              color: color ?? appColors.primaryColor,
              size: size,
              type: SpinKitWaveType.start,
            ),
            if (title.isNotEmpty) ...[Text(title, textAlign: TextAlign.center)],
          ],
        ),
      );
    }
  }
}
