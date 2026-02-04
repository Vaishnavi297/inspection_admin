import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/common/data_table/utils.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../data/data_structure/models/inspector.dart';
import 'bloc/inspector_bloc.dart';
import 'inspector_view_page.dart';
import 'add_inspector_page.dart';

class InspectorPage extends StatefulWidget {
  const InspectorPage({super.key});

  @override
  State<InspectorPage> createState() => _InspectorPageState();
}

class _InspectorPageState extends State<InspectorPage> {
  @override
  void initState() {
    super.initState();
    context.read<InspectorBloc>().add(FetchInspectorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<InspectorBloc, InspectorState>(
        listener: (context, state) {
          if (state is InspectorError) {
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
                          'All Inspectors',
                          style: boldTextStyle(
                            size: FontSize.s20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'List of all inspectors with their assignments',
                          style: secondaryTextStyle(
                            size: FontSize.s12,
                            color: appColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () => _onAddInspactorTap(),
                      width: 180,
                      height: 40,
                      btnWidget: Text(
                        'Add New Inspector',
                        style: boldTextStyle(size: FontSize.s14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is InspectorLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  )
                else if (state is InspectorLoaded)
                  _dataTableWidget(state.inspectors)
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

  Widget _dataTableWidget(List<Inspector> inspactors) {
    final columns = [
      'Sr. No.',
      'Inspector',
      'Badge ID',
      'Station',
      'Contact',
      'Status',
      'Last Login',
    ];
    final data = inspactors
        .map(
          (i) => {
            'Sr. No.': inspactors.indexOf(i) + 1,
            'Inspector': '${i.firstName} ${i.lastName}\n${i.email}',
            'Badge ID': i.badgeId ?? '-',
            'Station': i.stationName ?? '-',
            'Contact': i.phone,
            'Status': i.isActive ? 'Active' : 'Inactive',
            'Last Login': i.lastLogin == null
                ? '-'
                : '${i.lastLogin!.toDate().day.toString().padLeft(2, '0')}/${i.lastLogin!.toDate().month.toString().padLeft(2, '0')}/${i.lastLogin!.toDate().year}',
            '_model': i,
          },
        )
        .toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDataTableText: 'All Inspectors',
      subTitleDataTableText: 'List of all inspectors with their assignments',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      rowActions: {
        RowAction(RowActionType.view, icon: Icons.remove_red_eye_outlined),
        RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        RowAction(
          RowActionType.execute,
          icon: Icons.power_settings_new,
          hoverMessage: 'Activate/Deactivate',
        ),
        RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onView: (row) {
        final i = row['_model'] as Inspector;
        _onViewInspactorTap(context, i);
      },
      onModify: (row) async {
        final i = row['_model'] as Inspector;
        final result = await showDialog(
          context: context,
          builder: (context) => AddInspectorPage(
            initialData: {
              'firstName': i.firstName,
              'lastName': i.lastName,
              'email': i.email,
              'phone': i.phone,
              'badgeId': i.badgeId,
              'stationId': i.stationId,
              'stationName': i.stationName,
            },
          ),
        );
        if (result is Map &&
            result['firstName'] != null &&
            result['lastName'] != null) {
          context.read<InspectorBloc>().add(
            UpdateInspectorEvent(
              inspector: i,
              firstName: result['firstName'],
              lastName: result['lastName'],
              email: result['email'],
              phone: result['phone'],
              badgeId: result['badgeId'],
              stationId: result['stationId'],
              stationName: result['stationName'],
            ),
          );
        }
      },
      onExecute: (row) {
        final i = row['_model'] as Inspector;
        context.read<InspectorBloc>().add(
          ToggleActiveEvent(
            inspectorId: i.inspectorId ?? '',
            isActive: !i.isActive,
          ),
        );
      },
      onDelete: (row) async {
        final i = row['_model'] as Inspector;
        await AppCustomDialog.show(
          context: context,
          icon: Icons.delete_outline,
          iconBackgroundColor: appColors.red,
          title: 'Delete Inspector',
          message: 'Delete "${i.firstName} ${i.lastName}"?',
          primaryButtonText: 'Delete',
          secondaryButtonText: 'Cancel',
          primaryButtonColor: appColors.red,
          onPrimaryPressed: () {
            // Navigator.of(context).pop(true);
            context.read<InspectorBloc>().add(
              DeleteInspectorEvent(inspectorId: i.inspectorId ?? ''),
            );
          },
          onSecondaryPressed: () => Navigator.of(context).pop(false),
        );
      },
      actionColumnName: 'Actions',
    );
  }

  Future<void> _onAddInspactorTap() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddInspectorPage(),
    );
    if (result is Map &&
        result['firstName'] != null &&
        result['lastName'] != null) {
      context.read<InspectorBloc>().add(
        AddInspectorEvent(
          firstName: result['firstName'],
          lastName: result['lastName'],
          email: result['email'],
          phone: result['phone'],
          badgeId: result['badgeId'],
          stationId: result['stationId'],
          stationName: result['stationName'],
        ),
      );
    }
  }

  void _onViewInspactorTap(BuildContext context, Inspector inspector) {
    showDialog(
      context: context,
      builder: (context) => InspectorViewPage(inspector: inspector),
    );
  }
}
