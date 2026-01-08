import 'package:flutter/material.dart';
import 'package:inspection_station/data/data_structure/models/inspaction_station.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_dimension.dart';

class InspactionStationViewPage extends StatelessWidget {
  final InspactionStation station;
  final Function() onDelete;
  const InspactionStationViewPage({super.key, required this.station, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final daysOrder = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayLabels = {'mon': 'MON', 'tue': 'TUE', 'wed': 'WED', 'thu': 'THU', 'fri': 'FRI', 'sat': 'SAT', 'sun': 'SUN'};
    String formatHours(dynamic hours) {
      if (hours == null) return '-';
      WorkingHours? parsed;
      if (hours is WorkingHours) {
        parsed = hours;
      } else if (hours is Map) {
        parsed = WorkingHours.fromJson(Map<String, dynamic>.from(hours));
      } else {
        return '-';
      }
      if (parsed.weeklySchedule.isNotEmpty) {
        final entries = <String>[];
        for (final d in daysOrder) {
          final ranges = parsed.weeklySchedule[d] ?? const [];
          if (ranges.isNotEmpty) {
            final parts = ranges.map((r) => '${r.open}-${r.close}').toList();
            entries.add('${dayLabels[d]} ${parts.join(', ')}');
          }
        }
        return entries.isEmpty ? '-' : entries.join(', ');
      } else {
        if (parsed.selectedDays.isEmpty) return '-';
        final entries = <String>[];
        for (final d in daysOrder) {
          if (parsed.selectedDays.contains(d)) {
            final s = parsed.startTimes[d];
            final e = parsed.endTimes[d];
            if (s != null && e != null) {
              entries.add('${dayLabels[d]} $s-$e');
            }
          }
        }
        return entries.isEmpty ? '-' : entries.join(', ');
      }
    }

    final title = station.stationName;
    final idText = station.stationId ?? '-';
    final county = station.sCountyDetails?.countyName ?? '-';
    final phone = station.stationContactNumber ?? '-';
    final addr = station.stationAddress ?? '-';
    final statusActive = station.stationActivationStatus == true;
    final statusText = statusActive ? 'Active' : 'Inactive';
    final hoursText = formatHours(station.workingHours);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: appColors.surfaceColor,
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      actionsPadding: EdgeInsets.only(left: s.s20, right: s.s20, bottom: s.s16),
      title: Text(
        title,
        style: boldTextStyle(size: FontSize.s18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Station Information',
                        style: secondaryTextStyle(size: FontSize.s14, color: appColors.secondaryTextColor),
                      ),
                      SizedBox(height: s.s12),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('Station ID:', style: secondaryTextStyle(size: FontSize.s12)),
                          ),
                          Expanded(
                            child: Text(idText, style: boldTextStyle(size: FontSize.s14)),
                          ),
                        ],
                      ),
                      SizedBox(height: s.s8),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('Name:', style: secondaryTextStyle(size: FontSize.s12)),
                          ),
                          Expanded(
                            child: Text(station.stationName, style: boldTextStyle(size: FontSize.s14)),
                          ),
                        ],
                      ),
                      SizedBox(height: s.s8),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('County:', style: secondaryTextStyle(size: FontSize.s12)),
                          ),
                          Expanded(
                            child: Text(county, style: boldTextStyle(size: FontSize.s14)),
                          ),
                        ],
                      ),
                      SizedBox(height: s.s8),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('Phone:', style: secondaryTextStyle(size: FontSize.s12)),
                          ),
                          Expanded(
                            child: Text(phone, style: boldTextStyle(size: FontSize.s14)),
                          ),
                        ],
                      ),
                      SizedBox(height: s.s8),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text('Hours:', style: secondaryTextStyle(size: FontSize.s12)),
                          ),
                          Expanded(
                            child: Text(hoursText, style: boldTextStyle(size: FontSize.s14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: s.s24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: secondaryTextStyle(size: FontSize.s14, color: appColors.secondaryTextColor),
                      ),
                      SizedBox(height: s.s12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s10),
                        decoration: BoxDecoration(color: appColors.backgroundColor, borderRadius: BorderRadius.circular(appConstants.defaultRadius)),
                        child: Text(addr, style: primaryTextStyle(size: FontSize.s13)),
                      ),
                      SizedBox(height: s.s12),
                      Text(
                        'Status',
                        style: secondaryTextStyle(size: FontSize.s14, color: appColors.secondaryTextColor),
                      ),
                      SizedBox(height: s.s8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s6),
                        decoration: BoxDecoration(color: (statusActive ? appColors.successColor : appColors.errorColor).withAlpha(100), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          statusText,
                          style: primaryTextStyle(size: FontSize.s12, color: statusActive ? appColors.successColor : appColors.errorColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: s.s16),
            const Divider(height: 24, thickness: 0.5),
            SizedBox(height: s.s8),
            Text(
              'Station Statistics',
              style: secondaryTextStyle(size: FontSize.s14, color: appColors.secondaryTextColor),
            ),
            SizedBox(height: s.s12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s16),
                    decoration: BoxDecoration(color: appColors.backgroundColor, borderRadius: BorderRadius.circular(appConstants.defaultRadius)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${0}', style: boldTextStyle(size: FontSize.s20)),
                        SizedBox(height: s.s4),
                        Text('Inspectors', style: secondaryTextStyle(size: FontSize.s12)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: s.s12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s16),
                    decoration: BoxDecoration(color: appColors.backgroundColor, borderRadius: BorderRadius.circular(appConstants.defaultRadius)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${0}', style: boldTextStyle(size: FontSize.s20)),
                        SizedBox(height: s.s4),
                        Text('Total Inspections', style: secondaryTextStyle(size: FontSize.s12)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: s.s12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s16),
                    decoration: BoxDecoration(color: appColors.backgroundColor, borderRadius: BorderRadius.circular(appConstants.defaultRadius)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${0}', style: boldTextStyle(size: FontSize.s20)),
                        SizedBox(height: s.s4),
                        Text('Appointments', style: secondaryTextStyle(size: FontSize.s12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: s.s16),
            const Divider(height: 24, thickness: 0.5),
            SizedBox(height: s.s8),
            Text(
              'Description',
              style: secondaryTextStyle(size: FontSize.s14, color: appColors.secondaryTextColor),
            ),
            SizedBox(height: s.s8),
            Text(station.stationDescription?.trim().isNotEmpty == true ? station.stationDescription! : 'No description', style: primaryTextStyle(size: FontSize.s13)),
          ],
        ),
      ),
      actions: [
        AppButton(
          height: 40,
          width: 140,
          backgroundColor: appColors.transparent,
          isBorderEnable: true,
          onTap: () => Navigator.of(context).pop(),
          btnWidget: Text('Cancel', style: primaryTextStyle(color: appColors.secondaryTextColor)),
        ),
        AppButton(height: 40, width: 160, backgroundColor: appColors.red, strTitle: 'Delete Station', onTap: () => onDelete()),
      ],
    );
  }
}
