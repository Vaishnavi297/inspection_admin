import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../data/data_structure/models/user.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/common/data_table/utils.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import 'bloc/users_bloc.dart';
import 'add_user_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(FetchUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersError) {
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
                          'User Management',
                          style: boldTextStyle(size: FontSize.s20, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
                        ),
                        SizedBox(height: s.s4),
                        Text(
                          'Manage application users',
                          style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
                        ),
                      ],
                    ),
                    //AppButton(onTap: () => _onAddUserTap(context), width: 160, height: 40, btnWidget: Text('Add New User', style: boldTextStyle(size: FontSize.s14))),
                  ],
                ),
                SizedBox(height: s.s16),
                if (state is UsersLoading)
                  Center(
                    child: Padding(padding: EdgeInsets.all(s.s40), child: LoaderView()),
                  )
                else if (state is UsersLoaded)
                  _dataTableWidget(state.users)
                else if (state is UsersError)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: Text('Error loading users', style: secondaryTextStyle(color: appColors.errorColor)),
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

  Widget _dataTableWidget(List<AppUser> users) {
    final columns = ['Sr. No.', 'Name', 'Email', 'Phone', 'Status'];
    final data = users
        .asMap()
        .entries
        .map(
          (e) => {
            'Sr. No.': (e.key + 1).toString(),
            'Name': e.value.cName ?? '-',
            'Email': e.value.cEmail ?? '-',
            'Phone': e.value.cMobileNo ?? '-',
            'Status': (e.value.cActivationStatus ?? true) ? 'Active' : 'Inactive',
            '_model': e.value,
          },
        )
        .toList();

    return DataTableWidget(
      columns: columns,
      data: data,
      titleDatatableText: 'All Users',
      subTitleDatatableText: 'Manage application users',
      headerColor: appColors.primaryColor,
      headerColumnColor: appColors.textPrimaryColor,
      cellTextColor: appColors.primaryTextColor,
      // rowActions: {
      //   RowAction(RowActionType.modify, icon: Icons.edit_outlined),
      //   RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      // },
      onModify: (row) {
        final user = row['_model'] as AppUser;
        _onEditUserTap(context, user);
      },
      onDelete: (row) {
        final user = row['_model'] as AppUser;
        _onDeleteUserTap(context, user);
      },
      actionColumnName: 'Actions',
    );
  }

  Future<void> _onAddUserTap(BuildContext context) async {
    final result = await showDialog(context: context, builder: (context) => const AddUserPage());
    if (result is Map && result['name'] != null && result['email'] != null) {
      context.read<UsersBloc>().add(AddUserEvent(name: result['name'], email: result['email'], phone: result['phone'], isActive: result['isActive'] ?? true));
    }
  }

  Future<void> _onEditUserTap(BuildContext context, AppUser user) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddUserPage(user: user),
    );
    if (result is Map && result['name'] != null && result['email'] != null) {
      context.read<UsersBloc>().add(UpdateUserEvent(user: user, name: result['name'], email: result['email'], phone: result['phone'], isActive: result['isActive'] ?? true));
    }
  }

  Future<void> _onDeleteUserTap(BuildContext context, AppUser user) async {
    final shouldDelete = await AppCustomDialog.show<bool>(
      context: context,
      icon: Icons.delete_outline,
      iconBackgroundColor: appColors.red,
      title: 'Delete User',
      message: 'Are you sure you want to delete "${user.cName}"?',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.red,
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );
    if (shouldDelete == true) {
      context.read<UsersBloc>().add(DeleteUserEvent(userId: user.cId ?? ''));
    }
  }
}
