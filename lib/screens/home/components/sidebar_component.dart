import 'package:flutter/material.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';
import 'package:inspection_station/utils/constants/app_strings.dart';

import '../../../components/app_text_style/app_text_style.dart';
import '../../../components/app_dialog/app_custom_dialog.dart';
import '../../../data/services/local_storage_services/local_storage_services.dart';
import '../../../utils/common/responsive_widget.dart';
import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/app_dimension.dart';
import '../../../data/repositories/admin_repository/admin_repository.dart';
import '../../../utils/routes/app_routes.dart';

class SidebarComponent extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onSelect;
  const SidebarComponent({super.key, required this.currentIndex, this.onSelect});

  @override
  State<SidebarComponent> createState() => _SidebarComponentState();
}

class _SidebarComponentState extends State<SidebarComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveWidget.isLargeScreen(context) ? 300 : 80,
      height: MediaQuery.of(context).size.height,
      color: appColors.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              leading: SizedBox(
                width: ResponsiveWidget.isMediumScreen(context) ? 48 : 40,
                height: ResponsiveWidget.isMediumScreen(context) ? 48 : 40,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                  child: CircleAvatar(radius: 20, backgroundImage: AssetImage(AppAssets.imgAppLogo)),
                ),
              ),
              minLeadingWidth: 0,
              horizontalTitleGap: 12,
              contentPadding: ResponsiveWidget.isMediumScreen(context) ? EdgeInsets.zero : EdgeInsets.only(left: 8, right: 16),
              title: ResponsiveWidget.isMediumScreen(context) ? null : Text(appStrings.lblAppName, style: boldTextStyle(size: 20, color: appColors.primaryColor)),
              subtitle: ResponsiveWidget.isMediumScreen(context) ? null : Text(AdminRepository.instance.adminData?.email ?? appStrings.lblEmail, style: secondaryTextStyle(size: 12)),
              trailing: ResponsiveWidget.isMediumScreen(context) ? null : ImageIcon(AssetImage(AppAssets.imgCloseDrawer), size: 24),
              onTap: null,
            ),
            const Divider(height: 24, thickness: 0.5),

            Expanded(
              child: ListView(
                children: [
                  navItemWidget(title: 'Dashboard', icon: Icons.space_dashboard, index: 0, isTrailingIcon: false),
                  navItemWidget(title: 'County', icon: Icons.map_outlined, index: 1),
                  navItemWidget(title: 'Stations', icon: Icons.home_work_outlined, index: 2),
                  navItemWidget(title: 'Inspactors', icon: Icons.badge_outlined, index: 3),
                  navItemWidget(title: 'Users', icon: Icons.people_outline, index: 4),
                  navItemWidget(title: 'Vehicles', icon: Icons.directions_car_outlined, index: 5),

                ],
              ),
            ),

            navItemWidget(title: 'Logout', icon: Icons.logout, index: 7, isTrailingIcon: false, color: appColors.errorColor),

            const Divider(height: 18, thickness: 0.5),

            ListTile(
              contentPadding: EdgeInsets.only(left: 8, right: 16),
              dense: true,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: appColors.primaryColor,
                child: Icon(Icons.person_outline, size: 20, color: Colors.white),
              ),

              title: ResponsiveWidget.isMediumScreen(context) ? null : Text(AdminRepository.instance.adminData?.name ?? appStrings.lblUserName, style: boldTextStyle(size: 14)),
              subtitle: ResponsiveWidget.isMediumScreen(context) ? null : Text(AdminRepository.instance.adminData?.role ?? appStrings.lblEmail, style: secondaryTextStyle(size: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItemWidget({required String title, required IconData icon, required int index, bool? isTrailingIcon = true, Widget? trailing, Color? color}) {
    final selected = widget.currentIndex == index;
    final bg = selected ? appColors.primaryColor : Colors.transparent;
    final iconColor = color ?? (selected ? appColors.white : appColors.textSecondaryColor);
    final textColor = color ?? (selected ? appColors.white : appColors.textPrimaryColor);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(appConstants.defaultRadius)),
      child: ListTile(
        dense: true,
        leading: SizedBox(
          width: ResponsiveWidget.isMediumScreen(context) ? 16 : 18,
          height: ResponsiveWidget.isMediumScreen(context) ? 16 : 18,
          child: Icon(icon, color: iconColor, size: 18),
        ),
        minLeadingWidth: 0,
        title: ResponsiveWidget.isMediumScreen(context)
            ? null
            : Text(
                title,
                style: primaryTextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
        trailing: ResponsiveWidget.isMediumScreen(context)
            ? null
            : isTrailingIcon == true
            ? trailing ?? Icon(Icons.arrow_forward_ios_rounded, color: color, size: s.s18)
            : null,
        onTap: index == 7
            ? () async {
                final shouldLogout = await LogoutConfirmationDialog.show(context: context);

                if (shouldLogout == true) {
                  await LocalStorageService.instance.clearAllLocal();
                  await LocalStorageService.instance.clearAllSecure();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  }
                }
              }
            : () => widget.onSelect?.call(index),
      ),
    );
  }
}
