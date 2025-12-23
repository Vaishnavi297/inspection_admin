import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspection_station/utils/constants/app_constants.dart';
import 'package:intl/intl.dart';
import '../../components/app_button/app_button.dart';
import '../../utils/common/scrollable_data_table.dart';
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
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

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
                          appStrings.lblCountyManagement,
                          style: boldTextStyle(size: FontSize.s20, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'Manage counties across West Virginia',
                          style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () {
                        _onAddCountyTap(context);
                      },
                      width: 160,
                      height: 40,
                      btnWidget: Text('Add New County', style: boldTextStyle(size: FontSize.s14)),
                    ),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is CountyLoading)
                  Center(
                    child: Padding(padding: EdgeInsets.all(s.s40), child: LoaderView()),
                  )
                else if (state is CountyLoaded)
                  dataTableWidget(state.counties)
                else if (state is CountyError)
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

  Widget dataTableWidget(List<County> counties) {
    return ScrollableDataTable(
      horizontalController: _horizontalScrollController,
      verticalController: _verticalScrollController,
      headingRowColor: appColors.primaryColor,
      borderRadius: appConstants.defaultRadius,
      minWidth: MediaQuery.of(context).size.width,
      columnSpacing: s.s0,
      headingRowHeight: s.s40,
      margin: EdgeInsets.symmetric(horizontal: s.s0),
      expand: false,
      headingTextStyle: boldTextStyle(size: FontSize.s14, fontWeight: FontWeight.w600, color: appColors.textPrimaryColor),
      columns: [
        DataColumn(label: Text('Sr. No.', style: boldTextStyle())),

        DataColumn(label: Text('County Name', style: boldTextStyle())),
        DataColumn(label: Text('Created At', style: boldTextStyle())),

        DataColumn(
          label: Text('Actions', textAlign: TextAlign.center, style: boldTextStyle()),
        ),
      ],
      rows: counties.asMap().entries.map((entry) {
        final i = entry.key;
        final county = entry.value;
        return DataRow(
          color: WidgetStateProperty.resolveWith((_) => i.isOdd ? appColors.surfaceColor.withOpacity(0.04) : appColors.surfaceColor),
          cells: [
            DataCell(
              Text(
                (i + 1).toString(),
                style: boldTextStyle(size: s.s14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Text(
                county.countyName,
                style: boldTextStyle(size: s.s14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Text(
                county.createTime == null ? '-' : DateFormat('dd MMM yy hh:mm a').format(county.createTime!.toLocal()),
                style: boldTextStyle(size: s.s14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Row(
                spacing: s.s8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _onEditCountyTap(context, county),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: appColors.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: appColors.primaryColor.withOpacity(0.8)),
                      ),
                      child: Icon(Icons.edit, color: appColors.primaryColor, size: 16),
                    ),
                  ),
                  InkWell(
                    onTap: () => _onDeleteCountyTap(context, county),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: appColors.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: appColors.red.withOpacity(0.8)),
                      ),
                      child: Icon(Icons.delete, color: appColors.red, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _onAddCountyTap(BuildContext context) async {
    final result = await showDialog(context: context, builder: (context) => const AddCountyPage());
    if (result is Map && result['countyName'] != null && result['countyLowerName'] != null) {
      context.read<CountyBloc>().add(AddCountyEvent(countyName: result['countyName'], countyLowerName: result['countyLowerName']));
    }
  }

  void _onEditCountyTap(BuildContext context, County county) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddCountyPage(county: county),
    );
    if (result is Map && result['countyName'] != null && result['countyLowerName'] != null) {
      context.read<CountyBloc>().add(UpdateCountyEvent(county: result['county'], countyName: result['countyName'], countyLowerName: result['countyLowerName']));
    }
  }

  void _onDeleteCountyTap(BuildContext context, County county) async {
    final shouldDelete = await AppCustomDialog.show<bool>(
      context: context,
      icon: Icons.delete_outline,
      iconBackgroundColor: appColors.red,
      title: 'Delete County',
      message: 'Are you sure you want to delete "${county.countyName}"? This action cannot be undone.',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.red,
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );

    if (shouldDelete == true) {
      context.read<CountyBloc>().add(DeleteCountyEvent(countyId: county.countyId ?? ''));
    }
  }
}
