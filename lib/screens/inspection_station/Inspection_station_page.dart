import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspection_station/data/data_structure/models/inspection_station.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/common/data_table/utils.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import 'bloc/inspection_station_bloc.dart';
import 'Inspection_station_view_page.dart';
import 'add_inspection_station_page.dart';

class InspectionStationPage extends StatefulWidget {
  const InspectionStationPage({super.key});

  @override
  State<InspectionStationPage> createState() => _InspectionStationPageState();
}

class _InspectionStationPageState extends State<InspectionStationPage> {
  @override
  void initState() {
    super.initState();
    context.read<InspectionStationBloc>().add(FetchInspectionStationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<InspectionStationBloc, InspectionStationState>(
        listener: (context, state) {
          if (state is InspectionStationError) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspection Station Management',
                          style: boldTextStyle(
                            size: FontSize.s20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'Manage stations across West Virginia',
                          style: secondaryTextStyle(
                            size: FontSize.s12,
                            color: appColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () {
                        _onAddInspectionStationTap(context);
                      },
                      width: 160,
                      height: 40,
                      btnWidget: Text(
                        'Add New Inspection Station',
                        style: boldTextStyle(size: FontSize.s14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is InspectionStationLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  )
                else if (state is InspectionStationLoaded)
                  // Text('${state.inspactionStations.length} stations found')
                  dataTableWidget(state.inspectionStations)
                else if (state is InspectionStationError)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: Text(
                        'Error loading counties: ${state.errorMessage}',
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

  Widget dataTableWidget(List<InspectionStation> stations) {
    final columns = [
      'Station ID',
      'Station Name',
      'Address',
      'County',
      'Hours',
      'Inspectors',
      'Status',
    ];
    final data = stations.map((station) {
      final idText = station.stationId ?? '-';
      final address = station.stationAddress ?? '-';
      final county = station.sCountyDetails?.countyName ?? '-';
      final daysOrder = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final dayLabels = {
        'mon': 'MON',
        'tue': 'TUE',
        'wed': 'WED',
        'thu': 'THU',
        'fri': 'FRI',
        'sat': 'SAT',
        'sun': 'SUN',
      };
      String hours;
      WorkingHours? parsedWorkingHours;
      if (station.workingHours != null) {
        final dynamic raw = station.workingHours;
        if (raw is WorkingHours) {
          parsedWorkingHours = raw;
        } else if (raw is Map) {
          parsedWorkingHours = WorkingHours.fromJson(
            Map<String, dynamic>.from(raw),
          );
        }
      }

      if (parsedWorkingHours == null) {
        hours = '-';
      } else {
        if (parsedWorkingHours.weeklySchedule.isNotEmpty) {
          final ordered = daysOrder
              .where(
                (d) => (parsedWorkingHours!.weeklySchedule[d] ?? const [])
                    .isNotEmpty,
              )
              .toList();
          if (ordered.isNotEmpty) {
            final first = dayLabels[ordered.first]!;
            final last = dayLabels[ordered.last]!;
            hours = ordered.length > 1 ? '$first - $last' : first;
          } else {
            hours = '-';
          }
        } else if (parsedWorkingHours.selectedDays.isNotEmpty) {
          final ordered = daysOrder
              .where((d) => parsedWorkingHours!.selectedDays.contains(d))
              .toList();
          final first = dayLabels[ordered.first]!;
          final last = dayLabels[ordered.last]!;
          hours = ordered.length > 1 ? '$first - $last' : first;
        } else {
          hours = '-';
        }
      }
      final max = station.inspectors ?? 0;
      // final current = 0;
      final inspectors = '$max';
      final active = station.stationActivationStatus == true
          ? 'Active'
          : 'Inactive';
      return {
        'Station ID': idText,
        'Station Name': station.stationName,
        'Address': address,
        'County': county,
        'Hours': hours,
        'Inspectors': inspectors,
        'Status': active,
        '_model': station,
      };
    }).toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDataTableText: 'All Stations',
      subTitleDataTableText: 'List of all inspection stations',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      rowActions: {
        RowAction(RowActionType.view, icon: Icons.remove_red_eye_outlined),
        RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onView: (row) {
        final station = row['_model'] as InspectionStation;
        _onViewStationTap(context, station);
      },
      onModify: (row) {
        final station = row['_model'] as InspectionStation;
        _onEditInspectionStationTap(context, station);
      },
      onDelete: (row) {
        final station = row['_model'] as InspectionStation;
        _onDeleteInspectionStationTap(context, station);
      },
      actionColumnName: 'Actions',
    );
  }

  void _onViewStationTap(BuildContext context, InspectionStation station) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return InspectionStationViewPage(
          station: station,
          onDelete: () => _onDeleteInspectionStationTap(context, station),
        );
      },
    );
  }

  void _onAddInspectionStationTap(BuildContext context) async {
    print('=== MAIN PAGE DEBUG: Opening add station dialog ===');
    final result = await showDialog(
      context: context,
      builder: (context) => const AddInspectionStationPage(),
    );
    print('=== MAIN PAGE DEBUG: Dialog result: $result ===');
    print('=== MAIN PAGE DEBUG: Result type: ${result?.runtimeType} ===');

    if (result is InspectionStation) {
      print('=== MAIN PAGE DEBUG: Adding station: ${result.stationName} ===');
      context.read<InspectionStationBloc>().add(
        AddInspectionStationEvent(station: result),
      );
    } else {
      print('=== MAIN PAGE DEBUG: No station returned from dialog ===');
    }
  }

  void _onEditInspectionStationTap(
    BuildContext context,
    InspectionStation station,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddInspectionStationPage(station: station),
    );
    if (result is InspectionStation) {
      context.read<InspectionStationBloc>().add(
        UpdateInspectionStationEvent(station: result),
      );
    }
  }

  void _onDeleteInspectionStationTap(
    BuildContext context,
    InspectionStation station,
  ) async {
    await AppCustomDialog.show(
      context: context,
      icon: Icons.delete_outline,
      iconBackgroundColor: appColors.red,
      title: 'Delete Station',
      message:
          'Are you sure you want to delete "${station.stationName}"? This action cannot be undone.',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.red,
      onPrimaryPressed: () {
        // Navigator.of(context).pop(true);
        if (station.sId != null && station.sId!.isNotEmpty) {
          context.read<InspectionStationBloc>().add(
            DeleteInspectionStationEvent(stationId: station.sId!),
          );
        }
      },
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );
  }
}
