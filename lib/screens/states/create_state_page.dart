import 'package:flutter/material.dart';

import '../../components/app_button/app_button.dart';
import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../data/data_structure/models/state_model.dart';
import '../../utils/common/decoration.dart';
import '../../utils/constants/app_colors.dart';

class CreateStatePage extends StatefulWidget {
  final StateModel? state;
  final Function(StateModel) onSave;

  const CreateStatePage({super.key, this.state, required this.onSave});

  @override
  State<CreateStatePage> createState() => _CreateStatePageState();
}

class _CreateStatePageState extends State<CreateStatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ///
    _nameController.text = widget.state?.stateName ?? '';
    _codeController.text = widget.state?.stateCode ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: appColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.state == null ? 'Add New State' : 'Edit State',
                style: boldTextStyle(
                  size: 20,
                  color: appColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              textField(
                controller: _nameController,
                labelText: 'State Name',
                hintText: 'Enter state name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state name';
                  }
                  return null;
                },
              ),
              textField(
                controller: _codeController,
                labelText: 'State Code',
                hintText: 'Enter state code',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: secondaryTextStyle(
                        color: appColors.secondaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final newState = StateModel(
                          stateId: widget.state?.stateId,
                          stateName: _nameController.text.trim(),
                          stateCode: _codeController.text.trim(),
                          createTime: widget.state?.createTime,
                          updateTime: widget.state?.updateTime,
                        );
                        widget.onSave(newState);
                      }
                    },
                    width: 100,
                    height: 40,
                    btnWidget: Text(
                      widget.state == null ? 'Add' : 'Save',
                      style: boldTextStyle(size: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
