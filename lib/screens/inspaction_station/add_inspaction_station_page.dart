import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/working_hours_bloc.dart';
import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_button/app_button.dart';
import '../../components/app_text_style/app_text_style.dart';
import '../../data/data_structure/models/inspaction_station.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_dimension.dart';
import '../../data/repositories/county_repository/county_repository.dart';
import '../../data/data_structure/models/country.dart';
import '../../data/services/firebase_service/firebase_authentication_services.dart';

class AddInspactionStationPage extends StatefulWidget {
  final InspactionStation? station;
  const AddInspactionStationPage({super.key, this.station});

  @override
  State<AddInspactionStationPage> createState() => _AddInspactionStationPageState();
}

class _AddInspactionStationPageState extends State<AddInspactionStationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _stationIdController = TextEditingController();
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
 // final TextEditingController _maxInspectorsController = TextEditingController(text: '1');
  final TextEditingController _descriptionController = TextEditingController();

  County? _selectedCounty;
  String? _selectedCountyId;
  bool _active = true;

  String? stationCountry="+91";

  @override
  void initState() {
    super.initState();
    if (widget.station != null) {
      _stationIdController.text = widget.station!.stationId ?? '';
      _stationNameController.text = widget.station!.stationName;
      _addressController.text = widget.station!.stationAddress ?? '';
      _phoneController.text = widget.station!.stationContactNumber ?? '';
     // _maxInspectorsController.text = (widget.station!.inspactors ?? 1).toString();
      _descriptionController.text = widget.station!.stationDescription ?? '';
      _active = widget.station!.stationActivationStatus ?? true;
      _selectedCounty = widget.station!.sCountyDetails;
      _selectedCountyId = widget.station!.sCountyDetails?.countyId;
    }
  }

  @override
  void dispose() {
    _stationIdController.dispose();
    _stationNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
  //  _maxInspectorsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkingHoursBloc(widget.station?.workingHours),
      child: Builder(
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.only(left: s.s20, right: s.s20, top: s.s16),
          contentPadding: EdgeInsets.symmetric(horizontal: s.s20, vertical: s.s8),
          backgroundColor: appColors.surfaceColor,
          constraints: BoxConstraints.expand(width: 720, height: 600),
          actionsOverflowButtonSpacing: s.s12,
          title: Text(
            widget.station != null ? 'Update Station' : 'Add New Station',
            style: boldTextStyle(size: 18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
          ),
          content: FutureBuilder<List<County>>(
            future: CountyRepository.instance.getAllCounties(),
            builder: (context, snapshot) {
              final counties = snapshot.data ?? const <County>[];
              if (_selectedCountyId == null && counties.isNotEmpty) {
                _selectedCountyId = counties.first.countyId ?? counties.first.countyLowerName;
                _selectedCounty = counties.first;
              }
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: s.s16,
                        children: [
                          Expanded(
                            child: textField(
                              controller: _stationIdController,
                              labelText: 'Station ID *',
                              hintText: 'e.g., 1398',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          Expanded(
                            child: textField(
                              controller: _stationNameController,
                              labelText: 'Station Name *',
                              hintText: 'e.g., Kanawha Blvd Charleston',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      // Registration via mobile OTP; email credential field removed.
                      textField(
                        controller: _addressController,
                        labelText: 'Address *',
                        hintText: '123 Kanawha Blvd, Charleston, WV 25301',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      Row(
                        spacing: s.s16,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 20, bottom: 12),
                                  child: Text(
                                    'County *',
                                    style: GoogleFonts.ptSans(fontSize: FontSize.s14, color: appColors.textSecondaryColor, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DropdownButtonFormField(
                                  value: _selectedCountyId,
                                  isDense: true,
                                  focusColor: appColors.primaryColor,
                                  decoration: defaultInputDecoration(),
                                  items: counties.map((c) => DropdownMenuItem<String>(value: c.countyId ?? c.countyLowerName, child: Text(c.countyName))).toList(),
                                  onChanged: (id) => setState(() {
                                    _selectedCountyId = id;
                                    _selectedCounty = counties.firstWhere((c) => (c.countyId ?? c.countyLowerName) == id);
                                  }),
                                  icon: Icon(Icons.expand_more, color: appColors.textSecondaryColor),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: textField(
                              controller: _phoneController,
                              labelText: 'Phone *',
                              hintText: '(304) 555-0123',
                              prefix:  Text(stationCountry ?? '', style: primaryTextStyle()),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        
                      ],
                    ),
                    _WorkingHoursSection(),

                      // Row(
                      //   spacing: s.s16,
                      //   children: [
                      //     Expanded(
                      //       child: textField(
                      //         controller: _maxInspectorsController,
                      //         labelText: 'Max Inspectors',
                      //         hintText: '5',
                      //         inputType: TextInputType.number,
                      //         validator: (v) {
                      //           if (v == null || v.trim().isEmpty) return null;
                      //           final n = int.tryParse(v.trim());
                      //           if (n == null || n <= 0) return 'Invalid number';
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      textField(controller: _descriptionController, labelText: 'Description', hintText: 'Additional details about this station', maxLines: 4),
                      Row(
                        children: [
                          Checkbox(value: _active, onChanged: (v) => setState(() => _active = v ?? true), activeColor: appColors.primaryColor),
                          Text('Active Station', style: primaryTextStyle(color: appColors.textPrimaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actionsPadding: EdgeInsets.only(left: s.s20, right: s.s20, bottom: s.s16),
          actions: [
            AppButton(
              height: 40,
              width: 140,
              backgroundColor: appColors.transparent,
              isBorderEnable: true,
              onTap: () => Navigator.of(dialogContext).pop(),
              btnWidget: Text('Cancel', style: primaryTextStyle(color: appColors.secondaryTextColor)),
            ),
            AppButton(height: 40, width: 160, strTitle: widget.station != null ? 'Update Station' : 'Add New Station', onTap: () => _onSave(dialogContext)),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave(BuildContext dialogContext) async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedCounty == null) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: const Text('Select County'), backgroundColor: appColors.errorColor));
      return;
    }

    final hoursBloc = dialogContext.read<WorkingHoursBloc>();
    hoursBloc.add(const ValidateEvent());

    // Wait for the validation event to be processed and state to update
    // Skip the current state and wait for the next one (after validation)
    await hoursBloc.stream.skip(1).first;

    final errors = hoursBloc.state.errors;
    if (errors.isNotEmpty) {
      final first = errors.entries.first;
      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('${WorkingHoursBloc.dayLabels[first.key]}: ${first.value}'), backgroundColor: appColors.errorColor));
      return;
    }

    final apiHours = hoursBloc.toWorkingHours();

    String _normalizePhoneWithCountry(String input, String? countryCode) {
      final cc = (countryCode ?? '').trim();
      final cleanedCc = cc.startsWith('+') ? cc : (cc.isEmpty ? '+1' : '+$cc');
      final raw = input.trim();
      if (raw.isEmpty) return '';
      if (raw.startsWith('+')) return raw.replaceAll(RegExp(r'[^+0-9]'), '');
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return '';
      if (digits.length > 0 && cleanedCc == '+1') {
        if (digits.length == 11 && digits.startsWith('1')) return '+$digits';
        if (digits.length == 10) return '$cleanedCc$digits';
      }
      return '$cleanedCc$digits';
    }
    final phone = _normalizePhoneWithCountry(_phoneController.text, stationCountry);
    String? authUid;
    if (phone.isNotEmpty) {
      try {
        final verificationId = await AuthService.instance.sendOtp(phoneNumber: phone);
        final smsCode = await _promptOtpInput(context, phone);
        if (smsCode == null || smsCode.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('OTP verification cancelled'), backgroundColor: appColors.errorColor));
          return;
        }
        final cred = await AuthService.instance.verifyOtp(verificationId: verificationId, smsCode: smsCode.trim());
        authUid = cred.user?.uid;
      } catch (e) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Phone verification failed: $e'), backgroundColor: appColors.errorColor));
        log('Phone verification failed: $e');

        return;
      }
    }

    InspactionStation station = InspactionStation(
      stationId: _stationIdController.text.trim(),
      stationName: _stationNameController.text.trim(),
      // stationNameLower: _stationNameController.text.trim().toLowerCase(),
      stationAuthUid: authUid,
      stationAddress: _addressController.text.trim(),
      stationContactNumber: phone,
      sCountyDetails: _selectedCounty!,
    //  inspactors: int.tryParse(_maxInspectorsController.text.trim() == '' ? '0' : _maxInspectorsController.text.trim()) ?? 0,
      stationDescription: _descriptionController.text.trim(),
      stationActivationStatus: _active,
      createTime: Timestamp.fromDate(DateTime.now()),
      updateTime: Timestamp.fromDate(DateTime.now()),

      workingHours: apiHours,
    );

    Navigator.of(dialogContext).pop(station);
  }

  Future<String?> _promptOtpInput(BuildContext context, String phone) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Enter OTP',
          style: boldTextStyle(size: 18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('OTP sent to $phone', style: secondaryTextStyle(color: appColors.secondaryTextColor)),
            SizedBox(height: s.s12),
            textField(controller: controller, labelText: 'OTP Code', hintText: '123456'),
          ],
        ),
        actions: [
          AppButton(
            height: 40,
            width: 140,
            backgroundColor: appColors.transparent,
            isBorderEnable: true,
            onTap: () => Navigator.of(ctx).pop(null),
            btnWidget: Text('Cancel', style: primaryTextStyle(color: appColors.secondaryTextColor)),
          ),
          AppButton(height: 40, width: 160, strTitle: 'Verify', onTap: () => Navigator.of(ctx).pop(controller.text.trim())),
        ],
      ),
    );
    return result;
  }
}

class _WorkingHoursSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: s.s20),
      child: Column(
      
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apply All Section (replaces timezone section)
          Text(
            'Working Hours',
            style: GoogleFonts.ptSans(fontSize: FontSize.s14, color: appColors.textSecondaryColor, fontWeight: FontWeight.w500),
          ),

          BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
            buildWhen: (previous, current) => previous.selectedDays.length != current.selectedDays.length,
            builder: (context, state) {
              // Show button only when at least 1 day is selected
              if (state.selectedDays.isNotEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: s.s12),
                          Text(
                            'Apply All',
                            style:primaryTextStyle(size: FontSize.s14),
                          ),
                          SizedBox(height: s.s4),
                          Text(
                            'Apply Schedule like selected day',
                            style: secondaryTextStyle(size: FontSize.s12, color: appColors.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                    AppButton(onTap: () => context.read<WorkingHoursBloc>().add(const SelectAllEvent()), width: 150, height: 35,
                      backgroundColor: appColors.transparent,

                      borderColor: appColors.primaryColor, 
                      isBorderEnable: true,
                      btnWidget: Text('Apply Weekly Schedule', style: secondaryTextStyle(color: appColors.primaryTextColor)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: s.s12),
          // Week Days List
          BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
            builder: (context, state) {
              return Column(children: WorkingHoursBloc.daysOrder.map((day) => _WeekDayRow(day: day)).toList());
            },
          ),
        ],
      ),
    );
  }
}

class _WeekDayRow extends StatelessWidget {
  final String day;
  const _WeekDayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
      buildWhen: (previous, current) =>
          previous.selectedDays.contains(day) != current.selectedDays.contains(day) || previous.startTimes[day] != current.startTimes[day] || previous.endTimes[day] != current.endTimes[day],
      builder: (context, state) {
        final isSelected = state.selectedDays.contains(day);
        final startTime = state.startTimes[day];
        final endTime = state.endTimes[day];

        return Padding(
          padding: EdgeInsets.symmetric(vertical: s.s8),
          child: Row(
            children: [
              // Day name
              SizedBox(
                width: 100,
                child: Text(_getDayFullName(day), style: primaryTextStyle(color: appColors.primaryTextColor)),
              ),
              SizedBox(width: s.s12),
              // Toggle Switch
              Switch(
                value: isSelected,
                onChanged: (value) {
                  context.read<WorkingHoursBloc>().add(ToggleDayEvent(day));
                },
                activeThumbColor: appColors.primaryColor,
              ),
              SizedBox(width: s.s16),
              // Time fields or Closed status
              if (isSelected) ...[
                // From field
                Expanded(
                  child: _TimeInputField(day: day, isStart: true, label: 'From', value: startTime),
                ),
                SizedBox(width: s.s12),
                // To field
                Expanded(
                  child: _TimeInputField(day: day, isStart: false, label: 'To', value: endTime),
                ),
              ] else ...[
                // Closed status
                Expanded(
                  child: Container(
        padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s10),
        decoration: BoxDecoration(
          border: Border.all(color: appColors.textSecondaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
                    child: Row(
                      children: [
                        Icon(Icons.nightlight_outlined, size: 18, color: appColors.textSecondaryColor),
                        SizedBox(width: s.s8),
                        Text('Closed', style: secondaryTextStyle(color: appColors.textSecondaryColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getDayFullName(String day) {
    const dayNames = {'mon': 'Monday', 'tue': 'Tuesday', 'wed': 'Wednesday', 'thu': 'Thursday', 'fri': 'Friday', 'sat': 'Saturday', 'sun': 'Sunday'};
    return dayNames[day] ?? day.toUpperCase();
  }
}

class _TimeInputField extends StatelessWidget {
  final String day;
  final bool isStart;
  final String label;
  final String? value;

  const _TimeInputField({required this.day, required this.isStart, required this.label, required this.value});

  String _formatTime(String? hhmm) {
    if (hhmm == null || hhmm.isEmpty) return '';
    try {
      final parts = hhmm.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');
      return '$displayHour:$displayMinute $period';
    } catch (e) {
      return hhmm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = _formatTime(value);
    final isEmpty = value == null || value!.isEmpty;

    return InkWell(
      onTap: () async {
        final initial = value != null ? TimeOfDay(hour: int.parse(value!.split(':')[0]), minute: int.parse(value!.split(':')[1])) : const TimeOfDay(hour: 9, minute: 0);
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          final hh = picked.hour.toString().padLeft(2, '0');
          final mm = picked.minute.toString().padLeft(2, '0');
          final hhmm = '$hh:$mm';
          final bloc = context.read<WorkingHoursBloc>();
          if (isStart) {
            bloc.add(SetStartEvent(day, hhmm));
          } else {
            bloc.add(SetEndEvent(day, hhmm));
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: s.s12, vertical: s.s10),
        decoration: BoxDecoration(
          border: Border.all(color: appColors.textSecondaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: s.s4,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.ptSans(fontSize: FontSize.s12, color: appColors.textSecondaryColor),
                ),
                SizedBox(height: s.s4),
                Text(isEmpty ? label : displayValue, style: primaryTextStyle(color: isEmpty ? appColors.textSecondaryColor : appColors.primaryTextColor)),
              ],
            ),
            Icon(Icons.access_time, size: 18, color: appColors.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}
