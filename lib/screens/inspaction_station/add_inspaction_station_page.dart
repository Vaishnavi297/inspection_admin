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
  final TextEditingController _maxInspectorsController = TextEditingController(text: '1');
  final TextEditingController _descriptionController = TextEditingController();

  County? _selectedCounty;
  String? _selectedCountyId;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    if (widget.station != null) {
      _stationIdController.text = widget.station!.stationId ?? '';
      _stationNameController.text = widget.station!.stationName;
      _addressController.text = widget.station!.stationAddress ?? '';
      _phoneController.text = widget.station!.stationContactNumber ?? '';
      _maxInspectorsController.text = (widget.station!.maxInspectors ?? 1).toString();
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
    _maxInspectorsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkingHoursBloc().seedFromJson(widget.station?.workingHours),
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
                            child: textField(controller: _phoneController, labelText: 'Phone *', hintText: '(304) 555-0123', validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                          ),
                        ],
                      ),
                      _WorkingHoursSection(),
                      Row(
                        spacing: s.s16,
                        children: [
                          Expanded(
                            child: textField(
                              controller: _maxInspectorsController,
                              labelText: 'Max Inspectors',
                              hintText: '5',
                              inputType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final n = int.tryParse(v.trim());
                                if (n == null || n <= 0) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
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
    final errors = hoursBloc.state.errors;
    if (errors.isNotEmpty) {
      final first = errors.entries.first;
      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('${WorkingHoursBloc.dayLabels[first.key]}: ${first.value}'), backgroundColor: appColors.errorColor));
      return;
    }

    final apiHours = hoursBloc.toApiJson();

    final phone = _phoneController.text.trim();
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
      stationContactNumber: _phoneController.text.trim(),
      sCountyDetails: _selectedCounty!,
      maxInspectors: int.tryParse(_maxInspectorsController.text.trim() == '' ? '0' : _maxInspectorsController.text.trim()) ?? 0,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 12),
          child: Text(
            'Working Hours',
            style: GoogleFonts.ptSans(fontSize: FontSize.s14, color: appColors.textSecondaryColor, fontWeight: FontWeight.w500),
          ),
        ),
        Wrap(
          spacing: s.s8,
          runSpacing: s.s8,
          children: WorkingHoursBloc.daysOrder.map((day) => _DayChip(day: day)).toList(),
        ),
        SizedBox(height: s.s12),
        BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
          builder: (context, state) {
            final selected = state.selectedDays.toList();
            return Column(children: selected.map((day) => _DayTimeRow(day: day)).toList());
          },
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final String day;
  const _DayChip({required this.day});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
      buildWhen: (p, n) => p.selectedDays.contains(day) != n.selectedDays.contains(day),
      builder: (context, state) {
        final selected = state.selectedDays.contains(day);
        return ChoiceChip(selected: selected, label: Text(WorkingHoursBloc.dayLabels[day]!), onSelected: (_) => context.read<WorkingHoursBloc>().add(ToggleDayEvent(day)));
      },
    );
  }
}

class _DayTimeRow extends StatelessWidget {
  final String day;
  const _DayTimeRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.s6),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(WorkingHoursBloc.dayLabels[day]!, style: primaryTextStyle())),
          SizedBox(width: s.s8),
          _TimeChip(day: day, isStart: true),
          SizedBox(width: s.s8),
          _TimeChip(day: day, isStart: false),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String day;
  final bool isStart;
  const _TimeChip({required this.day, required this.isStart});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
      builder: (context, state) {
        final label = isStart ? 'Start' : 'End';
        final value = isStart ? state.startTimes[day] : state.endTimes[day];
        return ActionChip(
          label: Text(value ?? label),
          onPressed: () async {
            final initial = value != null ? TimeOfDay(hour: int.parse(value.split(':')[0]), minute: int.parse(value.split(':')[1])) : const TimeOfDay(hour: 9, minute: 0);
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
        );
      },
    );
  }
}
