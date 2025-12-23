import 'package:flutter/material.dart';
import '../../utils/common/decoration.dart';
import '../../utils/common/responsive_widget.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../app_text_style/app_text_style.dart';

/// A custom reusable dialog widget with dark theme and customizable content
class AppCustomDialog extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconBackgroundColor;
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Color? primaryButtonColor;
  final bool showIcon;

  const AppCustomDialog({
    super.key,
    this.icon,
    this.iconWidget,
    this.iconBackgroundColor,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.primaryButtonColor,
    this.showIcon = true,
  }) : assert(icon != null || iconWidget != null || !showIcon, 'Either icon or iconWidget must be provided if showIcon is true');

  /// Show the dialog with a static method for easy usage
  static Future<T?> show<T>({
    required BuildContext context,
    IconData? icon,
    Widget? iconWidget,
    Color? iconBackgroundColor,
    required String title,
    required String message,
    required String primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    Color? primaryButtonColor,
    bool showIcon = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AppCustomDialog(
        icon: icon,
        iconWidget: iconWidget,
        iconBackgroundColor: iconBackgroundColor,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        primaryButtonColor: primaryButtonColor,
        showIcon: showIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: ResponsiveWidget.isMediumScreen(context) ? 300 : 400,
        padding: const EdgeInsets.all(24),
        decoration: boxDecorationWithRoundedCorners(backgroundColor: appColors.surfaceColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (showIcon) ...[
              Container(
                width: 64,
                height: 64,
                decoration: boxDecorationWithRoundedCorners(backgroundColor: iconBackgroundColor ?? appColors.red, boxShape: BoxShape.circle),
                child: iconWidget ?? Icon(icon ?? Icons.info_outline, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
            ],

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: boldTextStyle(size: FontSize.s20),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: secondaryTextStyle(size: FontSize.s14),
            ),
            const SizedBox(height: 24),

            // Primary Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor ?? appColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  primaryButtonText,
                  style: boldTextStyle(size: FontSize.s16, color: Colors.white),
                ),
              ),
            ),

            // Secondary Button
            if (secondaryButtonText != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Text(
                  secondaryButtonText!,
                  style: primaryTextStyle(size: FontSize.s14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-built logout confirmation dialog
class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onCancel;

  const LogoutConfirmationDialog({super.key, this.onLogout, this.onCancel});

  static Future<bool?> show({required BuildContext context, VoidCallback? onLogout, VoidCallback? onCancel}) {
    return AppCustomDialog.show<bool>(
      context: context,
      icon: Icons.logout_rounded,
      iconBackgroundColor: appColors.red,
      title: 'Already leaving?',
      message: 'We\'ll keep an eye on your rewards and coins while you\'re gone. And we will miss you a lot.',
      primaryButtonText: 'Yes, Log out',
      secondaryButtonText: 'No, I am staying',
      primaryButtonColor: appColors.red,
      onPrimaryPressed:
          onLogout ??
          () {
            Navigator.of(context).pop(true);
          },
      onSecondaryPressed:
          onCancel ??
          () {
            Navigator.of(context).pop(false);
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCustomDialog(
      icon: Icons.logout_rounded,
      iconBackgroundColor: appColors.red,
      title: 'Already leaving?',
      message: 'We\'ll keep an eye on your rewards and coins while you\'re gone. And we will miss you a lot.',
      primaryButtonText: 'Yes, Log out',
      secondaryButtonText: 'No, I am staying',
      primaryButtonColor: appColors.red,
      onPrimaryPressed:
          onLogout ??
          () {
            Navigator.of(context).pop(true);
          },
      onSecondaryPressed:
          onCancel ??
          () {
            Navigator.of(context).pop(false);
          },
    );
  }
}
