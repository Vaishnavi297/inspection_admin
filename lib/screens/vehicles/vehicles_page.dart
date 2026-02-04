import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../data/data_structure/models/vehicle.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import 'bloc/vehicles_bloc.dart';
import 'add_vehicle_page.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  @override
  void initState() {
    super.initState();
    context.read<VehiclesBloc>().add(FetchVehiclesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<VehiclesBloc, VehiclesState>(
        listener: (context, state) {
          if (state is VehiclesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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
                          'Vehicles',
                          style: boldTextStyle(
                            size: FontSize.s20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'Manage registered vehicles',
                          style: secondaryTextStyle(
                            size: FontSize.s12,
                            color: appColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    // AppButton(
                    //   onTap: () => _onAddVehicleTap(context),
                    //   width: 160,
                    //   height: 40,
                    //   btnWidget: Text('Add Vehicle', style: boldTextStyle(size: FontSize.s14)),
                    // ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is VehiclesLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  )
                else if (state is VehiclesLoaded)
                  _dataTableWidget(state.vehicles)
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

  Widget _dataTableWidget(List<Vehicle> vehicles) {
    final columns = [
      'Sr. No.',
      'Plate',
      'VIN',
      'Name',
      'Title',
      'Model',
      'State',
      'Sticker',
      'Last Inspection',
      'Status',
    ];
    final data = vehicles.asMap().entries.map((e) {
      final v = e.value;
      final last = v.vLastInspectionDate?.toDate();
      final lastStr = last == null
          ? '-'
          : '${last.day.toString().padLeft(2, '0')}/${last.month.toString().padLeft(2, '0')}/${last.year}';
      return {
        'Sr. No.': (e.key + 1).toString(),
        'Plate': v.vPlateNumber ?? '-',
        'VIN': v.vVin ?? '-',
        'Name': v.vName ?? '-',
        'Title': v.vTitle ?? '-',
        'Model': v.vModel ?? '-',
        'State': v.vState ?? '-',
        'Sticker': v.vCurrentInspectionSticker ?? '-',
        'Last Inspection': lastStr,
        'Status': (v.vActivationStatus ?? true) ? 'Active' : 'Inactive',
        '_model': v,
      };
    }).toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDataTableText: 'All Vehicles',
      subTitleDataTableText: 'Manage registered vehicles',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      rowActions: {
        // RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        // RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onModify: (row) async {
        final v = row['_model'] as Vehicle;
        final result = await showDialog(
          context: context,
          builder: (context) => AddVehiclePage(
            initialData: {
              'cID': v.cID,
              'vName': v.vName,
              'vTitle': v.vTitle,
              'vPlateNumber': v.vPlateNumber,
              'vImageUrl': v.vImageUrl,
              'vVin': v.vVin,
              'vState': v.vState,
              'vCurrentInspectionSticker': v.vCurrentInspectionSticker,
              'vLastInspectionDate': v.vLastInspectionDate,
              'vActivationStatus': v.vActivationStatus,
              'documentVerificationStatus': v.documentVerificationStatus,
              'insuranceDocumentsIdList': v.insuranceDocumentsIdList,
              'registrationDocumentsIdList': v.registrationDocumentsIdList,
              'vModel': v.vModel,
              'vMileage': v.vMileage,
            },
          ),
        );
        if (result is Map) {
          context.read<VehiclesBloc>().add(
            UpdateVehicleEvent(
              vehicle: v,
              cID: result['cID'],
              vName: result['vName'],
              vTitle: result['vTitle'],
              vPlateNumber: result['vPlateNumber'],
              vImageUrl: result['vImageUrl'],
              vVin: result['vVin'],
              vState: result['vState'],
              vCurrentInspectionSticker: result['vCurrentInspectionSticker'],
              vLastInspectionDate: result['vLastInspectionDate'],
              vActivationStatus: result['vActivationStatus'],
              documentVerificationStatus: result['documentVerificationStatus'],
              insuranceDocumentsIdList: result['insuranceDocumentsIdList'],
              registrationDocumentsIdList:
                  result['registrationDocumentsIdList'],
              vModel: result['vModel'],
              vMileage: result['vMileage'],
            ),
          );
        }
      },
      onDelete: (row) async {
        final v = row['_model'] as Vehicle;
        await AppCustomDialog.show(
          context: context,
          icon: Icons.delete_outline,
          iconBackgroundColor: appColors.red,
          title: 'Delete Vehicle',
          message: 'Delete "${v.vPlateNumber ?? v.vVin ?? 'vehicle'}"?',
          primaryButtonText: 'Delete',
          secondaryButtonText: 'Cancel',
          primaryButtonColor: appColors.red,
          onPrimaryPressed: () {
            // Navigator.of(context).pop(true);
            context.read<VehiclesBloc>().add(
              DeleteVehicleEvent(vehicleId: v.vId ?? ''),
            );
          },
          onSecondaryPressed: () => Navigator.of(context).pop(false),
        );
      },
      // actionColumnName: 'Actions',
    );
  }

  // Future<void> _onAddVehicleTap(BuildContext context) async {
  //   final result = await showDialog(context: context, builder: (context) => const AddVehiclePage());
  //   if (result is Map) {
  //     context.read<VehiclesBloc>().add(
  //           AddVehicleEvent(
  //             cID: result['cID'],
  //             vName: result['vName'],
  //             vTitle: result['vTitle'],
  //             vPlateNumber: result['vPlateNumber'],
  //             vImageUrl: result['vImageUrl'],
  //             vVin: result['vVin'],
  //             vState: result['vState'],
  //             vCurrentInspectionSticker: result['vCurrentInspectionSticker'],
  //             vLastInspectionDate: result['vLastInspectionDate'],
  //             vActivationStatus: result['vActivationStatus'],
  //             documentVerificationStatus: result['documentVerificationStatus'],
  //             insuranceDocumentsIdList: result['insuranceDocumentsIdList'],
  //             registrationDocumentsIdList: result['registrationDocumentsIdList'],
  //             vModel: result['vModel'],
  //             vMileage: result['vMileage'],
  //           ),
  //         );
  //   }
  // }
}
