// import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../../utils/extensions/context_extension.dart';
// import '../components.dart';

// class UIDateDropdownMenu extends StatefulWidget {
//   final DateTime? initialDate;
//   final DateTime? initialFromDate;
//   final DateTime? initialToDate;
//   final bool isRange;
//   final double? width;
//   final double? height;
//   final String? hintText;
//   final TextStyle? hintTextStyle;
//   final Color? backgroundColor;
//   final Color? borderColor;
//   final String? errorText;
//   final bool enabled;
//   final ValueChanged<DateTime?>? onDateSelected;
//   final ValueChanged<DateTimeRange?>? onDateRangeSelected;
//   final Widget Function(bool isOpen)? trailingIconBuilder;
//   final TextEditingController? dropdownController;
//   final InputDecoration? inputDecoration;

//   const UIDateDropdownMenu({
//     super.key,
//     this.initialDate,
//     this.initialFromDate,
//     this.initialToDate,
//     this.isRange = false,
//     this.width = 320,
//     this.height = 400,
//     this.hintText,
//     this.hintTextStyle,
//     this.backgroundColor,
//     this.borderColor,
//     this.errorText,
//     this.enabled = true,
//     this.onDateSelected,
//     this.onDateRangeSelected,
//     this.trailingIconBuilder = defaultIconBuilder,
//     this.dropdownController,
//     this.inputDecoration,
//   });

//   @override
//   State<UIDateDropdownMenu> createState() => _UIDateDropdownMenuState();
// }

// class _UIDateDropdownMenuState extends State<UIDateDropdownMenu> {
//   DateTime? _selectedDate;
//   DateTime? _selectedFromDate;
//   DateTime? _selectedToDate;
//   late TextEditingController _effectiveController;
//   bool _isInternalController = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeState();
//   }

//   void _initializeState() {
//     _selectedDate = widget.initialDate;
//     _selectedFromDate = widget.initialFromDate;
//     _selectedToDate = widget.initialToDate;

//     _isInternalController = widget.dropdownController == null;
//     _effectiveController = widget.dropdownController ?? TextEditingController();
//     _updateControllerText();
//   }

//   @override
//   void didUpdateWidget(UIDateDropdownMenu oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Only update if the controller reference changed
//     if (widget.dropdownController != oldWidget.dropdownController) {
//       if (_isInternalController) {
//         _effectiveController.dispose();
//       }
//       _initializeState();
//     } else {
//       // Just update the dates if they changed
//       _selectedDate = widget.initialDate;
//       _selectedFromDate = widget.initialFromDate;
//       _selectedToDate = widget.initialToDate;
//       _updateControllerText();
//     }
//   }

//   void _updateControllerText() {
//     if (widget.isRange) {
//       if (_selectedFromDate != null && _selectedToDate != null) {
//         _effectiveController.text = '${DateFormat('dd MMM yyyy').format(_selectedFromDate!)} - ${DateFormat('dd MMM yyyy').format(_selectedToDate!)}';
//       } else if (_selectedFromDate != null) {
//         _effectiveController.text = DateFormat('dd MMM yyyy').format(_selectedFromDate!);
//       } else if (_effectiveController.text.isEmpty) {
//         _effectiveController.text = '';
//       }
//     } else {
//       if (_selectedDate != null) {
//         _effectiveController.text = DateFormat('dd MMM yyyy').format(_selectedDate!);
//       } else if (_effectiveController.text.isEmpty) {
//         _effectiveController.text = '';
//       }
//     }
//   }

//   @override
//   void dispose() {
//     if (_isInternalController) {
//       _effectiveController.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final MenuController menuController = MenuController();

//     return SizedBox(
//       width: widget.width,
//       child: MenuAnchor(
//         style: MenuStyle(backgroundColor: MaterialStateProperty.all(widget.backgroundColor ?? context.colorScheme.surface)),
//         controller: menuController,
//         menuChildren: [_buildCalendarMenu(menuController)],
//         builder: (context, controller, child) => _buildAnchor(context, controller),
//       ),
//     );
//   }

//   Widget _buildCalendarMenu(MenuController menuController) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(minWidth: widget.width ?? 320, maxWidth: widget.width ?? 320, maxHeight: widget.height ?? 400),
//       child: SingleChildScrollView(
//         child: Column(children: [widget.isRange ? _buildRangeCalendar(menuController) : _buildSingleCalendar(menuController), const Divider(height: 1), _buildActionButtons(menuController)]),
//       ),
//     );
//   }

//   Widget _buildSingleCalendar(MenuController menuController) {
//     return CalendarDatePicker2(
//       config: CalendarDatePicker2Config(
//         calendarType: CalendarDatePicker2Type.single,
//         dayTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colorScheme.tertiary),
//         selectedDayTextStyle: TextStyle(color: context.colorScheme.tertiary),
//         controlsTextStyle: TextStyle(color: context.colorScheme.tertiary),
//         weekdayLabelTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorScheme.tertiary),
//         yearTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorScheme.tertiary),
//         monthTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorScheme.tertiary),
//         lastDate: DateTime.now(),
//         firstDate: DateTime(2000),
//         currentDate: _selectedDate ?? DateTime.now(),
//         selectedDayHighlightColor: context.colorScheme.primary,
//         controlsHeight: 48,
//       ),
//       value: _selectedDate != null ? [_selectedDate!] : [],
//       onValueChanged: (dates) {
//         setState(() {
//           _selectedDate = dates.isNotEmpty ? dates[0] : null;
//         });
//       },
//     );
//   }

//   Widget _buildRangeCalendar(MenuController menuController) {
//     return CalendarDatePicker2(
//       config: CalendarDatePicker2Config(
//         calendarType: CalendarDatePicker2Type.range,
//         dayTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colorScheme.tertiary),
//         selectedDayTextStyle: TextStyle(color: context.colorScheme.tertiary),
//         controlsTextStyle: TextStyle(color: context.colorScheme.tertiary),
//         weekdayLabelTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorScheme.tertiary),
//         yearTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorScheme.tertiary),
//         monthTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colorScheme.tertiary),
//         lastDate: DateTime.now(),
//         firstDate: DateTime(2000),
//         currentDate: _selectedFromDate ?? DateTime.now(),
//         selectedDayHighlightColor: context.colorScheme.primary,
//         controlsHeight: 48,
//       ),
//       value: [if (_selectedFromDate != null) _selectedFromDate!, if (_selectedToDate != null) _selectedToDate!],
//       onValueChanged: (dates) {
//         setState(() {
//           _selectedFromDate = dates.isNotEmpty ? dates[0] : null;
//           _selectedToDate = dates.length > 1 ? dates[1] : null;
//         });
//       },
//     );
//   }

//   Widget _buildActionButtons(MenuController menuController) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _selectedDate = null;
//                 _selectedFromDate = null;
//                 _selectedToDate = null;
//                 _effectiveController.text = '';
//               });
//               menuController.close();
//               if (widget.isRange) {
//                 widget.onDateRangeSelected?.call(null);
//               } else {
//                 widget.onDateSelected?.call(null);
//               }
//             },
//             child: const Text('Clear'),
//           ),
//           TextButton(
//             onPressed: () {
//               _updateControllerText();
//               menuController.close();
//               if (widget.isRange) {
//                 if (_selectedFromDate != null && _selectedToDate != null) {
//                   widget.onDateRangeSelected?.call(DateTimeRange(start: _selectedFromDate!, end: _selectedToDate!));
//                 } else if (_selectedFromDate != null) {
//                   widget.onDateRangeSelected?.call(DateTimeRange(start: _selectedFromDate!, end: _selectedFromDate!));
//                 }
//               } else if (_selectedDate != null) {
//                 widget.onDateSelected?.call(_selectedDate);
//               }
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnchor(BuildContext context, MenuController controller) {
//     return TextField(
//       controller: _effectiveController,
//       readOnly: true,
//       enabled: widget.enabled,
//       onTap: () {
//         if (widget.enabled && !controller.isOpen) {
//           controller.open();
//         }
//       },
//       style: widget.hintTextStyle ?? TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
//       decoration:
//           widget.inputDecoration ??
//           InputDecoration(
//             filled: true,
//             // fillColor: widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
//             suffixIcon: widget.trailingIconBuilder?.call(controller.isOpen),
//             border: OutlineInputBorder(
//               borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).colorScheme.primaryContainer),
//               borderRadius: BorderRadius.circular(4.0),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).colorScheme.primaryContainer),
//               borderRadius: BorderRadius.circular(4.0),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).colorScheme.primaryContainer),
//               borderRadius: BorderRadius.circular(4.0),
//             ),
//             hintText: widget.hintText ?? (widget.isRange ? 'Select date range' : 'Select date'),
//             hintStyle: widget.hintTextStyle ?? TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
//             errorText: widget.errorText,
//           ),
//     );
//   }
// }
