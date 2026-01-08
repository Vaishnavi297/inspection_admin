import '../../utils/constants/app_dimension.dart';
import '../app_text_style/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_colors.dart';

Widget textField({
  TextEditingController? controller,
  bool obscureText = false,
  bool readOnly = false,
  TextInputType? inputType,
  String? Function(String?)? validator,
  Widget? prefixIcon,
  Widget? prefix,
  Widget? suffixIcon,
  InputBorder? border,
  InputBorder? enabledBorder,
  InputBorder? focusedBorder,
  InputBorder? errorBorder,
  String? labelText,
  String? hintText,
  bool isMandatory = true,
  bool isFilled = true,
  int? maxLength,
  double topPadding = 20.0,
  TextInputAction tia = TextInputAction.next,
  List<String>? autofillHints,
  int? maxLines,
  int? minLines,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  TextStyle? labelStyle,
  TextStyle? style,
  void Function()? onTap,
  void Function(String?)? onChanged,
  bool isEditable = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (labelText != null && labelText.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(top: topPadding, bottom: 12),
          child: RichText(
            text: TextSpan(
              text: labelText,
              style: labelStyle ?? GoogleFonts.ptSans(fontSize: FontSize.s14, color: appColors.textSecondaryColor, fontWeight: FontWeight.w500),
              children: [
                // TextSpan(
                //   text: isMandatory ? ' *' : '',
                //   style: TextStyle(color: AppColors().red),
                // ),
              ],
            ),
          ),
        ),
      TextFormField(
        maxLength: maxLength,
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        autofocus: false,
        autovalidateMode: autovalidateMode,
        keyboardType: inputType,
        autofillHints: autofillHints,
        textInputAction: tia,
        enabled: isEditable,
        validator: validator,
        decoration: defaultInputDecoration(suffixIcon: suffixIcon, hintText: hintText, isFilled: isFilled, radius: s.s10, prefix: prefix),
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        style: style ?? primaryTextStyle(overFlow: TextOverflow.ellipsis),
        textCapitalization: (inputType == TextInputType.emailAddress) || obscureText ? TextCapitalization.none : textCapitalization,
        onTap: onTap,
      ),
    ],
  );
}

InputDecoration defaultInputDecoration({
  String? labelText,
  String? hintText,
  String? errorText,
  Widget? suffixIcon,
  String? counterText,
  bool? isFilled,
  double? radius,
  Widget? prefix,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : prefix,
    isDense: true,
    contentPadding: EdgeInsets.all(12),
    fillColor: AppColors().surfaceColor,
    filled: isFilled,
    errorText: errorText,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: appColors.gray, width: 0.5),
      borderRadius: BorderRadius.circular(radius ?? appConstants.defaultRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: appColors.primaryColor),
      borderRadius: BorderRadius.circular(radius ?? appConstants.defaultRadius),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: appColors.gray, width: 0.5),
      borderRadius: BorderRadius.circular(radius ?? appConstants.defaultRadius),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: appColors.errorColor),
      borderRadius: BorderRadius.circular(radius ?? appConstants.defaultRadius),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade50),
      borderRadius: BorderRadius.circular(radius ?? appConstants.defaultRadius),
    ),
    counterText: counterText ?? '',
    hintText: hintText,
    hintStyle: secondaryTextStyle(fontWeight: FontWeight.w400),
    errorMaxLines: 2,
    suffixIcon: suffixIcon,
  );
}
