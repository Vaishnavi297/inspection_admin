import 'package:flutter/material.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';

class AddVehiclePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddVehiclePage({super.key, this.initialData});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _plateController;
  late final TextEditingController _vinController;
  late final TextEditingController _stateController;
  late final TextEditingController _modelController;
  late final TextEditingController _mileageController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _cIdController;
  late DateTime? _lastInspectionDate;
  bool _isActive = true;
  String? _sticker;
  String? _docVerification;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['vName'] ?? '');
    _titleController = TextEditingController(text: widget.initialData?['vTitle'] ?? '');
    _plateController = TextEditingController(text: widget.initialData?['vPlateNumber'] ?? '');
    _vinController = TextEditingController(text: widget.initialData?['vVin'] ?? '');
    _stateController = TextEditingController(text: widget.initialData?['vState'] ?? '');
    _modelController = TextEditingController(text: widget.initialData?['vModel'] ?? '');
    _mileageController = TextEditingController(text: widget.initialData?['vMileage'] ?? '');
    _imageUrlController = TextEditingController(text: widget.initialData?['vImageUrl'] ?? '');
    _cIdController = TextEditingController(text: widget.initialData?['cID'] ?? '');
    _lastInspectionDate = widget.initialData?['vLastInspectionDate'];
    _isActive = widget.initialData?['vActivationStatus'] ?? true;
    _sticker = widget.initialData?['vCurrentInspectionSticker'];
    _docVerification = widget.initialData?['documentVerificationStatus'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _plateController.dispose();
    _vinController.dispose();
    _stateController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    _imageUrlController.dispose();
    _cIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.initialData != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      backgroundColor: appColors.surfaceColor,
      constraints: BoxConstraints.expand(width: 720, height: 560),
      actionsOverflowButtonSpacing: s.s12,
      title: Text(
        isUpdate ? 'Update Vehicle' : 'Add Vehicle',
        style: boldTextStyle(size: 18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: textField(controller: _nameController, labelText: 'Name', hintText: 'Vehicle name')),
                  SizedBox(width: s.s12),
                  Expanded(child: textField(controller: _titleController, labelText: 'Title', hintText: 'Vehicle title')),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                children: [
                  Expanded(child: textField(controller: _plateController, labelText: 'Plate Number *', hintText: 'ABC-123', validator: _required)),
                  SizedBox(width: s.s12),
                  Expanded(child: textField(controller: _vinController, labelText: 'VIN *', hintText: '1HGCM82633A...', validator: _required)),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                children: [
                  Expanded(child: textField(controller: _stateController, labelText: 'State', hintText: 'WV')),
                  SizedBox(width: s.s12),
                  Expanded(child: textField(controller: _modelController, labelText: 'Model', hintText: 'Honda CR-V')),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                children: [
                  Expanded(child: textField(controller: _mileageController, labelText: 'Mileage', hintText: '120,000')),
                  SizedBox(width: s.s12),
                  Expanded(child: textField(controller: _imageUrlController, labelText: 'Image URL', hintText: 'https://...')),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                children: [
                  Expanded(child: textField(controller: _cIdController, labelText: 'Customer ID', hintText: 'c_id')),
                  SizedBox(width: s.s12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sticker,
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      ],
                      onChanged: (val) => setState(() => _sticker = val),
                      decoration: InputDecoration(labelText: 'Inspection Sticker', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _docVerification,
                      items: const [
                        DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                        DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      ],
                      onChanged: (val) => setState(() => _docVerification = val),
                      decoration: InputDecoration(labelText: 'Documents Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  SizedBox(width: s.s12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickLastInspectionDate,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: 'Last Inspection Date', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(
                          _lastInspectionDate == null ? 'Select date' : '${_lastInspectionDate!.day.toString().padLeft(2, '0')}/${_lastInspectionDate!.month.toString().padLeft(2, '0')}/${_lastInspectionDate!.year}',
                          style: primaryTextStyle(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: s.s12),
              Row(
                children: [
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  SizedBox(width: s.s8),
                  Text('Active', style: secondaryTextStyle()),
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
        AppButton(
          height: 40,
          width: 180,
          strTitle: isUpdate ? 'Update Vehicle' : 'Create Vehicle',
          onTap: _onSave,
        ),
      ],
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _pickLastInspectionDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _lastInspectionDate ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 5),
    );
    if (result != null) {
      setState(() => _lastInspectionDate = result);
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop({
      'cID': _cIdController.text.trim().isEmpty ? null : _cIdController.text.trim(),
      'vName': _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      'vTitle': _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      'vPlateNumber': _plateController.text.trim(),
      'vImageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      'vVin': _vinController.text.trim(),
      'vState': _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      'vCurrentInspectionSticker': _sticker,
      'vLastInspectionDate': _lastInspectionDate,
      'vActivationStatus': _isActive,
      'documentVerificationStatus': _docVerification,
      'insuranceDocumentsIdList': widget.initialData?['insuranceDocumentsIdList'],
      'registrationDocumentsIdList': widget.initialData?['registrationDocumentsIdList'],
      'vModel': _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      'vMileage': _mileageController.text.trim().isEmpty ? null : _mileageController.text.trim(),
    });
  }
}
