import 'package:flutter/material.dart';

TextStyle boldTextStyle({
  double size = 16,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.bold,
  TextDecoration? textDecoration,
}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: fontWeight,
    decoration: textDecoration,
  );
}

TextStyle primaryTextStyle({
  double size = 16,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.normal,
  TextOverflow overFlow = TextOverflow.ellipsis,
  TextDecoration? textDecoration,
}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: fontWeight,
    overflow: overFlow,
    decoration: textDecoration,
  );
}

TextStyle secondaryTextStyle({
  double size = 14,
  Color color = Colors.grey,
  FontWeight fontWeight = FontWeight.normal,
  TextDecoration? textDecoration,
}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: fontWeight,
    decoration: textDecoration,
  );
}
