import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/states/create_state_page.dart';

import '../../components/app_button/app_button.dart';
import '../../components/app_dialog/app_custom_dialog.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../components/loader_view.dart';
import '../../data/data_structure/models/state_model.dart';
import '../../data/repositories/state_repository/state_repository.dart';
import '../../utils/common/data_table/data_table.dart';
import '../../utils/common/data_table/utils.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';

class StateListPage extends StatefulWidget {
  const StateListPage({super.key});

  @override
  State<StateListPage> createState() => _StateListPageState();
}

class _StateListPageState extends State<StateListPage> {
  final StateRepository _repository = StateRepository.instance;

  /// SHOW ADD/EDIT DIALOG
  void _showAddEditDialog({StateModel? state, required BuildContext bContext}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (bContext) => CreateStatePage(
        state: state,
        onSave: (newState) async {
          try {
            if (state == null) {
              /// ADD STATE
              await _repository.addState(
                newState.copyWith(createTime: Timestamp.now()),
              );
            } else {
              /// EDIT STATE
              await _repository.updateState(
                state.stateId!,
                newState.copyWith(
                  updateTime: Timestamp.now(),
                  createTime: state.createTime,
                ),
              );
            }

            /// SHOW SUCCESS SNACKBAR
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state == null
                      ? 'State added successfully'
                      : 'State updated successfully',
                ),
                backgroundColor: appColors.successColor,
              ),
            );
            Navigator.of(bContext).pop();
          } catch (e) {
            /// SHOW ERROR SNACKBAR
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: appColors.errorColor,
              ),
            );
            Navigator.of(bContext).pop();
          }
        },
      ),
    );
  }

  /// DELETE STATE FROM FIRESTORE
  void _onDeleteState(StateModel state) {
    final stateId = state.stateId;

    if (stateId == null || stateId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Invalid state identifier. Please refresh and try again.',
          ),
          backgroundColor: appColors.errorColor,
        ),
      );
      return;
    }

    AppCustomDialog.show(
      context: context,
      title: 'Delete State',
      message: 'Are you sure you want to delete ${state.stateName}?',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      primaryButtonColor: appColors.errorColor,
      icon: Icons.delete_outlined,

      /// PRIMARY ACTION
      onPrimaryPressed: () async {
        Navigator.of(context).pop();
        try {
          await _repository.deleteState(stateId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('State deleted successfully')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting state: $e'),
              backgroundColor: appColors.errorColor,
            ),
          );
        }
      },

      /// CANCEL ACTION
      onSecondaryPressed: () {},
    );
  }

  Widget _buildDataTable(List<StateModel> states) {
    final data = states
        .asMap()
        .entries
        .map(
          (e) => {
            'Sr.No': (e.key + 1),
            'id': e.value.stateId,
            'Name': e.value.stateName,
            'Code': e.value.stateCode,
            '_model': e.value,
          },
        )
        .toList();

    return DataTableWidget(
      columns: const ['Sr.No', 'Name', 'Code'],
      data: data,
      actionColumnName: 'Actions',
      rowActions: {
        RowAction(RowActionType.modify, icon: Icons.edit_outlined),
        RowAction(RowActionType.delete, icon: Icons.delete_outlined),
      },
      onModify: (row) {
        final state = row['_model'] as StateModel;
        _showAddEditDialog(bContext: context, state: state);
      },
      onDelete: (row) {
        final state = row['_model'] as StateModel;
        _onDeleteState(state);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: s.s16, vertical: s.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State Management',
                      style: boldTextStyle(
                        size: FontSize.s20,
                        fontWeight: FontWeight.w600,
                        color: appColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: s.s4),
                    Text(
                      'Manage states and codes',
                      style: secondaryTextStyle(
                        size: FontSize.s12,
                        color: appColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                AppButton(
                  onTap: () =>
                      _showAddEditDialog(bContext: context, state: null),
                  width: 160,
                  height: 40,
                  btnWidget: Text(
                    'Add New State',
                    style: boldTextStyle(size: FontSize.s14),
                  ),
                ),
              ],
            ),
            SizedBox(height: s.s16),

            StreamBuilder<List<StateModel>>(
              stream: _repository.streamAllStates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: LoaderView(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(s.s40),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: secondaryTextStyle(color: appColors.errorColor),
                      ),
                    ),
                  );
                }
                final states = snapshot.data ?? [];
                return _buildDataTable(states);
              },
            ),
          ],
        ),
      ),
    );
  }
}
