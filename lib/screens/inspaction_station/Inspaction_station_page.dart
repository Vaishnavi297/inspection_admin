import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspection_station/data/data_structure/models/inspaction_station.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../utils/common/drop_down/data_table.dart';
import '../../utils/common/drop_down/utils.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../inspaction_station/bloc/inspaction_station_bloc.dart';
import 'Inspaction_station_view_page.dart';
import 'add_inspaction_station_page.dart';

class InspactionStationPage extends StatefulWidget {
  const InspactionStationPage({super.key});

  @override
  State<InspactionStationPage> createState() => _InspactionStationPageState();
}

class _InspactionStationPageState extends State<InspactionStationPage> {
  @override
  void initState() {
    super.initState();
    context.read<InspactionStationBloc>().add(FetchInspactionStationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<InspactionStationBloc, InspactionStationState>(
        listener: (context, state) {
          if (state is InspactionStationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage), backgroundColor: appColors.errorColor));
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
                          'Inspaction Station Management',
                          style: boldTextStyle(size: FontSize.s20, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'Manage stations across West Virginia',
                          style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () {
                        _onAddInspactionStationTap(context);
                      },
                      width: 160,
                      height: 40,
                      btnWidget: Text('Add New Inspaction Station', style: boldTextStyle(size: FontSize.s14)),
                    ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is InspactionStationLoading)
                  Center(
                    child: Padding(padding: EdgeInsets.all(s.s40), child: LoaderView()),
                  )
                else if (state is InspactionStationLoaded)
                  // Text('${state.inspactionStations.length} stations found')
                  dataTableWidget(state.inspactionStations)
                else if (state is InspactionStationError)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: Text('Error loading counties: ${state.errorMessage}', style: secondaryTextStyle(color: appColors.errorColor)),
                    ),
                  )
                else
                  Center(
                    child: Padding(padding: EdgeInsets.all(s.s40), child: LoaderView()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget dataTableWidget(List<InspactionStation> stations) {
    final columns = ['Station ID', 'Station Name', 'Address', 'County', 'Hours', 'Inspectors', 'Status'];
    final data = stations.map((station) {
      final idText = station.stationId ?? '-';
      final address = station.stationAddress ?? '-';
      final county = station.sCountyDetails?.countyName ?? '-';
      final daysOrder = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final dayLabels = {'mon': 'MON', 'tue': 'TUE', 'wed': 'WED', 'thu': 'THU', 'fri': 'FRI', 'sat': 'SAT', 'sun': 'SUN'};
      String hours;
      WorkingHours? parsedWorkingHours;
      if (station.workingHours != null) {
        final dynamic raw = station.workingHours;
        if (raw is WorkingHours) {
          parsedWorkingHours = raw;
        } else if (raw is Map) {
          parsedWorkingHours = WorkingHours.fromJson(Map<String, dynamic>.from(raw));
        }
      }

      if (parsedWorkingHours == null) {
        hours = '-';
      } else {
        if (parsedWorkingHours.weeklySchedule.isNotEmpty) {
          final ordered = daysOrder.where((d) => (parsedWorkingHours!.weeklySchedule[d] ?? const []).isNotEmpty).toList();
          if (ordered.isNotEmpty) {
            final first = dayLabels[ordered.first]!;
            final last = dayLabels[ordered.last]!;
            hours = ordered.length > 1 ? '$first - $last' : first;
          } else {
            hours = '-';
          }
        } else if (parsedWorkingHours.selectedDays.isNotEmpty) {
          final ordered = daysOrder.where((d) => parsedWorkingHours!.selectedDays.contains(d)).toList();
          final first = dayLabels[ordered.first]!;
          final last = dayLabels[ordered.last]!;
          hours = ordered.length > 1 ? '$first - $last' : first;
        } else {
          hours = '-';
        }
      }  
      final max = station.inspactors ?? 0;  
      final current = 0;
      final inspectors = '$current/$max';
      final active = station.stationActivationStatus == true ? 'Active' : 'Inactive';
      return {'Station ID': idText, 'Station Name': station.stationName, 'Address': address, 'County': county, 'Hours': hours, 'Inspectors': inspectors, 'Status': active, '_model': station};
    }).toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDatatableText: 'All Stations',
      subTitleDatatableText: 'List of all inspection stations',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      rowActions: {
        RowAction(RowActionType.view, icon: Icons.remove_red_eye_outlined),
        RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onView: (row) {
        final station = row['_model'] as InspactionStation;
        _onViewStationTap(context, station);
      },
      onModify: (row) {
        final station = row['_model'] as InspactionStation;
        _onEditInspactionStationTap(context, station);
      },
      onDelete: (row) {
        final station = row['_model'] as InspactionStation;
        _onDeleteInspactionStationTap(context, station);
      },
      actionColumnName: 'Actions',
    );
  }

  void _onViewStationTap(BuildContext context, InspactionStation station) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return InspactionStationViewPage(station: station, onDelete: () => _onDeleteInspactionStationTap(context, station));
      },
    );
  }

  void _onAddInspactionStationTap(BuildContext context) async {
    final result = await showDialog(context: context, builder: (context) => const AddInspactionStationPage());
    if (result is InspactionStation) {
      context.read<InspactionStationBloc>().add(AddInspactionStationEvent(station: result));
    }
  }

  void _onEditInspactionStationTap(BuildContext context, InspactionStation station) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddInspactionStationPage(station: station),
    );
    if (result is InspactionStation) {
      context.read<InspactionStationBloc>().add(
        UpdateInspactionStationEvent(station: result, stationName: result.stationName, stationLowerName: result.stationName.toLowerCase(), inspactors: result.inspactors ?? 0),
      );
    }
  }

  void _onDeleteInspactionStationTap(BuildContext context, InspactionStation station) async {
    final shouldDelete = await AppCustomDialog.show<bool>(
      context: context,
      icon: Icons.delete_outline,
      iconBackgroundColor: appColors.red,
      title: 'Delete Station',
      message: 'Are you sure you want to delete "${station.stationName}"? This action cannot be undone.',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.red,
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );

    if (shouldDelete == true && station.sId != null && station.sId!.isNotEmpty) {
      context.read<InspactionStationBloc>().add(DeleteInspactionStationEvent(stationId: station.sId!));
    }
  }
}
