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
import 'bloc/inspactor_bloc.dart';
import 'inspactor_view_page.dart';
import 'add_inspactor_page.dart';

class InspactorsPage extends StatefulWidget {
  const InspactorsPage({super.key});

  @override
  State<InspactorsPage> createState() => _InspactorsPageState();
}

class _InspactorsPageState extends State<InspactorsPage> {
  @override
  void initState() {
    super.initState();
    context.read<InspactorBloc>().add(FetchInspactorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<InspactorBloc, InspactorState>(
        listener: (context, state) {
          if (state is InspactorError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: appColors.errorColor));
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
                          style: boldTextStyle(size: FontSize.s20, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'List of all inspectors with their assignments',
                          style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () => _onAddInspactorTap(),
                      width: 180,
                      height: 40,
                      btnWidget: Text('Add New Inspector', style: boldTextStyle(size: FontSize.s14)),
                    ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is InspactorLoading)
                  Center(
                    child: Padding(padding: EdgeInsets.all(s.s40), child: LoaderView()),
                  )
                else if (state is InspactorLoaded)
                  _dataTableWidget(state.inspactors)
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

  Widget _dataTableWidget(List<Inspector> inspactors) {
    final columns = ['Sr. No.', 'Inspector', 'Badge ID', 'Station', 'Contact', 'Status', 'Last Login'];
    final data = inspactors
        .map(
          (i) => {
            'Sr. No.': inspactors.indexOf(i) + 1,
            'Inspector': '${i.firstName} ${i.lastName}\n${i.email}',
            'Badge ID': i.badgeId ?? '-',
            'Station': i.stationName ?? '-',
            'Contact': i.phone,
            'Status': i.isActive ? 'Active' : 'Inactive',
            'Last Login': i.lastLogin == null ? '-' : '${i.lastLogin!.toDate().day.toString().padLeft(2, '0')}/${i.lastLogin!.toDate().month.toString().padLeft(2, '0')}/${i.lastLogin!.toDate().year}',
            '_model': i,
          },
        )
        .toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDatatableText: 'All Inspectors',
      subTitleDatatableText: 'List of all inspectors with their assignments',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      rowActions: {
        RowAction(RowActionType.view, icon: Icons.remove_red_eye_outlined),
        RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        RowAction(RowActionType.execute, icon: Icons.power_settings_new, hoverMessage: 'Activate/Deactivate'),
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
          builder: (context) => AddInspactorPage(
            initialData: {'firstName': i.firstName, 'lastName': i.lastName, 'email': i.email, 'phone': i.phone, 'badgeId': i.badgeId, 'stationId': i.stationId, 'stationName': i.stationName},
          ),
        );
        if (result is Map && result['firstName'] != null && result['lastName'] != null) {
          context.read<InspactorBloc>().add(
            UpdateInspactorEvent(
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
        context.read<InspactorBloc>().add(ToggleActiveEvent(inspectorId: i.inspectorId ?? '', isActive: !i.isActive));
      },
      onDelete: (row) async {
        final i = row['_model'] as Inspector;
        final shouldDelete = await AppCustomDialog.show<bool>(
          context: context,
          icon: Icons.delete_outline,
          iconBackgroundColor: appColors.red,
          title: 'Delete Inspector',
          message: 'Delete "${i.firstName} ${i.lastName}"?',
          primaryButtonText: 'Delete',
          secondaryButtonText: 'Cancel',
          primaryButtonColor: appColors.red,
          onPrimaryPressed: () => Navigator.of(context).pop(true),
          onSecondaryPressed: () => Navigator.of(context).pop(false),
        );
        if (shouldDelete == true) {
          context.read<InspactorBloc>().add(DeleteInspactorEvent(inspectorId: i.inspectorId ?? ''));
        }
      },
      actionColumnName: 'Actions',
    );
  }

  Future<void> _onAddInspactorTap() async {
    final result = await showDialog(context: context, builder: (context) => const AddInspactorPage());
    if (result is Map && result['firstName'] != null && result['lastName'] != null) {
      context.read<InspactorBloc>().add(
        AddInspactorEvent(
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
      builder: (context) => InspactorViewPage(inspector: inspector),
    );
  }
}
