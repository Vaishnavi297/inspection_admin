import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../components/app_button/app_button.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/common/data_table/utils.dart';
import '../../utils/constants/app_strings.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/loader_view.dart';
import '../../data/data_structure/models/country.dart';
import 'add_county_page.dart';
import 'bloc/county_bloc.dart';

class CountyPage extends StatefulWidget {
  const CountyPage({super.key});

  @override
  State<CountyPage> createState() => _CountyPageState();
}

class _CountyPageState extends State<CountyPage> {
  @override
  void initState() {
    super.initState();
    // Fetch counties when page loads
    context.read<CountyBloc>().add(FetchCountiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<CountyBloc, CountyState>(
        listener: (context, state) {
          if (state is CountyError) {
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
                          appStrings.lblCountyManagement,
                          style: boldTextStyle(
                            size: FontSize.s20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'Manage counties across West Virginia',
                          style: secondaryTextStyle(
                            size: FontSize.s12,
                            color: appColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () {
                        _onAddCountyTap(context);
                      },
                      width: 160,
                      height: 40,
                      btnWidget: Text(
                        'Add New County',
                        style: boldTextStyle(size: FontSize.s14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is CountyLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  )
                else if (state is CountyLoaded)
                  dataTableWidget(state.counties)
                else if (state is CountyError)
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

  Widget dataTableWidget(List<County> counties) {
    final columns = ['Sr. No.', 'County Name', 'Created At'];
    final data = counties
        .asMap()
        .entries
        .map(
          (e) => {
            'Sr. No.': (e.key + 1).toString(),
            'County Name': e.value.countyName,
            'Created At': e.value.createTime == null
                ? '-'
                : DateFormat(
                    'dd MMM yy hh:mm a',
                  ).format(e.value.createTime!.toDate()),
            '_model': e.value,
          },
        )
        .toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDataTableText: 'All Counties',
      subTitleDataTableText: 'Manage counties across West Virginia',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      // Use default DataTable row heights to avoid min>max constraint issues
      rowActions: {
        RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onModify: (row) {
        final county = row['_model'] as County;
        _onEditCountyTap(context, county);
      },
      onDelete: (row) {
        final county = row['_model'] as County;
        _onDeleteCountyTap(context, county);
      },
      actionColumnName: 'Actions',
    );
  }

  void _onAddCountyTap(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddCountyPage(),
    );
    if (result is Map &&
        result['countyName'] != null &&
        result['countyLowerName'] != null) {
      context.read<CountyBloc>().add(
        AddCountyEvent(
          countyName: result['countyName'],
          countyLowerName: result['countyLowerName'],
        ),
      );
    }
  }

  void _onEditCountyTap(BuildContext context, County county) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddCountyPage(county: county),
    );
    if (result is Map &&
        result['countyName'] != null &&
        result['countyLowerName'] != null) {
      context.read<CountyBloc>().add(
        UpdateCountyEvent(
          county: result['county'],
          countyName: result['countyName'],
          countyLowerName: result['countyLowerName'],
        ),
      );
    }
  }

  void _onDeleteCountyTap(BuildContext context, County county) async {
    await AppCustomDialog.show(
      context: context,
      icon: Icons.delete_outline,
      iconBackgroundColor: appColors.red,
      title: 'Delete County',
      message:
          'Are you sure you want to delete "${county.countyName}"? This action cannot be undone.',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.red,
      onPrimaryPressed: () {
        // Navigator.of(context).pop(true);
        context.read<CountyBloc>().add(
          DeleteCountyEvent(countyId: county.countyId ?? ''),
        );
      },
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );
  }
}
