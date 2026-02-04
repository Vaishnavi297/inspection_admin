import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../data/data_structure/models/inspection.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/common/data_table/utils.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import 'bloc/inspection_bloc.dart';
import 'inspection_view_page.dart';

class InspectionPage extends StatefulWidget {
  const InspectionPage({super.key});

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<InspectionBloc>().add(FetchInspectionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<InspectionBloc, InspectionState>(
        listener: (context, state) {
          if (state is InspectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: appColors.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: s.s16, vertical: s.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inspection Management',
                  style: boldTextStyle(
                    size: FontSize.s20,
                    fontWeight: FontWeight.w600,
                    color: appColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: s.s4),
                Text(
                  'View and manage inspection records',
                  style: secondaryTextStyle(
                    size: FontSize.s12,
                    color: appColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: s.s16),
                if (state is InspectionLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  )
                else if (state is InspectionLoaded)
                  _dataTableWidget(context, state.inspections)
                else if (state is InspectionError)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: Text(
                        'Error loading inspections: ${state.errorMessage}',
                        style: secondaryTextStyle(color: appColors.errorColor),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dataTableWidget(BuildContext context, List<Inspection> inspections) {
    final columns = [
      'Time',
      'Vehicle',
      'Station',
      'Inspector',
      'VIN',
      // 'Title',
      'Sticker',
      'Type',
      'Result',
      'Source',
    ];
    final data = inspections.map((inspection) {
      final time = inspection.appointmentDateTime != null
          ? DateFormat('HH:mm').format(inspection.appointmentDateTime!.toDate())
          : '-';
      final vehicle = '${inspection.vTitle ?? ''} ${inspection.vName ?? ''}';
      final vin = inspection.vId ?? '-';
      //  final title = inspection.vTitle ?? '-';
      final sticker = inspection.inspectionSticker ?? '-';
      final type = inspection.inspectionType ?? '-';
      final result = inspection.appointmentApprovalStatus ?? '-';
      final source = inspection.isScheduledForLater == true
          ? 'Scheduled'
          : 'Walk-in';
      final station = inspection.stationName ?? inspection.stationId ?? '-';
      final inspector = inspection.inspectorName ?? '-';

      return {
        'Time': time,
        'Vehicle': vehicle.trim().isEmpty ? '-' : vehicle,
        'Station': station,
        'Inspector': inspector,
        'VIN': vin,
        // 'Title': title,
        'Sticker': sticker,
        'Type': type,
        'Result': result,
        'Source': source,
        '_model': inspection,
      };
    }).toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDataTableText: 'All Inspections',
      subTitleDataTableText: 'List of all inspections',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      rowActions: {
        RowAction(RowActionType.view, icon: Icons.remove_red_eye_outlined),
        RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onView: (row) {
        final inspection = row['_model'] as Inspection;
        _onViewInspectionTap(context, inspection);
      },
      onDelete: (row) {
        final inspection = row['_model'] as Inspection;
        _onDeleteInspectionTap(context, inspection);
      },
      actionColumnName: 'Actions',
    );
  }

  void _onViewInspectionTap(BuildContext context, Inspection inspection) {
    showDialog(
      context: context,
      builder: (context) => InspectionViewPage(inspection: inspection),
    );
  }

  void _onDeleteInspectionTap(
    BuildContext context,
    Inspection inspection,
  ) async {
    await AppCustomDialog.show(
      context: context,
      icon: Icons.delete_outline,
      iconBackgroundColor: appColors.red,
      title: 'Delete Inspection',
      message:
          'Are you sure you want to delete this inspection? This action cannot be undone.',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.red,
      onPrimaryPressed: () {
        // Navigator.of(context).pop(true);
        if (inspection.appointmentId != null) {
          context.read<InspectionBloc>().add(
            DeleteInspectionEvent(inspectionId: inspection.appointmentId!),
          );
        }
      },
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );
  }
}
