import 'dart:math';
import 'package:flutter/material.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../data/data_structure/models/inspaction_station.dart';
import '../../data/repositories/inspaction_station_repository/inspaction_station_repository.dart';

class AddInspactorPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddInspactorPage({super.key, this.initialData});

  @override
  State<AddInspactorPage> createState() => _AddInspactorPageState();
}

class _AddInspactorPageState extends State<AddInspactorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _badgeController;
  InspactionStation? _selectedStation;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.initialData?['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.initialData?['lastName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialData?['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialData?['phone'] ?? '',
    );
    _badgeController = TextEditingController(
      text: widget.initialData?['badgeId'] ?? _generateBadgeId(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  String _generateBadgeId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random();
    final numPart = (300 + rand.nextInt(400)).toString();
    final suffix =
        '${chars[rand.nextInt(chars.length)]}${chars[rand.nextInt(chars.length)]}';
    return 'WV-$numPart-$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
      contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
      backgroundColor: appColors.surfaceColor,
      constraints: BoxConstraints.expand(width: 720, height: 520),
      actionsOverflowButtonSpacing: s.s12,
      title: Text(
        widget.initialData == null ? 'Add New Inspector' : 'Update Inspector',
        style: boldTextStyle(
          size: 18,
          fontWeight: FontWeight.w600,
          color: appColors.primaryTextColor,
        ),
      ),
      content: Form(
        key: _formKey,
        child: FutureBuilder<List<InspactionStation>>(
          future: InspactionStationRepository.instance.getAllStations(),
          builder: (context, snapshot) {
            final stations = snapshot.data ?? const <InspactionStation>[];
            if (_selectedStation == null && stations.isNotEmpty) {
              _selectedStation = stations.first;
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: textField(
                          controller: _firstNameController,
                          labelText: 'First Name *',
                          hintText: 'Enter first name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      SizedBox(width: s.s12),
                      Expanded(
                        child: textField(
                          controller: _lastNameController,
                          labelText: 'Last Name *',
                          hintText: 'Enter last name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s.s12),
                  textField(
                    controller: _emailController,
                    labelText: 'Email Address *',
                    hintText: 'inspector@inspectionwv.gov',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: s.s12),
                  Row(
                    children: [
                      Expanded(
                        child: textField(
                          controller: _phoneController,
                          labelText: 'Phone Number *',
                          hintText: '(304) 555-0123',
                          inputType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      SizedBox(width: s.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 8),
                              child: Text(
                                'Station *',
                                style: primaryTextStyle(
                                  color: appColors.textSecondaryColor,
                                ),
                              ),
                            ),
                            DropdownButtonFormField(
                              initialValue: _selectedStation?.sId,
                              isDense: true,
                              focusColor: appColors.primaryColor,
                              decoration: defaultInputDecoration(),
                              items: stations
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.sId,
                                      child: Text(s.stationName),
                                    ),
                                  )
                                  .toList(),

                              onChanged: (id) => setState(
                                () => _selectedStation = stations.firstWhere(
                                  (x) => x.sId == id,
                                ),
                              ),

                              icon: Icon(
                                Icons.expand_more,
                                color: appColors.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s.s12),
                  Row(
                    children: [
                      Expanded(
                        child: textField(
                          controller: _badgeController,
                          labelText: 'Badge ID',
                          hintText: 'WV-512-JB',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s.s12),
                  Row(
                    children: [
                      AppButton(
                        height: 40,
                        width: 200,
                        strTitle: 'Generate Badge',
                        onTap: () => setState(() {
                          _badgeController.text = _generateBadgeId();
                        }),
                      ),
                      SizedBox(width: s.s16),
                    ],
                  ),
                ],
              ),
            );
          },
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
          btnWidget: Text(
            'Cancel',
            style: primaryTextStyle(color: appColors.secondaryTextColor),
          ),
        ),
        AppButton(
          height: 40,
          width: 180,
          strTitle: widget.initialData == null
              ? 'Create Inspector'
              : 'Update Inspector',
          onTap: _onSave,
        ),
      ],
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true || _selectedStation == null) {
      return;
    }
    Navigator.of(context).pop({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'badgeId': _badgeController.text.trim(),
      'stationId': _selectedStation!.sId,
      'stationName': _selectedStation!.stationName,
    });
  }
}
