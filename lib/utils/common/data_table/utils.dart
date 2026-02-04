import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';

import '../../../components/app_text_field/app_textfield.dart';
import 'ui_drop_down_menu.dart';
import 'data_table.dart';

enum RowActionType { modify, delete, view, execute, inlineEdit, add, renew }

class RowAction {
  final RowActionType type;
  final Color? color;
  final IconData? icon;
  final String? hoverMessage;

  const RowAction(this.type, {this.color, this.icon, this.hoverMessage});
}

typedef StatusColorMap = Map<String, Color>;

List<Map<String, dynamic>> filteredData(List<Map<String, dynamic>> data, String searchText, Map<String, Set<String>> columnSelections) {
  return data.where((row) {
    // final matchesGlobalSearch = searchText.isEmpty ||
    //     row.values.any((value) =>
    //         value.toString().toLowerCase().contains(searchText.toLowerCase()));

    ///Search data only according to columnSelections (ColumnList)
    final matchesGlobalSearch = searchText.isEmpty || columnSelections.keys.any((col) => row[col]?.toString().toLowerCase().contains(searchText.toLowerCase()) ?? false);

    final matchesColumnFilters = columnSelections.entries.every((entry) {
      final col = entry.key;
      final selectedValues = entry.value;

      if (selectedValues.isEmpty) return true;

      return selectedValues.contains(row[col]?.toString() ?? '');
    });

    return matchesGlobalSearch && matchesColumnFilters;
  }).toList();
}

List<Map<String, dynamic>> sortedData(List<Map<String, dynamic>> dataA, String searchText, Map<String, Set<String>> columnSelections, String? sortColumn, bool isAscending) {
  if (sortColumn == null || dataA.isEmpty) {
    return filteredData(dataA, searchText, columnSelections);
  }

  final filtered = filteredData(dataA, searchText, columnSelections);
  if (filtered.isEmpty) return filtered;

  // 3. Pre-compute sort keys to avoid repeated calculations
  final sortKeys = List<SortKey>.generate(filtered.length, (index) {
    final row = filtered[index];
    final value = row[sortColumn];
    return SortKey.fromValue(value);
  });

  final indices = List<int>.generate(filtered.length, (i) => i);

  indices.sort((a, b) {
    final comparison = sortKeys[a].compareTo(sortKeys[b]);
    return isAscending ? comparison : -comparison;
  });

  return indices.map((i) => filtered[i]).toList();
}

class SortKey implements Comparable<SortKey> {
  final int _type; // 0=null, 1=number, 2=date, 3=string
  final dynamic _value;
  final String _stringValue;

  SortKey._(this._type, this._value, this._stringValue);

  factory SortKey.fromValue(dynamic value) {
    if (value == null) {
      return SortKey._(0, null, '');
    }

    final num? number = _tryParseNumberFast(value);
    if (number != null) {
      return SortKey._(1, number, '');
    }

    final DateTime? date = _tryParseDateTimeFast(value);
    if (date != null) {
      return SortKey._(2, date.microsecondsSinceEpoch, '');
    }

    final str = value.toString().toLowerCase(); // Convert to lowercase here
    return SortKey._(3, null, str);
  }

  @override
  int compareTo(SortKey other) {
    if (_type == 0 || other._type == 0) {
      if (_type == other._type) return 0;
      return _type == 0 ? -1 : 1;
    }

    if (_type == other._type) {
      switch (_type) {
        case 1: // number
          return (_value as num).compareTo(other._value as num);
        case 2: // date
          return (_value as int).compareTo(other._value as int);
        case 3: // string
          return _naturalSortCompareFast(_stringValue, other._stringValue);
        default:
          return 0;
      }
    }

    return _naturalSortCompareFast(_stringValue, other._stringValue);
  }

  static num? _tryParseNumberFast(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      // Optimized for common number formats
      if (value.isEmpty) return null;
      final firstChar = value.codeUnitAt(0);
      if ((firstChar >= 48 && firstChar <= 57) || firstChar == 45 || firstChar == 43) {
        return num.tryParse(value);
      }
    }
    return null;
  }

  static DateTime? _tryParseDateTimeFast(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      // Try ISO format first (most common)
      try {
        return DateTime.parse(value);
      } catch (_) {
        // Fall back to basic pattern matching for common formats
        if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value)) {
          final parts = value.split('-');
          if (parts.length == 3) {
            try {
              return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } catch (_) {}
          }
        }
      }
    }
    return null;
  }

  static int _naturalSortCompareFast(String a, String b) {
    // Strings are already lowercase at this point
    final aLen = a.length;
    final bLen = b.length;
    int aIndex = 0, bIndex = 0;

    while (aIndex < aLen && bIndex < bLen) {
      final aChar = a.codeUnitAt(aIndex);
      final bChar = b.codeUnitAt(bIndex);

      if (_isDigit(aChar) && _isDigit(bChar)) {
        int aNum = 0, bNum = 0;

        while (aIndex < aLen && _isDigit(a.codeUnitAt(aIndex))) {
          aNum = aNum * 10 + (a.codeUnitAt(aIndex) - 48);
          aIndex++;
        }

        while (bIndex < bLen && _isDigit(b.codeUnitAt(bIndex))) {
          bNum = bNum * 10 + (b.codeUnitAt(bIndex) - 48);
          bIndex++;
        }

        final numCompare = aNum.compareTo(bNum);
        if (numCompare != 0) return numCompare;
      } else {
        if (aChar != bChar) return aChar - bChar;
        aIndex++;
        bIndex++;
      }
    }

    return aLen - bLen;
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;
}

// List<DataRow> groupedDataRows(
//   BuildContext context,
//   final StatusColorMap? customStatusColors,
//   List<Map<String, dynamic>> paginatedData,
//   Set<RowAction>? rowActions,
//   List<String>? groupByColumns,
//   List<String> columnOrder,
//   void Function(Map<String, dynamic>)? onView,
//   void Function(Map<String, dynamic>)? onExecute,
//   void Function(Map<String, dynamic>)? onRenew,
//   void Function(Map<String, dynamic>)? onModify,
//   void Function(Map<String, dynamic>)? onInlineEdit,
//   void Function(Map<String, dynamic>)? onDelete,
//   List<String> visibleColumns,
//   Color? cellTextColor,
//   List<bool> rowSelections,
//   void Function(int index, bool?)? onRowSelected,
//   int currentPage,
//   int rowsPerPage,
//   Map<int, EditableRow> editableRows,
//   void Function(int index)? onStartEdit,
//   void Function(int index)? onSaveEdit,
//   void Function(int index)? onCancelEdit,
//   Map<String, List<UIDropdownMenuItem<String>>> dropdownOptions,
//   bool isMultiSelectMode,
//   Set<int>? selectedIndices,
//   Set<int> expandedRows,
//   void Function(int index, bool isExpanded)? onExpandChanged,
// ) {
//   final data = paginatedData;
//   bool showActions = rowActions != null && rowActions.isNotEmpty;
//   bool hasCheckboxes = onRowSelected != null;
//   final pageOffset = currentPage * rowsPerPage;

//   final isMobile = MediaQuery.of(context).size.width < 450;

//   Widget buildImageCell(dynamic value) {
//     if (value == null || value.toString().isEmpty) {
//       return Container(
//         color: Colors.grey.shade300,
//         child: Icon(Icons.image_not_supported, size: 28),
//       );
//     }

//     final img = value.toString();

//     if (img.startsWith("http")) {
//       return Image.network(
//         img,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 28),
//       );
//     }

//     try {
//       return Image.memory(
//         base64Decode(img),
//         fit: BoxFit.cover,
//       );
//     } catch (_) {
//       return Icon(Icons.broken_image, size: 28);
//     }
//   }

//   Widget _buildEditableField({
//     required BuildContext context,
//     required FieldType fieldType,
//     required TextEditingController controller,
//     required String originalValue,
//     required bool isEditing,
//     required String columnName,
//   }) {
//     switch (fieldType) {
//       case FieldType.textField:
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 5),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: 200),
//             child: textField(
//               controller: controller,
//               hintText: originalValue,
//             ),
//           ),
//         );
//       // case FieldType.dropDown:
//       //   // Get options for this specific column
//       //   final options = dropdownOptions[columnName] ??
//       //       [UIDropdownMenuItem(value: originalValue, label: originalValue)];

//       //   return Padding(
//       //     padding: const EdgeInsets.symmetric(vertical: 5),
//       //     child: ConstrainedBox(
//       //       constraints: BoxConstraints(maxWidth: 200),
//       //       child: UIDropdownMenu<String>(
//       //         dropdownController: controller,
//       //         dropdownMenuEntries: options,
//       //         onSelected: (value) {
//       //           if (value != null) {
//       //             controller.text = value;
//       //           }
//       //         },
//       //         enableSearch: true,
//       //         enabled: isEditing,
//       //       ),
//       //     ),
//       //   );
//       // case FieldType.calendarDropDown:
//       //   return Padding(
//       //     padding: const EdgeInsets.symmetric(vertical: 5),
//       //     child: ConstrainedBox(
//       //       constraints: BoxConstraints(maxWidth: 200),
//       //       child: UIDateDropdownMenu(
//       //         dropdownController: controller,
//       //         // initialDate: DateTime.tryParse(originalValue),
//       //         onDateSelected: (date) {
//       //           if (date != null) {
//       //             controller.text = date.toIso8601String();
//       //           }
//       //         },
//       //         enabled: isEditing,
//       //       ),
//       //     ),
//       //   );
//       // case FieldType.none:
//       default:
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 5),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: 200),
//             child: SelectableText(
//               originalValue,
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 color: cellTextColor,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         );
//     }
//   }}

class UICard extends StatelessWidget {
  final Widget? child;
  final Color? cardColor;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double? curve;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final Color? shadowColor;
  final Function()? onTap;

  const UICard({
    Key? key,
    this.curve,
    this.child,
    this.cardColor,
    this.onTap,
    this.elevation,
    this.borderColor,
    this.shadowColor,
    this.borderRadius,
    this.padding = const EdgeInsets.all(8.0),
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation ?? 5,
        color: cardColor, // ?? Theme.of(context).colorScheme.surface,
        shadowColor: shadowColor ?? Colors.blueGrey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(curve ?? 8.0),
          side: BorderSide(color: borderColor ?? appColors.gray),
        ),
        // side: borderColor != null
        //     ? BorderSide(color: borderColor!)
        //     : BorderSide.none),
        margin: margin,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class UIOutlineButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget? child;
  final String? text;
  final Size? size;
  final EdgeInsets? padding;
  final bool loading;
  final Color? background;
  final Color? foreground;
  final Widget? icon;
  final TextStyle? textStyle;
  final double? borderRadius;
  const UIOutlineButton({
    Key? key,
    this.onPressed,
    this.child,
    this.text,
    this.size,
    this.padding,
    this.loading = false,
    this.background,
    this.icon,
    this.textStyle,
    this.foreground,
    this.borderRadius,
  }) : assert(child != null || text != null),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        padding: padding,
        backgroundColor: background ?? AppColors().white,
        fixedSize: size,
        shape: RoundedRectangleBorder(
          side: background != null ? BorderSide.none : BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
          borderRadius: BorderRadius.circular(borderRadius ?? (Theme.of(context).inputDecorationTheme.border as OutlineInputBorder?)?.borderRadius.topLeft.x ?? 8.0),
        ),
      ).copyWith(backgroundColor: WidgetStateProperty.all(background ?? Theme.of(context).colorScheme.surfaceContainerLow)),
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2)),
            )
          : child ??
                (icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon!,
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(child: Text(text!.toUpperCase(), style: textStyle != null ? Theme.of(context).textTheme.bodyLarge?.merge(textStyle) : null)),
                          ),
                          const SizedBox(width: 4),
                        ],
                      )
                    : Text(text!.toUpperCase(), style: textStyle != null ? Theme.of(context).textTheme.bodyLarge?.merge(textStyle) : null)),
    );
  }
}

List<DataRow> groupedDataRows(
  BuildContext context,
  final StatusColorMap? customStatusColors,
  List<Map<String, dynamic>> paginatedData,
  Set<RowAction>? rowActions,
  List<String>? groupByColumns,
  List<String> columnOrder,
  void Function(Map<String, dynamic>)? onView,
  void Function(Map<String, dynamic>)? onExecute,
  void Function(Map<String, dynamic>)? onRenew,
  void Function(Map<String, dynamic>)? onModify,
  void Function(Map<String, dynamic>)? onInlineEdit,
  void Function(Map<String, dynamic>)? onDelete,
  List<String> visibleColumns,
  Color? cellTextColor,
  List<bool> rowSelections,
  void Function(int index, bool?)? onRowSelected,
  int currentPage,
  int rowsPerPage,
  Map<int, EditableRow> editableRows,
  void Function(int index)? onStartEdit,
  void Function(int index)? onSaveEdit,
  void Function(int index)? onCancelEdit,
  Map<String, List<UIDropdownMenuItem<String>>> dropdownOptions,
  bool isMultiSelectMode,
  Set<int>? selectedIndices,
  Set<int> expandedRows,
  void Function(int index, bool isExpanded)? onExpandChanged,
) {
  final data = paginatedData;
  bool showActions = rowActions != null && rowActions.isNotEmpty;
  bool hasCheckboxes = onRowSelected != null;
  final pageOffset = currentPage * rowsPerPage;

  final isMobile = MediaQuery.of(context).size.width < 450;

  Widget buildImageCell(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return Container(color: Colors.grey.shade300, child: Icon(Icons.image_not_supported, size: 28));
    }

    final img = value.toString();

    if (img.startsWith("http")) {
      return Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 28));
    }

    try {
      return Image.memory(base64Decode(img), fit: BoxFit.cover);
    } catch (_) {
      return Icon(Icons.broken_image, size: 28);
    }
  }

  Widget _buildEditableField({
    required BuildContext context,
    required FieldType fieldType,
    required TextEditingController controller,
    required String originalValue,
    required bool isEditing,
    required String columnName,
  }) {
    switch (fieldType) {
      case FieldType.textField:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: textField(controller: controller, hintText: originalValue),
          ),
        );
      case FieldType.dropDown:
        // Get options for this specific column
        final options = dropdownOptions[columnName] ?? [UIDropdownMenuItem(value: originalValue, label: originalValue)];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: UIDropdownMenu<String>(
              dropdownController: controller,
              dropdownMenuEntries: options,
              onSelected: (value) {
                if (value != null) {
                  controller.text = value;
                }
              },
              enableSearch: true,
              enabled: isEditing,
            ),
          ),
        );
      // case FieldType.calendarDropDown:
      //   return Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 5),
      //     child: ConstrainedBox(
      //       constraints: BoxConstraints(maxWidth: 200),
      //       child: UIDateDropdownMenu(
      //         dropdownController: controller,
      //         // initialDate: DateTime.tryParse(originalValue),
      //         onDateSelected: (date) {
      //           if (date != null) {
      //             controller.text = date.toIso8601String();
      //           }
      //         },
      //         enabled: isEditing,
      //       ),
      //     ),
      //   );
      case FieldType.none:
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: SelectableText(
              originalValue,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cellTextColor, fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        );
    }
  }

  DataCell _buildEditActionCells(int index, void Function(int)? onSave, void Function(int)? onCancel) {
    return DataCell(
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.green, size: 18),
            onPressed: () => onSave?.call(index),
            tooltip: 'Save',
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red, size: 18),
            onPressed: () => onCancel?.call(index),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  int _calculateMaxLines(String text) {
    final length = text.length;
    if (length > 100) return 5;
    if (length > 80) return 4;
    if (length > 60) return 3;
    if (length > 35) return 2;
    return 1;
  }

  // Non-grouped data implementation
  if (groupByColumns == null || groupByColumns.isEmpty) {
    final rows = <DataRow>[];

    for (final entry in data.asMap().entries) {
      final pageRelativeIndex = entry.key;
      final absoluteIndex = pageOffset + pageRelativeIndex;
      final row = entry.value;
      final isSelected = isMultiSelectMode
          ? selectedIndices?.contains(absoluteIndex) ?? false
          : rowSelections.length > absoluteIndex
          ? rowSelections[absoluteIndex]
          : false;
      final isEditing = editableRows.containsKey(absoluteIndex);
      final editableRow = editableRows[absoluteIndex];
      final color = absoluteIndex % 2 == 0 ? Colors.white : const Color(0xFFFAFAFB); // Alternate row colors #
      final isExpanded = expandedRows.contains(absoluteIndex);

      // Calculate total columns
      final totalColumns =
          1 + // expand column
          (hasCheckboxes ? 1 : 0) + // checkbox
          visibleColumns.length + // data columns
          (showActions ? 1 : 0); // actions

      // Build main row cells
      final mainCells = <DataCell>[
        if (isMobile) DataCell(IconButton(icon: Icon(isExpanded ? Icons.expand_more : Icons.chevron_right), onPressed: () => onExpandChanged?.call(absoluteIndex, !isExpanded))),
      ];

      if (hasCheckboxes) {
        mainCells.add(DataCell(Checkbox(value: isSelected, onChanged: (selected) => onRowSelected.call(pageRelativeIndex, selected))));
      }

      mainCells.addAll(
        columnOrder.where((col) => visibleColumns.contains(col)).map((col) {
          if (col.toLowerCase() == "image" || col.toLowerCase() == "photo" || col.toLowerCase() == "profilepic") {
            final value = row[col];

            return DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: buildImageCell(value)),
                ),
              ),
            );
          }
          if (isEditing) {
            return DataCell(
              _buildEditableField(
                context: context,
                fieldType: editableRow?.fieldTypes[col] ?? FieldType.none,
                controller: editableRow!.controllers[col]!,
                originalValue: row[col]?.toString() ?? '',
                isEditing: true,
                columnName: col,
              ),
            );
          } else if (col.toLowerCase() == 'status') {
            final statusText = row[col]?.toString() ?? '';
            final isActive = statusText.toLowerCase() == 'active' || statusText.toLowerCase() == 'act' || statusText.toLowerCase() == 'enabled';

            return DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE0FFEA) // Light green background
                        : const Color(0xFFFFE5E6), // Light red background
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? const Color(0xFF06802B) // Dark green text
                          : const Color(0xFFCC0A0D), // Dark red text
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          } else {
            final isRulesColumn = col.toLowerCase() == 'rules';

            if (isRulesColumn) {
              return DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250, maxHeight: 120),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        formatRules(row[col]),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cellTextColor, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Check if this is a description column (for view more/less)
            final isDescriptionColumn = col.toLowerCase().contains('description') || col.toLowerCase().contains('desc');
            final cellValue = row[col]?.toString() ?? '';
            final isExpanded = expandedRows.contains(absoluteIndex);
            final shouldShowViewMore = isDescriptionColumn && cellValue.length > 50 && !isExpanded;

            return DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SelectableText(
                        shouldShowViewMore ? '${cellValue.substring(0, 50)}...' : cellValue,
                        maxLines: shouldShowViewMore ? 2 : _calculateMaxLines(cellValue),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cellTextColor ?? const Color(0xFF221340), // #221340, 0xFF1F2937
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (shouldShowViewMore)
                        InkWell(
                          onTap: () => onExpandChanged?.call(absoluteIndex, true),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'View more',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B46C1), fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                        ),
                      if (isDescriptionColumn && cellValue.length > 50 && isExpanded)
                        InkWell(
                          onTap: () => onExpandChanged?.call(absoluteIndex, false),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'View less',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B46C1), fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        }),
      );

      if (showActions) {
        mainCells.add(
          isEditing
              ? _buildEditActionCells(absoluteIndex, onSaveEdit, onCancelEdit)
              : buildActionCell(context, row, rowActions, onView, onExecute, onRenew, onModify, onDelete, () => onStartEdit?.call(absoluteIndex)),
        );
      }

      // Add main row
      rows.add(
        DataRow(selected: isSelected, onSelectChanged: hasCheckboxes ? (selected) => onRowSelected.call(pageRelativeIndex, selected) : null, color: WidgetStateProperty.all(color), cells: mainCells),
      );

      // Add expanded row if needed
      if (isMobile && isExpanded) {
        final expandedCells = <DataCell>[];

        // Expand column
        expandedCells.add(const DataCell(SizedBox.shrink()));
        //
        // // Checkbox column if exists
        // if (hasCheckboxes) {
        //   expandedCells.add(const DataCell(SizedBox.shrink()));
        // }

        // Main content cell (spanning all data columns)
        expandedCells.add(
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: visibleColumns.map((col) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText('$col :', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: SelectableText(
                              row[col]?.toString() ?? 'N/A',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                              maxLines: _calculateMaxLines(row[col]?.toString() ?? ''),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );

        // Empty cells for remaining columns
        while (expandedCells.length < totalColumns) {
          expandedCells.add(const DataCell(SizedBox.shrink()));
        }

        rows.add(DataRow(color: WidgetStateProperty.all(color.withOpacity(0.8)), cells: expandedCells));
      }
    }

    return rows;
  }

  // Grouped data implementation
  List<DataRow> rows = [];
  Map<String, List<Map<String, dynamic>>> grouped = {};
  int globalDataIndex = pageOffset;

  // Group the data
  for (var row in data) {
    final key = groupByColumns.map((col) => row[col]?.toString() ?? 'Unknown').join(' | ');
    grouped.putIfAbsent(key, () => []).add(row);
  }

  // Build rows for each group
  grouped.forEach((group, groupRows) {
    // Add group header row
    rows.add(
      DataRow(
        color: WidgetStateProperty.all(Theme.of(context).colorScheme.surface),
        cells: [
          if (isMobile) DataCell(const SizedBox.shrink()),
          if (hasCheckboxes) const DataCell(SizedBox.shrink()),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200),
                child: SelectableText(
                  group,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cellTextColor, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ),
          ...List.generate((visibleColumns.length - 1) + (showActions ? 1 : 0), (_) => const DataCell(SizedBox.shrink())),
        ],
      ),
    );

    // Add rows for each item in the group
    for (var row in groupRows) {
      final originalIndex = data.indexOf(row);
      final absoluteIndex = pageOffset + originalIndex;
      final isSelected = rowSelections.length > absoluteIndex ? rowSelections[absoluteIndex] : false;
      final isEditing = editableRows.containsKey(absoluteIndex);
      final editableRow = editableRows[absoluteIndex];
      final color = absoluteIndex % 2 == 0 ? Colors.white : const Color(0xFFFAFAFB); // Alternate row colors
      final isExpanded = expandedRows.contains(absoluteIndex);

      rows.add(
        DataRow(
          selected: isSelected,
          onSelectChanged: hasCheckboxes ? (selected) => onRowSelected.call(originalIndex, selected) : null,
          color: WidgetStateProperty.all(color),
          cells: [
            if (isMobile) DataCell(IconButton(icon: Icon(isExpanded ? Icons.expand_more : Icons.chevron_right), onPressed: () => onExpandChanged?.call(absoluteIndex, !isExpanded))),
            if (hasCheckboxes) DataCell(Checkbox(value: isSelected, onChanged: (selected) => onRowSelected.call(originalIndex, selected))),
            ...visibleColumns.map((col) {
              if (col.toLowerCase() == "image" || col.toLowerCase() == "photo" || col.toLowerCase() == "profilepic") {
                final value = row[col];
                return DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: buildImageCell(value)),
                    ),
                  ),
                );
              }
              if (isEditing) {
                return DataCell(
                  _buildEditableField(
                    context: context,
                    fieldType: editableRow?.fieldTypes[col] ?? FieldType.none,
                    controller: editableRow!.controllers[col]!,
                    originalValue: row[col]?.toString() ?? '',
                    isEditing: true,
                    columnName: col,
                  ),
                );
              } else if (col.toLowerCase() == 'status') {
                return DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: SelectableText(
                        '${row[col]}',
                        maxLines: _calculateMaxLines(row[col]?.toString() ?? ''),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: getChipColor(row[col] ?? "", customColors: customStatusColors),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Regular cells (non-description, non-status, non-rules)
                return DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: SelectableText(
                        '${row[col]}',
                        maxLines: _calculateMaxLines(row[col]?.toString() ?? ''),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cellTextColor ?? const Color(0xFF221340), // 221340, 0xFF1F2937
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
            if (showActions)
              isEditing
                  ? _buildEditActionCells(absoluteIndex, onSaveEdit, onCancelEdit)
                  : buildActionCell(context, row, rowActions, onView, onExecute, onRenew, onModify, onDelete, () => onStartEdit?.call(absoluteIndex)),
          ],
        ),
      );

      if (isMobile && isExpanded) {
        final totalColumns =
            1 + // expand column
            (hasCheckboxes ? 1 : 0) + // checkbox
            visibleColumns.length + // data columns
            (showActions ? 1 : 0); // actions

        rows.add(
          DataRow(
            color: WidgetStateProperty.all(color.withOpacity(0.8)),
            cells: List<DataCell>.generate(totalColumns, (index) {
              // Expand column (always first)
              if (index == 0) return DataCell(SizedBox.shrink());

              // Checkbox column (if exists)
              // if (hasCheckboxes && index == 1) return DataCell(SizedBox.shrink());

              // Actions column (if exists, always last)
              if (showActions && index == totalColumns - 1) return DataCell(SizedBox.shrink());

              // Main content (span all data columns)
              final contentColumnIndex = hasCheckboxes ? 2 : 1;
              if (index == contentColumnIndex) {
                return DataCell(
                  Container(
                    constraints: BoxConstraints(minHeight: 50),
                    padding: EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: visibleColumns.map((col) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText('$col:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 250),
                                  child: SelectableText(row[col]?.toString() ?? 'N/A', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }

              // Empty cells for other data columns
              return DataCell(SizedBox.shrink());
            }),
          ),
        );
      }

      globalDataIndex++;
    }
  });

  return rows;
}

String formatRules(dynamic rules) {
  if (rules == null) return '';
  if (rules is! List) return rules.toString();

  return rules
      .asMap()
      .entries
      .map((e) {
        final index = e.key + 1;
        final r = e.value;

        String ruleName = '';
        String userMessageAr = '';

        if (r is Map) {
          ruleName = r['ruleName']?.toString() ?? '';
          userMessageAr = r['userMessageAr']?.toString() ?? '';
        } else {
          final d = r as dynamic;
          ruleName = d.ruleName?.toString() ?? '';
          userMessageAr = d.userMessageAr?.toString() ?? '';
        }

        if (ruleName.isEmpty && userMessageAr.isEmpty) {
          return "$index. ${r.toString()}";
        } else if (userMessageAr.isEmpty) {
          return "$index. $ruleName";
        } else if (ruleName.isEmpty) {
          return "$index. $userMessageAr";
        } else {
          return "$index. $ruleName ($userMessageAr)";
        }
      })
      .join("\n");
}

DataCell buildActionCell(
  BuildContext context,
  Map<String, dynamic> row,
  Set<RowAction>? rowActions,
  void Function(Map<String, dynamic>)? onView,
  void Function(Map<String, dynamic>)? onExecute,
  void Function(Map<String, dynamic>)? onModify,
  void Function(Map<String, dynamic>)? onRenew,
  void Function(Map<String, dynamic>)? onDelete,
  void Function()? onInlineEdit,
) {
  return DataCell(
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rowActions!.any((e) => e.type == RowActionType.view))
          InkWell(
            onTap: () => onView?.call(row),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: rowActions.where((e) => e.type == RowActionType.view).first.icon != null
                  ? Tooltip(
                      message: rowActions.where((e) => e.type == RowActionType.view).first.hoverMessage ?? 'View',
                      child: Icon(
                        rowActions.where((e) => e.type == RowActionType.view).first.icon,
                        size: 18,
                        color: rowActions.where((e) => e.type == RowActionType.view).first.color ?? const Color(0xFF6B7280),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/svg/icons/eye_view_curved.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(rowActions.where((e) => e.type == RowActionType.view).first.color ?? const Color(0xFF6B7280), BlendMode.srcIn),
                    ),
            ),
          ),
        if (rowActions.any((e) => e.type == RowActionType.modify))
          InkWell(
            onTap: () => onModify?.call(row),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: rowActions.where((e) => e.type == RowActionType.modify).first.icon != null
                  ? Tooltip(
                      message: rowActions.where((e) => e.type == RowActionType.modify).first.hoverMessage ?? 'Modify',
                      child: Icon(
                        rowActions.where((e) => e.type == RowActionType.modify).first.icon,
                        size: 18,
                        color: rowActions.where((e) => e.type == RowActionType.modify).first.color ?? const Color(0xFF6B7280),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/svg/icons/edit_curved.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(rowActions.where((e) => e.type == RowActionType.modify).first.color ?? const Color(0xFF6B7280), BlendMode.srcIn),
                    ),
            ),
          ),
        if (rowActions.any((e) => e.type == RowActionType.inlineEdit))
          InkWell(
            onTap: onInlineEdit,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Tooltip(
                message: rowActions.where((e) => e.type == RowActionType.inlineEdit).first.hoverMessage ?? 'Inline Edit',
                child: Icon(
                  rowActions.where((e) => e.type == RowActionType.inlineEdit).first.icon ?? Icons.edit_note,
                  size: 18,
                  color: rowActions.where((e) => e.type == RowActionType.inlineEdit).first.color ?? const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        if (rowActions.any((e) => e.type == RowActionType.execute))
          InkWell(
            onTap: () => onExecute?.call(row),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Tooltip(
                message: rowActions.where((e) => e.type == RowActionType.execute).first.hoverMessage ?? 'Execute',
                child: Icon(
                  rowActions.where((e) => e.type == RowActionType.execute).first.icon ?? Icons.launch,
                  size: 18,
                  color: rowActions.where((e) => e.type == RowActionType.execute).first.color ?? const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        if (rowActions.any((e) => e.type == RowActionType.delete))
          InkWell(
            onTap: () => onDelete?.call(row),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: rowActions.where((e) => e.type == RowActionType.delete).first.icon != null
                  ? Tooltip(
                      message: rowActions.where((e) => e.type == RowActionType.delete).first.hoverMessage ?? 'Delete',
                      child: Icon(
                        rowActions.where((e) => e.type == RowActionType.delete).first.icon,
                        size: 18,
                        color: rowActions.where((e) => e.type == RowActionType.delete).first.color ?? const Color(0xFFEF4444),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/svg/icons/trash_curved.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(rowActions.where((e) => e.type == RowActionType.delete).first.color ?? const Color(0xFFEF4444), BlendMode.srcIn),
                    ),
            ),
          ),
        if (rowActions.any((e) => e.type == RowActionType.renew))
          InkWell(
            onTap: () => onRenew?.call(row),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Tooltip(
                message: rowActions.where((e) => e.type == RowActionType.renew).first.hoverMessage ?? 'Renew',
                child: Icon(
                  rowActions.where((e) => e.type == RowActionType.renew).first.icon ?? Icons.autorenew_outlined,
                  size: 18,
                  color: rowActions.where((e) => e.type == RowActionType.renew).first.color ?? const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Color getChipColor(String status, {Map<String, Color>? customColors}) {
  final cleanedStatus = status.toLowerCase().replaceAll(' ', '');

  if (customColors != null && customColors.containsKey(cleanedStatus)) {
    return customColors[cleanedStatus]!;
  }

  switch (cleanedStatus) {
    case 'active':
    case 'completed':
    case 'success':
      return Colors.green;
    case 'inactive':
      return Colors.grey;
    case 'pending':
    case 'inprogress':
    case 'in_progress':
      return Colors.orange;
    case 'failed':
    case 'rejected':
      return Colors.red;
    default:
      return Colors.blue.shade300;
  }
}
