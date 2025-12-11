import 'package:flutter/widgets.dart';

extension DoubleExtension on num {
  SizedBox height() => SizedBox(height: toDouble());
  SizedBox width() => SizedBox(width: toDouble());

}
