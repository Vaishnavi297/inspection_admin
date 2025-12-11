// Widget Extensions
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

extension WidgetExtension on Widget? {
  /// WITH CUSTOM HEIGHT AND WIDTH
  SizedBox withSize({double width = 0.0, double height = 0.0}) {
    return SizedBox(height: height, width: width, child: this);
  }

  /// WITH CUSTOM WIDTH
  SizedBox withWidth(double width) => SizedBox(width: width, child: this);

  /// WITH CUSTOM HEIGHT
  SizedBox withHeight(double height) => SizedBox(height: height, child: this);

  /// RETURN PADDING TOP
  Padding paddingTop(double top) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: this,
    );
  }

  /// RETURN PADDING LEFT
  Padding paddingLeft(double left) {
    return Padding(
      padding: EdgeInsets.only(left: left),
      child: this,
    );
  }

  /// RETURN PADDING RIGHT
  Padding paddingRight(double right) {
    return Padding(
      padding: EdgeInsets.only(right: right),
      child: this,
    );
  }

  /// RETURN PADDING BOTTOM
  Padding paddingBottom(double bottom) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: this,
    );
  }

  /// RETURN PADDING ALL
  Padding paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  /// RETURN CUSTOM PADDING FROM EACH SIDE
  Padding paddingOnly({
    double top = 0.0,
    double left = 0.0,
    double bottom = 0.0,
    double right = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: this,
    );
  }

  /// RETURN PADDING SYMMETRIC
  Padding paddingSymmetric({double vertical = 0.0, double horizontal = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// SET VISIBILITY
  Widget visible(bool visible, {Widget? defaultWidget}) {
    return visible ? this! : (defaultWidget ?? const SizedBox());
  }

  /// ADD CUSTOM CORNER RADIUS EACH SIDE
  ClipRRect cornerRadiusWithClipRRectOnly({
    int bottomLeft = 0,
    int bottomRight = 0,
    int topLeft = 0,
    int topRight = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(bottomLeft.toDouble()),
        bottomRight: Radius.circular(bottomRight.toDouble()),
        topLeft: Radius.circular(topLeft.toDouble()),
        topRight: Radius.circular(topRight.toDouble()),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  /// ADD CORNER RADIUS
  ClipRRect cornerRadiusWithClipRRect(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  /// SET WIDGET VISIBILITY
  @Deprecated('')
  Visibility withVisibility(
    bool visible, {
    Widget? replacement,
    bool maintainAnimation = false,
    bool maintainState = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
  }) {
    return Visibility(
      visible: visible,
      maintainAnimation: maintainAnimation,
      maintainInteractivity: maintainInteractivity,
      maintainSemantics: maintainSemantics,
      maintainSize: maintainSize,
      maintainState: maintainState,
      replacement: replacement ?? const SizedBox(),
      child: this!,
    );
  }

  /// ADD OPACITY TO PARENT WIDGET
  Widget opacity({
    required double opacity,
    int durationInSecond = 1,
    Duration? duration,
  }) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration ?? const Duration(milliseconds: 500),
      child: this,
    );
  }

  /// ADD ROTATION TO PARENT WIDGET
  Widget rotate({
    required double angle,
    bool transformHitTests = true,
    Offset? origin,
  }) {
    return Transform.rotate(
      origin: origin,
      angle: angle,
      transformHitTests: transformHitTests,
      child: this,
    );
  }

  /// ADD SCALING TO PARENT WIDGET
  Widget scale({
    required double scale,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
  }) {
    return Transform.scale(
      scale: scale,
      origin: origin,
      alignment: alignment,
      transformHitTests: transformHitTests,
      child: this,
    );
  }

  /// ADD TRANSLATE TO PARENT WIDGET
  Widget translate({
    required Offset offset,
    bool transformHitTests = true,
    Key? key,
  }) {
    return Transform.translate(
      offset: offset,
      transformHitTests: transformHitTests,
      key: key,
      child: this,
    );
  }

  /// SET PARENT WIDGET IN CENTER
  Widget center({double? heightFactor, double? widthFactor}) {
    return Center(
      heightFactor: heightFactor,
      widthFactor: widthFactor,
      child: this,
    );
  }

  /// WRAP WITH SHADER MASK WIDGET
  Widget withShaderMask(
    List<Color> colors, {
    BlendMode blendMode = BlendMode.srcATop,
  }) {
    return withShaderMaskGradient(
      LinearGradient(colors: colors),
      blendMode: blendMode,
    );
  }

  /// WRAP WITH SHADER MASK WIDGET GRADIENT
  Widget withShaderMaskGradient(
    Gradient gradient, {
    BlendMode blendMode = BlendMode.srcATop,
  }) {
    return ShaderMask(
      shaderCallback: (rect) => gradient.createShader(rect),
      blendMode: blendMode,
      child: this,
    );
  }

  // ignore: provide_deprecation_message
  @deprecated
  Widget withScroll({
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool? primary,
    required bool reverse,
  }) {
    return SingleChildScrollView(
      physics: physics,
      padding: padding,
      scrollDirection: scrollDirection,
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      primary: primary,
      reverse: reverse,
      child: this,
    );
  }

  /// ADD EXPANDED TO PARENT WIDGET
  // ignore: strict_top_level_inference
  Widget expand({flex = 1}) => Expanded(flex: flex, child: this!);

  /// ADD FLEXIBLE TO PARENT WIDGET
  // ignore: strict_top_level_inference
  Widget flexible({flex = 1, FlexFit? fit}) {
    return Flexible(flex: flex, fit: fit ?? FlexFit.loose, child: this!);
  }

  /// ADD FITTED BOX TO PARENT WIDGET
  Widget fit({BoxFit? fit, AlignmentGeometry? alignment}) {
    return FittedBox(
      fit: fit ?? BoxFit.contain,
      alignment: alignment ?? Alignment.center,
      child: this,
    );
  }

  /// VALIDATE GIVEN WIDGET IS NOT NULL AND RETURNS GIVEN VALUE IF NULL
  Widget validate({Widget value = const SizedBox()}) => this ?? value;

  @Deprecated('Use withTooltip() instead')
  Widget tooltip({required String msg}) {
    return Tooltip(message: msg, child: this);
  }

  /// VALIDATE GIVEN WIDGET IS NOT NULL AND RETURNS GIVEN VALUE IF NULL
  Widget withTooltip({required String msg}) {
    return Tooltip(message: msg, child: this);
  }

  /// MAKE YOUR ANY WIDGET REFRESHABLE WITH REFRESH INDICATOR ON TOP
  Widget get makeRefreshable {
    return Stack(children: [ListView(), this!]);
  }
}
