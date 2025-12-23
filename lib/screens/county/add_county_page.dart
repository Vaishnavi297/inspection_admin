import 'package:flutter/material.dart';
import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_button/app_button.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../data/data_structure/models/country.dart';

class AddCountyPage extends StatefulWidget {
  final County? county; // If provided, we're in edit mode

  const AddCountyPage({super.key, this.county});

  @override
  State<AddCountyPage> createState() => _AddCountyPageState();
}

class _AddCountyPageState extends State<AddCountyPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.county?.countyName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.county != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      backgroundColor: appColors.surfaceColor,
      constraints: BoxConstraints.expand(width: 500, height: 250),
      actionsOverflowButtonSpacing: s.s12,
      title: Text(
        isEditMode ? 'Edit County' : 'Add County',
        style: boldTextStyle(size: 18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
      ),
      content: Form(
        key: _formKey,
        child: textField(controller: _nameController, labelText: 'County Name', hintText: 'Enter county name', validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
      ),
      actionsPadding: EdgeInsets.only(left: s.s20, right: s.s20, bottom: s.s16),
      actions: [
        AppButton(
          height: 40,
          width: 140,
          backgroundColor: appColors.transparent,
          isBorderEnable: true,
          onTap: () => Navigator.of(context).pop(),
          btnWidget: Text('Cancel', style: primaryTextStyle(color: appColors.secondaryTextColor)),
        ),
        AppButton(height: 40, width: 140, strTitle: isEditMode ? 'Update' : 'Save', onTap: _onSave),
      ],
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;
    final name = _nameController.text.trim();

    Navigator.of(context).pop({'countyName': name, 'countyLowerName': name.toLowerCase(), 'county': widget.county});
  }
}
