import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inspection_station/components/app_text_field/app_textfield.dart';
import 'package:inspection_station/components/app_text_style/app_text_style.dart';
import 'package:inspection_station/utils/common/drop_down/utils.dart';
import 'package:inspection_station/utils/constants/app_dimension.dart';

import '../../constants/app_colors.dart';
import '../../extensions/context_extension.dart';
import 'UIDropdownMenu.dart';

class DataTableWidget extends StatefulWidget {
  final List<String> columns;
  final List<Map<String, dynamic>> data;
  final Color? backgroundCardColor;
  final Set<RowAction>? rowActions;
  final void Function(Map<String, dynamic> row)? onView;
  final void Function(Map<String, dynamic> row)? onExecute;
  final void Function(Map<String, dynamic> row)? onModify;
  final void Function(Map<String, dynamic> row)? onRenew;
  final void Function(Map<String, dynamic> row)? onDelete;
  final void Function(Map<String, dynamic> row)? onInlineEdit;
  final VoidCallback? uploadExcelData;
  final bool? isShowLabelIcon;
  final Set<String>? filterableColumns;
  final VoidCallback? onAddLabel;
  final Color? headerColor;
  final Color? headerTextColor;
  final Color? cellColor;
  final Color? cellTextColor;
  final Color? widgetBackgroundColor;
  final StatusColorMap? customStatusColors;
  final Color? headerColumnColor;
  final Color? topHeaderColor;
  final bool? isExportBox;
  final bool? isGroupBox;
  final String? titleDatatableText;
  final String? subTitleDatatableText;
  final double? maxRowHeight;
  final String? actionColumnName;
  final void Function(Map<String, dynamic>? selectedRow)? onCheckBoxRowSelected;
  final void Function(Set<Map<String, dynamic>> selectedRows)? onMultiCheckBoxRowSelected;
  final DataTableController? controller;
  final Map<String, FieldType> columnFieldTypes;
  final Map<String, List<UIDropdownMenuItem<String>>> dropdownOptions;
  final String? groupFilterColumn;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.data,
    this.filterableColumns,
    this.columnFieldTypes = const {},
    this.dropdownOptions = const {},
    this.backgroundCardColor,
    this.rowActions,
    this.onView,
    this.onExecute,
    this.onModify,
    this.onInlineEdit,
    this.onDelete,
    this.onRenew,
    this.onAddLabel,
    this.headerColor,
    this.headerTextColor,
    this.cellColor,
    this.cellTextColor,
    this.widgetBackgroundColor,
    this.customStatusColors,
    this.headerColumnColor,
    this.topHeaderColor,
    this.uploadExcelData,
    this.isShowLabelIcon = true,
    this.isExportBox = false,
    this.isGroupBox = false,
    this.titleDatatableText,
    this.subTitleDatatableText,
    this.maxRowHeight,
    this.actionColumnName,
    this.onCheckBoxRowSelected,
    this.controller,
    this.onMultiCheckBoxRowSelected,
    this.groupFilterColumn,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

enum FieldType { none, textField, dropDown, calendarDropDown }

class DataTableController extends ChangeNotifier {
  VoidCallback? _resetPagination;
  VoidCallback? _clearSelectionCallback;
  VoidCallback? _clearSearchCallback;
  final Map<String, FieldType> _fieldTypes = {};
  VoidCallback? _updateFieldTypes;
  VoidCallback? _resetGroups;
  VoidCallback? _resetFilters;

  void _bindResetPagination(VoidCallback callback) {
    _resetPagination = callback;
  }

  void resetPagination() {
    _resetPagination?.call();
  }

  void setFieldType(String column, FieldType type) {
    _fieldTypes[column] = type;
    _updateFieldTypes?.call();
  }

  void setFieldTypes(Map<String, FieldType> fieldTypes) {
    _fieldTypes.clear();
    _fieldTypes.addAll(fieldTypes);
    _updateFieldTypes?.call();
  }

  void _bindUpdateFieldTypes(VoidCallback callback) {
    _updateFieldTypes = callback;
  }

  void _bind(VoidCallback callback) {
    _clearSelectionCallback = callback;
  }

  void clearSelections() {
    _clearSelectionCallback?.call();
  }

  void _searchBind(VoidCallback callback) {
    _clearSearchCallback = callback;
  }

  void clearSearch() {
    _clearSearchCallback?.call();
  }

  void clearGroups() {
    _resetGroups?.call();
  }

  void _bindGroups(VoidCallback callback) {
    _resetGroups = callback;
  }

  void clearFilters() {
    _resetFilters?.call();
  }

  void bindFilter(VoidCallback callback) {
    _resetFilters = callback;
  }
}

class EditableRow {
  final Map<String, dynamic> originalData;
  final Map<String, TextEditingController> controllers;
  final Map<String, FieldType> fieldTypes;
  bool isEditing;

  EditableRow({required this.originalData, required this.fieldTypes, this.isEditing = false})
    : controllers = {for (var entry in originalData.entries) entry.key: TextEditingController(text: entry.value?.toString() ?? '')};

  Map<String, dynamic> get editedData {
    return {for (var entry in controllers.entries) entry.key: entry.value.text};
  }

  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
  }
}

class _DataTableWidgetState extends State<DataTableWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Set<int> _expandedRows = {};

  int _currentPage = 0;
  int _rowsPerPage = 10;
  String _searchText = '';
  String? _sortColumn;
  bool _isAscending = true;
  Map<String, Set<String>> _columnSelections = {};
  late List<String> _visibleColumns;
  late List<String> _columnOrder;
  int totalItems = 0;

  List<String>? groupByColumns = [];
  Set<String> _tempSelectedColumns = {};
  bool _showFilterOptions = false; // Hide filter options by default

  List<Map<String, dynamic>> get _paginatedData {
    final start = _currentPage * _rowsPerPage;
    return sortedData(widget.data, _searchText, _columnSelections, _sortColumn, _isAscending).skip(start).take(_rowsPerPage).toList();
  }

  int get _totalPages => (sortedData(widget.data, _searchText, _columnSelections, _sortColumn, _isAscending).length / _rowsPerPage).ceil().clamp(1, double.infinity).toInt();

  int get totalDataSearchCount => sortedData(widget.data, _searchText, _columnSelections, _sortColumn, _isAscending).length;

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }
    });
  }

  List<bool> _rowSelections = [];

  final Map<int, EditableRow> _editableRows = {};
  final Map<String, FieldType> _columnFieldTypes = {};

  @override
  void initState() {
    super.initState();
    _initializeSelections();
    _visibleColumns = List.from(widget.columns);
    totalItems = widget.data.length;

    _columnOrder = [...widget.columns];
    for (final col in widget.columns) {
      _columnSelections[col] = <String>{};
      _columnFieldTypes[col] = widget.columnFieldTypes[col] ?? FieldType.none;
    }
    if (widget.groupFilterColumn != null) {
      groupByColumns = [widget.groupFilterColumn!];
      _tempSelectedColumns = {widget.groupFilterColumn!};
    }

    widget.controller?._bind(() {
      setState(() {
        _rowSelections = List<bool>.filled(widget.data.length, false);
        _selectedIndices.clear();
      });
    });

    widget.controller?._searchBind(() {
      setState(() {
        _searchController.clear();
        _searchText = "";
      });
    });

    widget.controller?._bindUpdateFieldTypes(() {
      setState(() {
        _columnFieldTypes.addAll(widget.controller!._fieldTypes);
      });
    });

    widget.controller?._bindResetPagination(() {
      setState(() {
        _currentPage = 0;
      });
    });

    widget.controller?._bindGroups(() {
      setState(() {
        if (widget.groupFilterColumn != null) {
          groupByColumns = [widget.groupFilterColumn!];
          _tempSelectedColumns = {widget.groupFilterColumn!};
        } else {
          groupByColumns = [];
          _tempSelectedColumns.clear();
        }
        _currentPage = 0;
      });
    });
  }

  @override
  void didUpdateWidget(DataTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      _initializeSelections();
      _currentPage = 0;
    }

    if (oldWidget.groupFilterColumn != widget.groupFilterColumn) {
      if (widget.groupFilterColumn != null) {
        groupByColumns = [widget.groupFilterColumn!];
        _tempSelectedColumns = {widget.groupFilterColumn!};
      } else {
        groupByColumns = [];
        _tempSelectedColumns.clear();
      }
    }
  }

  void _initializeSelections() {
    _rowSelections = List<bool>.filled(widget.data.length, false);
  }

  @override
  void dispose() {
    for (var row in _editableRows.values) {
      row.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _startEditing(int index) {
    final rowData = widget.data[index];
    setState(() {
      _editableRows[index] = EditableRow(originalData: rowData, fieldTypes: _columnFieldTypes, isEditing: true);
    });
  }

  void _saveEditing(int index) {
    final editableRow = _editableRows[index];
    if (editableRow != null) {
      widget.onInlineEdit?.call(editableRow.editedData);
      setState(() {
        _editableRows.remove(index);
      });
    }
  }

  void _cancelEditing(int index) {
    setState(() {
      _editableRows.remove(index);
    });
  }

  Set<int> _selectedIndices = {};
  bool get _isMultiSelectMode => widget.onMultiCheckBoxRowSelected != null;

  void _handleSingleSelect(int pageRelativeIndex, bool? selected) {
    setState(() {
      final absoluteIndex = (_currentPage * _rowsPerPage) + pageRelativeIndex;

      if (selected == true) {
        _rowSelections = List<bool>.filled(widget.data.length, false);
        _rowSelections[absoluteIndex] = true;
        widget.onCheckBoxRowSelected?.call(widget.data[absoluteIndex]);
      } else {
        _rowSelections[absoluteIndex] = false;
        widget.onCheckBoxRowSelected?.call(null);
      }
    });
  }

  void _handleMultiSelect(int pageRelativeIndex, bool? selected) {
    setState(() {
      final absoluteIndex = (_currentPage * _rowsPerPage) + pageRelativeIndex;

      if (selected == true) {
        _selectedIndices.add(absoluteIndex);
      } else {
        _selectedIndices.remove(absoluteIndex);
      }

      _rowSelections = List<bool>.generate(widget.data.length, (i) => _selectedIndices.contains(i));

      widget.onMultiCheckBoxRowSelected?.call(_selectedIndices.map((i) => widget.data[i]).toSet());
    });
  }

  void _toggleSelectAll(bool? selected) {
    if (selected == true) {
      setState(() {
        _selectedIndices = Set<int>.from(Iterable<int>.generate(widget.data.length, (i) => i));
        _rowSelections = List<bool>.filled(widget.data.length, true);
        widget.onMultiCheckBoxRowSelected?.call(widget.data.toSet());
      });
    } else {
      _clearAllSelections();
    }
  }

  void _clearAllSelections() {
    log("clear_1");
    setState(() {
      _selectedIndices.clear();
      _rowSelections = List<bool>.filled(widget.data.length, false);

      if (_isMultiSelectMode) {
        widget.onMultiCheckBoxRowSelected?.call({});
      } else {
        widget.onCheckBoxRowSelected?.call(null);
      }
    });
  }

  Widget topBar() {
    double screenWidth = MediaQuery.of(context).size.width;
    Color blueLight50 = widget.widgetBackgroundColor ?? AppColors().surfaceColor;
    bool hasGroupDropdown = widget.isGroupBox == true && widget.groupFilterColumn == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: screenWidth > 700
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: screenWidth > 1024 ? 320 : 280, child: _buildModernSearchBox(blueLight50)),
                if (widget.uploadExcelData != null && widget.isShowLabelIcon == true) ...[const SizedBox(width: 12), addLabelBox(blueLight50)],
                const SizedBox(width: 12),
                columnBox(blueLight50),
                const SizedBox(width: 12),
                filterToggleBox(blueLight50),
                if (hasGroupDropdown) ...[const SizedBox(width: 12), SizedBox(width: screenWidth * 0.15, child: groupBox(blueLight50))],
                if (widget.uploadExcelData != null) ...[const SizedBox(width: 12), uploadBox(blueLight50)],
                if (widget.isExportBox == true) ...[const SizedBox(width: 12), exportBox(blueLight50)],
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildModernSearchBox(blueLight50),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (widget.uploadExcelData != null && widget.isShowLabelIcon == true) ...[addLabelBox(blueLight50), const SizedBox(width: 10)],
                    columnBox(blueLight50),
                    const SizedBox(width: 10),
                    filterToggleBox(blueLight50),
                    if (hasGroupDropdown) ...[const SizedBox(width: 10), Expanded(child: groupBox(blueLight50))],
                    if (widget.uploadExcelData != null) ...[const SizedBox(width: 10), uploadBox(blueLight50)],
                    if (widget.isExportBox == true) ...[const SizedBox(width: 10), exportBox(blueLight50)],
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildModernSearchBox(Color? backgroundColor) {
    return SizedBox(
      child: textField(
        // style: context.textTheme.labelSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors().surfaceColor),
        controller: _searchController,
        labelText: "",
        topPadding: 0,
        suffixIcon: _searchController.text.isNotEmpty
            ? InkWell(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchText = "";
                    widget.controller?.clearSearch();
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                child: Icon(Icons.clear, size: 18),
              )
            : Icon(Icons.search, size: 20),
        hintText: 'Search',

        onChanged: (value) {
          setState(() {
            _searchText = value!;
            _currentPage = 0;
          });
        },
      ),
    );
  }

  Widget footer() {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPerPageButton(screenWidth),
                const SizedBox(width: 16),
                // _buildDropDownPerPage(screenWidth),
              ],
            ),
            _buildDropDownPerPage(screenWidth),
            // _buildTextPerPage(screenWidth),
          ],
        ),
      );
    } else if (screenWidth < 480) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildPerPageButton(screenWidth), const SizedBox(width: 12), _buildDropDownPerPage(screenWidth)]),
            ),
            const SizedBox(height: 12),
            _buildTextPerPage(screenWidth),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildPerPageButton(screenWidth),
                  const SizedBox(width: 12),
                  // _buildDropDownPerPage(screenWidth),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // _buildTextPerPage(screenWidth),
            _buildDropDownPerPage(screenWidth),
          ],
        ),
      );
    }
  }

  SizedBox _buildTextPerPage(double screenWidth) {
    final totalCount = totalDataSearchCount;
    if (totalCount == 0) {
      return SizedBox(
        child: Text(
          "Showing 0 to 0 of 0 entries",
          style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors().surfaceColor.withOpacity(0.7)),
        ),
      );
    }

    final start = ((_rowsPerPage * _currentPage) + 1).clamp(1, totalCount);
    final end = (_rowsPerPage * (_currentPage + 1)).clamp(start, totalCount);

    return SizedBox(
      child: Text(
        "Showing $start to $end of $totalCount entries",
        style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors().surfaceColor.withOpacity(0.7)),
      ),
    );
  }

  _buildPerPageButton(double screenWidth) {
    // Handle edge case: no pages or empty data
    if (_totalPages <= 0) {
      return const SizedBox.shrink();
    }

    // Calculate visible page numbers
    List<int> visiblePages = [];
    int maxVisible = 5;

    // Ensure we don't have negative values in clamp
    int maxStartPage = (_totalPages - maxVisible).clamp(0, _totalPages);
    int startPage = (_currentPage - (maxVisible ~/ 2)).clamp(0, maxStartPage);
    int endPage = (startPage + maxVisible).clamp(0, _totalPages);

    // Ensure we have at least one page visible
    if (startPage >= endPage && _totalPages > 0) {
      startPage = 0;
      endPage = _totalPages.clamp(1, maxVisible);
    }

    for (int i = startPage; i < endPage; i++) {
      visiblePages.add(i);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button - circular with arrow icon only
        InkWell(
          onTap: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _currentPage > 0 ? Colors.white : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.chevron_left, size: 18, color: _currentPage > 0 ? const Color(0xFF1F2937) : const Color(0xFF1F2937).withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 8),
        // Page numbers - circular
        ...visiblePages.map((pageIndex) {
          final isActive = _currentPage == pageIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => setState(() => _currentPage = pageIndex),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF221340) // Dark purple for active page
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${pageIndex + 1}',
                  style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 14, color: isActive ? Colors.white : const Color(0xFF1F2937)),
                ),
              ),
            ),
          );
        }),
        // Ellipsis if needed
        if (endPage < _totalPages && _totalPages > maxVisible) ...[
          const SizedBox(width: 4),
          Text('...', style: context.theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: const Color(0xFF1F2937).withOpacity(0.5))),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => setState(() => _currentPage = _totalPages - 1),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Text(
                '$_totalPages',
                style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 14, color: const Color(0xFF1F2937)),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        // Next button - circular with arrow icon only
        InkWell(
          onTap: (_currentPage + 1) < _totalPages ? () => setState(() => _currentPage++) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (_currentPage + 1) < _totalPages ? Colors.white : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.chevron_right, size: 18, color: (_currentPage + 1) < _totalPages ? const Color(0xFF1F2937) : const Color(0xFF1F2937).withOpacity(0.3)),
          ),
        ),
      ],
    );
  }

  SizedBox _buildDropDownPerPage(double screenWidth) {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<int>(
        initialValue: _rowsPerPage,
        isDense: true,
        decoration: defaultInputDecoration(),
        icon: Icon(Icons.keyboard_arrow_down, size: 20),
        items: [5, 10, 20, 50]
            .map(
              (val) => DropdownMenuItem(
                value: val,
                child: Text('$val rows', style: primaryTextStyle(size: 14)),
              ),
            )
            .toList(),
        onChanged: (val) {
          setState(() {
            _rowsPerPage = val!;
            _currentPage = 0;
          });
        },
        style: primaryTextStyle(size: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int? sortColumnIndex;
    if (_sortColumn != null) {
      final filteredColumns = _columnOrder.where((col) => _visibleColumns.contains(col)).toList();
      sortColumnIndex = filteredColumns.indexOf(_sortColumn!);
      if (sortColumnIndex == -1) {
        sortColumnIndex = null;
        _sortColumn = null;
      }
    }

    if (_paginatedData.isEmpty && _currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }

    return Container(
      decoration: BoxDecoration(color: widget.backgroundCardColor ?? Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar(),
          const SizedBox(height: 0),
          Container(
            color: Colors.white,
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * (_visibleColumns.length < 6 ? 1.0 : 1.0)),
                  child: DataTable(
                    showCheckboxColumn: false,
                    dividerThickness: 0.02,
                    dataRowMaxHeight: widget.maxRowHeight ?? double.infinity,
                    columnSpacing: s.s0,
                    sortAscending: _isAscending,
                    sortColumnIndex: sortColumnIndex,
                    columns: [
                      if (MediaQuery.of(context).size.width < 450) const DataColumn(label: SizedBox.shrink()),
                      if (widget.onCheckBoxRowSelected != null || widget.onMultiCheckBoxRowSelected != null) ...{
                        DataColumn(
                          label: _isMultiSelectMode
                              ? Checkbox(
                                  tristate: true,
                                  value: _selectedIndices.length == widget.data.length
                                      ? true
                                      : _selectedIndices.isEmpty
                                      ? false
                                      : null,
                                  onChanged: _toggleSelectAll,
                                )
                              : const SizedBox.shrink(),
                        ),
                      },
                      ..._columnOrder.where((col) => _visibleColumns.contains(col)).map((col) {
                        int colIndex = _columnOrder.indexOf(col);
                        final uniqueValues = widget.data.map((e) => e[col]?.toString() ?? '').toSet().toList();
                        _columnSelections[col] ??= uniqueValues.toSet();
                        final isFilterable = widget.filterableColumns == null || widget.filterableColumns!.contains(col);
                        return DataColumn(
                          label: DragTarget<String>(
                            onWillAccept: (draggedCol) => draggedCol != col,
                            onAccept: (draggedCol) {
                              setState(() {
                                int fromIndex = _columnOrder.indexOf(draggedCol);
                                _columnOrder.removeAt(fromIndex);
                                _columnOrder.insert(colIndex, draggedCol);
                              });
                            },
                            builder: (context, candidateData, rejectedData) => LongPressDraggable<String>(
                              data: col,
                              feedback: Material(
                                elevation: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: widget.headerColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
                                  child: Text(
                                    col,
                                    style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0XFF221340)),
                                  ),
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _onSort(col),
                                child: Row(
                                  children: [
                                    Text(
                                      col,
                                      style: context.theme.textTheme.titleLarge?.copyWith(
                                        color: widget.headerColumnColor ?? const Color(0xFF6E6D74), // 6B7280
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 4),
                                    if (isFilterable && _showFilterOptions)
                                      _FilterDropdownWithImage(
                                        color: widget.widgetBackgroundColor ?? AppColors().white,
                                        column: col,
                                        options: uniqueValues,
                                        selections: _columnSelections[col]!,
                                        onChanged: (column, selected) {
                                          setState(() {
                                            _columnSelections[column] = selected;
                                            _currentPage = 0;
                                          });
                                        },
                                        optionTextStyle: context.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                        controller: widget.controller,
                                      ),
                                    if (_sortColumn == col) Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: const Color(0xFF6B7280)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      if (widget.rowActions != null && widget.rowActions!.isNotEmpty)
                        DataColumn(
                          label: Text(
                            widget.actionColumnName ?? 'Actions',
                            style: context.theme.textTheme.titleLarge?.copyWith(
                              color: widget.headerColumnColor ?? const Color(0xFF6E6D74), // #6E6D74, 0xFF6B7280
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                    border: const TableBorder(
                      bottom: BorderSide(color: Color(0xFFE7E7E8), width: 0.5),
                      horizontalInside: BorderSide(color: Color(0xFFE7E7E8), width: 0.5),
                    ),
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      return widget.headerColor ?? Colors.white;
                    }),
                    rows: groupedDataRows(
                      context,
                      widget.customStatusColors,
                      _paginatedData,
                      widget.rowActions,
                      groupByColumns,
                      _columnOrder,
                      widget.onView,
                      widget.onExecute,
                      widget.onModify,
                      widget.onRenew,
                      widget.onInlineEdit,
                      widget.onDelete,
                      _visibleColumns,
                      widget.cellTextColor,
                      _rowSelections,
                      _isMultiSelectMode ? _handleMultiSelect : (widget.onCheckBoxRowSelected == null ? null : _handleSingleSelect),
                      _currentPage,
                      _rowsPerPage,
                      _editableRows,
                      _startEditing,
                      _saveEditing,
                      _cancelEditing,
                      widget.dropdownOptions,
                      _isMultiSelectMode,
                      _isMultiSelectMode ? _selectedIndices : null,
                      _expandedRows,
                      (index, isExpanded) {
                        setState(() {
                          if (isExpanded) {
                            _expandedRows.add(index);
                          } else {
                            _expandedRows.remove(index);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_paginatedData.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No records found',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.titleLarge?.copyWith(color: widget.cellTextColor ?? const Color(0xFF6B7280), fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                ],
              ),
            ),
          footer(),
        ],
      ),
    );
  }

  //----- Helper Widgets ---------
  // searchBox(blueLight50) {
  //   return TextField(
  //     style: context.textTheme.labelSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
  //     controller: _searchController,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(Icons.search, color: AppColors().surfaceColor),
  //       suffixIcon: _searchController.text.isNotEmpty
  //           ? InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   _searchController.clear();
  //                   _searchText = "";
  //                   widget.controller?.clearSearch();
  //                   FocusScope.of(context).requestFocus(FocusNode());
  //                 });
  //               },
  //               child: const Icon(Icons.clear, color: Colors.grey),
  //             )
  //           : null,
  //       hintText: 'Search',
  //       hintStyle: context.textTheme.labelSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
  //       border: OutlineInputBorder(
  //         borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer, width: 2),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       isDense: true,
  //       filled: true,
  //       fillColor: blueLight50 ?? Colors.white,
  //     ),
  //     onChanged: (value) {
  //       setState(() {
  //         _searchText = value;
  //         _currentPage = 0;
  //       });
  //     },
  //   );
  // }

  /// Normal interactive Group By dropdown (used only when [groupFilterColumn] is null)
  Widget groupBox(Color? blueLight50) {
    return DropdownButtonFormField<String>(
      style: context.textTheme.labelMedium?.copyWith(color: blueLight50 ?? context.theme.highlightColor),
      value: null,
      isDense: true,
      isExpanded: true,
      hint: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            groupByColumns?.isEmpty ?? true
                ? 'Group By'
                : groupByColumns!.length == 1
                ? groupByColumns!.first
                : groupByColumns!.join(', '),
            style: groupByColumns?.isEmpty ?? true
                ? context.textTheme.labelSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)
                : context.textTheme.labelMedium?.copyWith(color: AppColors().surfaceColor),
          ),
        ),
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: blueLight50 ?? context.theme.highlightColor,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dropdownColor: blueLight50 ?? context.theme.highlightColor,
      items: [
        DropdownMenuItem<String>(
          enabled: false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (_tempSelectedColumns.isEmpty && groupByColumns != null && groupByColumns!.isNotEmpty) {
                _tempSelectedColumns = Set.from(groupByColumns!);
              }
              return Column(
                children: [
                  ...widget.columns.map((col) {
                    return CheckboxListTile(
                      title: Text(col, style: context.textTheme.labelMedium?.copyWith(color: AppColors().surfaceColor)),
                      value: _tempSelectedColumns.contains(col),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _tempSelectedColumns
                              ..clear()
                              ..add(col);
                          } else {
                            _tempSelectedColumns.remove(col);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  const Divider(height: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            log("cleared...group");
                            Navigator.pop(context);
                            setState(() {
                              _tempSelectedColumns.clear();
                            });
                            if (mounted) {
                              this.setState(() {
                                groupByColumns = null;
                              });
                            }
                          },
                          child: const Text('Clear'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (mounted) {
                              this.setState(() {
                                groupByColumns = _tempSelectedColumns.isNotEmpty ? _tempSelectedColumns.toList() : null;
                                _currentPage = 0;
                              });
                            }
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
      onChanged: (value) {},
      onTap: () {
        if (groupByColumns != null && groupByColumns!.isNotEmpty) {
          _tempSelectedColumns = Set.from(groupByColumns!);
        } else {
          _tempSelectedColumns.clear();
        }
      },
    );
  }

  Widget columnBox(Color cardColor) {
    return UICard(
      margin: EdgeInsets.zero,
      elevation: 1,
      padding: EdgeInsets.zero,
      cardColor: cardColor,
      borderColor: appColors.gray,
      child: InkWell(
        onTapDown: (details) {
          _showColumnPopupMenu(context, details.globalPosition, cardColor);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child:  Icon(Icons.view_column_outlined, size: 20, color: Color(0xFF6B7280))
            
          
        ),
      ),
    );
  }

  Widget filterToggleBox(Color cardColor) {
    return UICard(
      margin: EdgeInsets.zero,
      elevation: 1,
      padding: EdgeInsets.zero,
      cardColor: cardColor,
      borderColor: appColors.gray,
      child: InkWell(
        onTapDown: (details) {
          setState(() {
            _showFilterOptions = !_showFilterOptions;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(_showFilterOptions ? Icons.filter_list : Icons.filter_list_off, size: 20, color: _showFilterOptions ? Color(0xFF221340) : Color(0xFF6B7280)),
        ),
      ),
    );
  }

  void _showColumnPopupMenu(BuildContext context, Offset position, Color cardColor) {
    final tempVisibleColumns = Set<String>.from(_visibleColumns);

    showMenu(
      color: cardColor,
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.columns.map((col) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        children: [
                          Checkbox(
                            value: tempVisibleColumns.contains(col),
                            onChanged: (bool? value) {
                              setState(() {
                                value == true ? tempVisibleColumns.add(col) : tempVisibleColumns.remove(col);
                              });
                            },
                          ),
                          Expanded(child: Text(col, style: primaryTextStyle())),
                        ],
                      );
                    },
                  );
                }).toList(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _visibleColumns.clear();
                          _visibleColumns.addAll(widget.columns);
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _visibleColumns
                            ..clear()
                            ..addAll(tempVisibleColumns);
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  UIOutlineButton exportBox(blueLight50) {
    final exportCurved = "assets/images/import_curved.png";

    return UIOutlineButton(
      // onPressed: () => exportToCSV(widget.columns, sortedData(widget.data, _searchText, _columnSelections, _sortColumn, _isAscending)),
      borderRadius: 8.0,
      background: const Color(0xFF221340), // Dark purple background
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // onPressed: () => exportToCSV(widget.columns, sortedData(widget.data, _searchText, _columnSelections, _sortColumn, _isAscending)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(exportCurved, width: 20, height: 20, fit: BoxFit.contain, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Export',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget uploadBox(Color blueLight50) {
    final importCurved = "assets/images/export_curved.png";

    return UIOutlineButton(
      onPressed: widget.uploadExcelData,
      borderRadius: 8.0,
      background: const Color(0xFF221340), // Dark purple background
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(importCurved, width: 20, height: 20, fit: BoxFit.contain, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Upload',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget addLabelBox(Color blueLight50) {
    return UICard(
      margin: EdgeInsets.zero,
      elevation: 1,
      padding: EdgeInsets.zero,
      cardColor: blueLight50,
      borderColor: Theme.of(context).colorScheme.onPrimaryContainer,
      child: IconButton(icon: Icon(Icons.add), tooltip: 'Add Label', onPressed: widget.onAddLabel),
    );
  }
}

// Custom filter dropdown with filterModern image icon
class _FilterDropdownWithImage extends StatefulWidget {
  final String column;
  final Set<String> selections;
  final List<String> options;
  final void Function(String column, Set<String>) onChanged;
  final Color? color;
  final TextStyle? optionTextStyle;
  final DataTableController? controller;

  const _FilterDropdownWithImage({required this.column, required this.selections, required this.options, required this.onChanged, this.color, this.optionTextStyle, this.controller});

  @override
  State<_FilterDropdownWithImage> createState() => _FilterDropdownWithImageState();
}

class _FilterDropdownWithImageState extends State<_FilterDropdownWithImage> {
  late Set<String> selected;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected = {...widget.selections};

    widget.controller?.bindFilter(() {
      setState(() {
        selected.clear();
        _searchController.clear();
      });
      widget.onChanged(widget.column, selected);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: widget.color,
      icon:  Icon(Icons.filter_alt_outlined, size: 16),
        
      
      onCanceled: () {
        _searchController.clear();
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false,

          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clear & Select All buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setInnerState(() {
                            selected.clear();
                            _searchController.clear();
                          });
                          widget.onChanged(widget.column, selected);
                        },
                        child: const Text('Clear All'),
                      ),
                      TextButton(
                        onPressed: () {
                          setInnerState(() {
                            final filteredOptions = widget.options.where((option) => option.toLowerCase().contains(_searchController.text.toLowerCase())).toSet();
                            selected.addAll(filteredOptions);
                          });
                          widget.onChanged(widget.column, selected);
                        },
                        child: const Text('Select All'),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  // Search box
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      style: context.textTheme.labelSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: (Colors.black)),
                        hintText: 'Search',
                        hintStyle: context.textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) {
                        setInnerState(() {});
                      },
                    ),
                  ),
                  // Checkbox list
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: ListView(
                        controller: _scrollController,
                        shrinkWrap: true,
                        children: widget.options.where((option) => option.toLowerCase().contains(_searchController.text.toLowerCase())).map((option) {
                          return CheckboxListTile(
                            title: Text(option, style: widget.optionTextStyle),
                            value: selected.contains(option),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setInnerState(() {
                                if (val == true) {
                                  selected.add(option);
                                } else {
                                  selected.remove(option);
                                }
                              });
                              widget.onChanged(widget.column, selected);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
