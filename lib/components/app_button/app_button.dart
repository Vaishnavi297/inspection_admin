import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/app_dimension.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/extensions/context_extension.dart';

import '../loader_view.dart';
import '../my_bounce.dart';

// ignore: must_be_immutable
class AppButton extends StatelessWidget {
  Function()? onTap;
  Widget? btnWidget;
  String? strTitle;
  FontWeight? fontWeight;
  double? fontSize = FontSize.s15;
  Color? fontColor;
  Color? backgroundColor;
  TextAlign? textAlign = TextAlign.center;
  bool? isBorderEnable;
  Color? borderColor;
  bool? isShadow;
  bool? isDisable;
  bool? isButtonLoading;
  final bool isLoading;
  Color? loaderColor;
  double? height;
  double? width;
  double? radius;

  AppButton({
    super.key,
    this.onTap,
    this.btnWidget,
    this.strTitle,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.fontColor,
    this.backgroundColor,
    this.textAlign,
    this.isBorderEnable = false,
    this.isShadow = false,
    this.isDisable,
    this.isButtonLoading = false,
    this.borderColor,
    this.loaderColor,
    this.isLoading = false,
    this.height,
    this.width,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return isButtonLoading == true
        ? const LoaderView()
        : Bounce(
            duration: Duration(milliseconds: isDisable == null || isDisable == false ? 110 : 0),
            onPressed: () {
              if (isDisable == null || isDisable == false) {
                if (onTap != null) {
                  onTap!();
                }
              }
            },
            isDisable: isDisable ?? false,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: s.s8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? s.s10),
                color: isDisable == null || isDisable == false ? (backgroundColor ?? appColors.primaryColor) : Colors.grey,
                border: isBorderEnable != null ? (isBorderEnable! ? Border.all(color: borderColor == null ? appColors.primaryColor : borderColor!, width: 1) : null) : null,
                boxShadow: isShadow == null || isShadow == true ? [BoxShadow(color: Colors.grey.withAlpha(50), blurRadius: 2.0, spreadRadius: 2, offset: const Offset(0, 2))] : null,
              ),
              height: height ?? s.s40,
              width: width ?? context.width(),
              child: Align(
                alignment: Alignment.center,
                child: FittedBox(
                  child: isLoading
                      ? LoaderView(color: appColors.white)
                      : btnWidget ??
                            Text(
                              strTitle!,
                              // ignore: deprecated_member_use
                              textScaleFactor: 1.0,
                              textAlign: textAlign ?? TextAlign.center,
                              style: GoogleFonts.ptSans(
                                decoration: TextDecoration.none,
                                fontWeight: fontWeight ?? FontWeight.w500,
                                fontSize: fontSize ?? FontSize.s16,
                                color: fontColor == null ? appColors.white : fontColor!,
                              ),
                            ),
                ),
              ),
            ),
          );
  }
}
