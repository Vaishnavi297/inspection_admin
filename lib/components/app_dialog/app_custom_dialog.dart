import 'package:flutter/material.dart';
import '../../utils/common/decoration.dart';
import '../../utils/common/responsive_widget.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../app_text_style/app_text_style.dart';

/// A reusable, safe dialog widget.
/// - Dialog ALWAYS closes itself
/// - Callers NEVER call Navigator.pop()
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
  }) : assert(
         icon != null || iconWidget != null || !showIcon,
         'Either icon or iconWidget must be provided if showIcon is true',
       );

  /// Show dialog helper
  static Future<bool?> show({
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
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) {
        return AppCustomDialog(
          icon: icon,
          iconWidget: iconWidget,
          iconBackgroundColor: iconBackgroundColor,
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          primaryButtonColor: primaryButtonColor,
          showIcon: showIcon,

          /// IMPORTANT:
          /// Dialog closes itself FIRST, then callback runs
          onPrimaryPressed: () {
            Navigator.of(dialogContext).pop(true);
            onPrimaryPressed?.call();
          },
          onSecondaryPressed: () {
            Navigator.of(dialogContext).pop(false);
            onSecondaryPressed?.call();
          },
        );
      },
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
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: appColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ICON
            if (showIcon) ...[
              Container(
                width: 64,
                height: 64,
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: iconBackgroundColor ?? appColors.red,
                  boxShape: BoxShape.circle,
                ),
                child:
                    iconWidget ??
                    Icon(
                      icon ?? Icons.info_outline,
                      color: Colors.white,
                      size: 32,
                    ),
              ),
              const SizedBox(height: 20),
            ],

            /// TITLE
            Text(
              title,
              textAlign: TextAlign.center,
              style: boldTextStyle(size: FontSize.s20),
            ),
            const SizedBox(height: 12),

            /// MESSAGE
            Text(
              message,
              textAlign: TextAlign.center,
              style: secondaryTextStyle(size: FontSize.s14),
            ),
            const SizedBox(height: 24),

            /// PRIMARY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor ?? appColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  primaryButtonText,
                  style: boldTextStyle(size: FontSize.s16, color: Colors.white),
                ),
              ),
            ),

            /// SECONDARY BUTTON
            if (secondaryButtonText != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondaryPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  secondaryButtonText!,
                  style: primaryTextStyle(
                    size: FontSize.s14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Example: Logout confirmation dialog (SAFE)
/// ------------------------------------------------------------
class LogoutConfirmationDialog {
  static Future<bool?> show(BuildContext context) {
    return AppCustomDialog.show(
      context: context,
      icon: Icons.logout_rounded,
      iconBackgroundColor: appColors.red,
      title: 'Already leaving?',
      message:
          'We\'ll keep an eye on your rewards and coins while you\'re gone.',
      primaryButtonText: 'Yes, Log out',
      secondaryButtonText: 'No, I am staying',
      primaryButtonColor: appColors.red,
    );
  }
}
