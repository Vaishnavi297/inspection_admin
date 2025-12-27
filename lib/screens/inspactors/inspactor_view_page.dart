import 'package:flutter/material.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../data/data_structure/models/inspector.dart';
import 'bloc/inspactor_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InspactorViewPage extends StatelessWidget {
  final Inspector inspector;
  const InspactorViewPage({super.key, required this.inspector});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      backgroundColor: appColors.surfaceColor,
      constraints: BoxConstraints(minWidth: 720),
      actionsOverflowButtonSpacing: s.s12,
      title: Text(
        'Inspector Details',
        style: boldTextStyle(size: 18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(' ${inspector.firstName} ${inspector.lastName}', style: primaryTextStyle()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Full Name:', '${inspector.firstName} ${inspector.lastName}'),
                    SizedBox(height: s.s8),
                    _kv('Badge ID:', inspector.badgeId ?? '-'),
                    SizedBox(height: s.s8),
                    _kv('Email:', inspector.email),
                    SizedBox(height: s.s8),
                    _kv('Phone:', inspector.phone),
                  ],
                ),
              ),
              SizedBox(width: s.s20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Station:', inspector.stationName ?? '-'),
                    SizedBox(height: s.s8),
                    _kv('Status:', inspector.isActive ? 'Active' : 'Inactive'),
                    SizedBox(height: s.s8),
                    _kv('Created:', inspector.createdAt?.toDate().toIso8601String().split('T').first ?? '-'),
                    SizedBox(height: s.s8),
                    _kv('Last Login:', inspector.lastLogin?.toDate().toIso8601String().replaceFirst('T', ' ') ?? '-'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: s.s20),
          Row(
            children: [
              Expanded(child: _metricCard('${inspector.totalInspections ?? 0}', 'Total Inspections')),
              SizedBox(width: s.s12),
              Expanded(child: _metricCard('${(inspector.passRate ?? 0).toStringAsFixed(0)}%', 'Pass Rate')),
              SizedBox(width: s.s12),
              Expanded(child: _metricCard('${inspector.avgDaily ?? 0}', 'Avg. Daily')),
            ],
          ),
        ],
      ),
      actionsPadding: EdgeInsets.only(left: s.s20, top: s.s12, right: s.s20, bottom: s.s16),
      actions: [
        AppButton(
          height: 40,
          width: 140,
          backgroundColor: appColors.transparent,
          isBorderEnable: true,
          onTap: () => Navigator.of(context).pop(),
          btnWidget: Text('Cancel', style: primaryTextStyle(color: appColors.secondaryTextColor)),
        ),
        AppButton(
          height: 40,
          width: 160,
          backgroundColor: appColors.red,
          strTitle: inspector.isActive ? 'Deactivate' : 'Activate',
          onTap: () {
            context.read<InspactorBloc>().add(ToggleActiveEvent(inspectorId: inspector.inspectorId ?? '', isActive: !inspector.isActive));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(k, style: secondaryTextStyle())),
        Expanded(
          flex: 5,
          child: Text(v, style: boldTextStyle(size: FontSize.s14)),
        ),
      ],
    );
  }

  Widget _metricCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s16),
      decoration: BoxDecoration(color: appColors.backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: boldTextStyle(size: FontSize.s20)),
          SizedBox(height: s.s4),
          Text(label, style: secondaryTextStyle(size: FontSize.s12)),
        ],
      ),
    );
  }
}
