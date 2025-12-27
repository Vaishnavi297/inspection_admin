import 'package:flutter/material.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../data/data_structure/models/user.dart';

class AddUserPage extends StatefulWidget {
  final AppUser? user;
  const AddUserPage({super.key, this.user});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.cName ?? '');
    _emailController = TextEditingController(text: widget.user?.cEmail ?? '');
    _phoneController = TextEditingController(text: widget.user?.cMobileNo ?? '');
    _isActive = widget.user?.cActivationStatus ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.user != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      backgroundColor: appColors.surfaceColor,
      constraints: BoxConstraints.expand(width: 560),
      actionsOverflowButtonSpacing: s.s12,
      title: Text(
        isEditMode ? 'Edit User' : 'Add User',
        style: boldTextStyle(size: 18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              textField(controller: _nameController, labelText: 'Name', hintText: 'Enter full name', validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              Row(
                spacing: s.s12,
                children: [
                  Expanded(
                    child: textField(controller: _emailController, labelText: 'Email', hintText: 'Enter email', validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                  ),
                  Expanded(
                    child: textField(controller: _phoneController, labelText: 'Phone', hintText: 'Enter phone'),
                  ),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active', style: primaryTextStyle()),
                  Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                ],
              ),
            ],
          ),
        ),
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
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    Navigator.of(context).pop({'name': name, 'email': email, 'phone': phone.isEmpty ? null : phone, 'isActive': _isActive, 'user': widget.user});
  }
}
