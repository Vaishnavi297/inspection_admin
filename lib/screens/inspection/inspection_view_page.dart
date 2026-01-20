import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/app_button/app_button.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../data/data_structure/models/inspection.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';

class InspectionViewPage extends StatelessWidget {
  final Inspection inspection;

  const InspectionViewPage({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    final title = 'Inspection Details';
    final date = inspection.appointmentDateTime != null
        ? DateFormat(
            'MMM dd, yyyy HH:mm',
          ).format(inspection.appointmentDateTime!.toDate())
        : '-';

    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 700, minWidth: 700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: appColors.surfaceColor,
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      actionsPadding: EdgeInsets.only(left: s.s20, right: s.s20, bottom: s.s16),
      title: Text(
        title,
        style: boldTextStyle(
          size: FontSize.s18,
          fontWeight: FontWeight.w600,
          color: appColors.primaryTextColor,
        ),
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
                      _buildSectionTitle('Appointment Info'),
                      _buildInfoRow('ID:', inspection.appointmentId ?? '-'),
                      _buildInfoRow('Date:', date),
                      _buildInfoRow(
                        'Approval:',
                        inspection.appointmentApprovalStatus ?? '-',
                      ),
                      _buildInfoRow(
                        'Scheduled Later:',
                        inspection.isScheduledForLater == true ? 'Yes' : 'No',
                      ),
                      _buildInfoRow('Station ID:', inspection.stationId ?? '-'),
                    ],
                  ),
                ),
                SizedBox(width: s.s24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Vehicle Info'),
                      _buildInfoRow('Name:', inspection.vName ?? '-'),
                      _buildInfoRow('Title:', inspection.vTitle ?? '-'),
                      _buildInfoRow('State:', inspection.vStates ?? '-'),
                      _buildInfoRow('ID:', inspection.vId ?? '-'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: s.s16),
            const Divider(height: 24, thickness: 0.5),
            SizedBox(height: s.s8),
            _buildSectionTitle('Inspection Results'),
            _buildInfoRow('Type:', inspection.inspectionType ?? '-'),
            _buildInfoRow('Sticker:', inspection.inspectionSticker ?? '-'),
            _buildInfoRow(
              'Decline Reason:',
              inspection.inspectionDeclineReason ?? '-',
            ),
            SizedBox(height: s.s8),
            Text(
              'Inspection Note',
              style: secondaryTextStyle(size: FontSize.s12),
            ),
            SizedBox(height: s.s4),
            Text(
              inspection.inspectionNote ?? '-',
              style: primaryTextStyle(size: FontSize.s14),
            ),
            if (inspection.inspectionDocumentImage != null) ...[
              SizedBox(height: s.s16),
              Text(
                'Document Image',
                style: secondaryTextStyle(size: FontSize.s12),
              ),
              SizedBox(height: s.s8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: appColors.borderColor),
                  image: DecorationImage(
                    image: NetworkImage(inspection.inspectionDocumentImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
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
          btnWidget: Text(
            'Close',
            style: primaryTextStyle(color: appColors.secondaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: s.s12),
      child: Text(
        title,
        style: secondaryTextStyle(
          size: FontSize.s14,
          color: appColors.secondaryTextColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: s.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: secondaryTextStyle(size: FontSize.s12)),
          ),
          Expanded(
            child: Text(value, style: boldTextStyle(size: FontSize.s14)),
          ),
        ],
      ),
    );
  }
}
