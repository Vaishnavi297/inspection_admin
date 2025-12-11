import 'package:flutter/material.dart';

import 'common.dart';

/// RETURNS DEFAULT INPUT DECORATION FOR APP TEXTFIELD WIDGET
InputDecoration defaultInputDecoration({
  String? hint,
  String? label,
  TextStyle? textStyle,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: textStyle ?? const TextStyle(),
    labelStyle: textStyle ?? const TextStyle(),
    border: const OutlineInputBorder(),
    alignLabelWithHint: true,
  );
}

/// RETURNS RADIUS
BorderRadius radius([double? radius]) {
  return BorderRadius.all(radiusCircular(radius ?? defaultRadius));
}

/// RETURN RADIUS CIRCULAR
Radius radiusCircular([double? radius]) {
  return Radius.circular(radius ?? defaultRadius);
}

/// RETURN THE DIALOG SHAPE
ShapeBorder dialogShape([double? borderRadius]) {
  return RoundedRectangleBorder(
    borderRadius: radius(borderRadius ?? defaultRadius),
  );
}

/// RETURN CUSTOM RADIUS ON EACH SIDE
BorderRadius radiusOnly({
  double? topRight,
  double? topLeft,
  double? bottomRight,
  double? bottomLeft,
}) {
  return BorderRadius.only(
    topRight: radiusCircular(topRight ?? 0),
    topLeft: radiusCircular(topLeft ?? 0),
    bottomRight: radiusCircular(bottomRight ?? 0),
    bottomLeft: radiusCircular(bottomLeft ?? 0),
  );
}

/// DEFAULT BOX DECORATION FOR THE CONTAINER WIDGET
Decoration boxDecorationDefault({
  BorderRadiusGeometry? borderRadius,
  Color? color,
  Gradient? gradient,
  BoxBorder? border,
  BoxShape? shape,
  BlendMode? backgroundBlendMode,
  List<BoxShadow>? boxShadow,
  DecorationImage? image,
}) {
  return BoxDecoration(
    borderRadius: (shape != null && shape == BoxShape.circle)
        ? null
        : (borderRadius ?? radius()),
    boxShadow: boxShadow ?? defaultBoxShadow(),
    color: color ?? Colors.white,
    gradient: gradient,
    border: border,
    shape: shape ?? BoxShape.rectangle,
    backgroundBlendMode: backgroundBlendMode,
    image: image,
  );
}

/// ROUNDED BOX DECORATION FOR THE CONTAINER
Decoration boxDecorationWithRoundedCorners({
  Color backgroundColor = Colors.white,
  BorderRadius? borderRadius,
  LinearGradient? gradient,
  BoxBorder? border,
  List<BoxShadow>? boxShadow,
  DecorationImage? decorationImage,
  BoxShape boxShape = BoxShape.rectangle,
}) {
  return BoxDecoration(
    color: backgroundColor,
    borderRadius: boxShape == BoxShape.circle
        ? null
        : (borderRadius ?? radius()),
    gradient: gradient,
    border: border,
    boxShadow: boxShadow,
    image: decorationImage,
    shape: boxShape,
  );
}

/// BOX DECORATION WITH SHADOW FOR THE CONTAINER WIDGET
Decoration boxDecorationWithShadow({
  Color backgroundColor = Colors.white,
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
  LinearGradient? gradient,
  BoxBorder? border,
  List<BoxShadow>? boxShadow,
  DecorationImage? decorationImage,
  BoxShape boxShape = BoxShape.rectangle,
  BorderRadius? borderRadius,
}) {
  return BoxDecoration(
    boxShadow:
        boxShadow ??
        defaultBoxShadow(
          shadowColor: shadowColor,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
    color: backgroundColor,
    gradient: gradient,
    border: border,
    image: decorationImage,
    shape: boxShape,
    borderRadius: borderRadius,
  );
}

/// ROUNDED BOX WITH SHADOW DECORATION FOR THE CONTAINER WIDGET
Decoration boxDecorationRoundedWithShadow(
  int radiusAll, {
  Color backgroundColor = Colors.white,
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
  LinearGradient? gradient,
}) {
  return BoxDecoration(
    boxShadow: defaultBoxShadow(
      shadowColor: shadowColor ?? shadowColorGlobal,
      blurRadius: blurRadius ?? defaultBlurRadius,
      spreadRadius: spreadRadius ?? defaultSpreadRadius,
      offset: offset,
    ),
    color: backgroundColor,
    gradient: gradient,
    borderRadius: radius(radiusAll.toDouble()),
  );
}

/// DEFAULT BOX SHADOW FOR THE CONTAINER WIDGET
List<BoxShadow> defaultBoxShadow({
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
}) {
  return [
    BoxShadow(
      color: shadowColor ?? shadowColorGlobal,
      blurRadius: blurRadius ?? defaultBlurRadius,
      spreadRadius: spreadRadius ?? defaultSpreadRadius,
      offset: offset,
    ),
  ];
}
