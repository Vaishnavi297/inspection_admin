import 'package:flutter/material.dart';
import 'package:inspection_station/components/app_text_style/app_text_style.dart';
import '../../extensions/context_extension.dart';

/*class UIDropdownMenu1<T> extends StatelessWidget {
  const UIDropdownMenu1(
      {super.key,
      this.width = 320,
      this.expandedInsets,
      this.enableFilter = false,
      this.enableSearch = false,
      this.requestFocusOnTap = false,
      required this.onSelected,
      required this.dropdownMenuEntries,
      this.trailingIcon = const Icon(Icons.keyboard_arrow_down),
      this.selectedTrailingIcon = const Icon(Icons.keyboard_arrow_up),
      this.errorText,
      required this.enabled,
        this.dropdownController,
        this.borderColor,
      this.hintText});

  final double? width;

  /// if null, the width matches with menu max width, else expands to
  /// parent width
  final EdgeInsets? expandedInsets;
  final bool enableFilter;
  final bool enableSearch;
  final bool requestFocusOnTap;
  final ValueChanged<T?>? onSelected;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final Icon trailingIcon;
  final Icon selectedTrailingIcon;
  final String? errorText;
  final bool enabled;
  final String? hintText;
  final TextEditingController? dropdownController;
  final Color? borderColor;


  @override
  Widget build(BuildContext context) {
    return DropdownMenu1<T>(
      width: width,
      controller: dropdownController,
      enableFilter: enableFilter,
      enableSearch: enableSearch,
      textStyle: const UiTextNew.b1Medium("").getTextStyle(context),
      requestFocusOnTap: requestFocusOnTap,
      onSelected: onSelected,
      dropdownMenuEntries: dropdownMenuEntries,
      trailingIcon: trailingIcon,
      selectedTrailingIcon: selectedTrailingIcon,
      errorText: errorText,
      enabled: enabled,
      hintText: hintText,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: context.colorScheme.surfaceBright,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? context.colorScheme.tertiary),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      expandedInsets: expandedInsets,
    );
  }
}*/

class UIDropdownMenuItem<T> {
  final String label;
  final T value;
  bool isSelected;
  final Function(bool)? onSelectionChanged;

  UIDropdownMenuItem({
    required this.label,
    required this.value,
    this.isSelected = false,
    this.onSelectionChanged,
  });
}

Widget defaultIconBuilder(bool isOpen) {
  return Icon(
    isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down_sharp,
    color: Color(0xFF64748B),
    size: 25,
  );
}

class UIDropdownMenu<T> extends StatefulWidget {
  const UIDropdownMenu({
    super.key,
    this.width = 320,
    this.height = 300,
    this.expandedInsets,
    this.enableFilter = false,
    this.enableSearch = false,
    this.requestFocusOnTap = false,
    required this.onSelected,
    required this.dropdownMenuEntries,
    this.trailingIconBuilder = defaultIconBuilder,
    this.errorText,
    required this.enabled,
    this.dropdownController,
    this.borderColor,
    this.hintText,
    this.trailingIcon = const Icon(Icons.keyboard_arrow_down),
    this.selectedTrailingIcon = const Icon(Icons.keyboard_arrow_up),
    this.hintTextStyle,
    this.backgroundColor,
    this.isCheckBox = false,
    this.validation,
    this.idExtractor,
    this.initialSelectedIds,
    this.autovalidateMode,
  });

  final double? width;
  final double? height;
  final EdgeInsets? expandedInsets;
  final bool enableFilter;
  final bool enableSearch;
  final bool requestFocusOnTap;
  final ValueChanged<T?>? onSelected;
  final List<UIDropdownMenuItem<T>> dropdownMenuEntries;
  final String? errorText;
  final bool enabled;
  final TextEditingController? dropdownController;
  final Color? borderColor;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final Color? backgroundColor;
  final Icon trailingIcon;
  final Icon selectedTrailingIcon;
  final Widget Function(bool isOpen)? trailingIconBuilder;
  final bool isCheckBox;
  final String? Function(String?)? validation;
  final int Function(T)? idExtractor;
  final List<int>? initialSelectedIds;
  final AutovalidateMode? autovalidateMode;

  @override
  State<UIDropdownMenu<T>> createState() => _UIDropdownMenuState<T>();
}

class _UIDropdownMenuState<T> extends State<UIDropdownMenu<T>>
    with WidgetsBindingObserver {
  late List<UIDropdownMenuItem<T>> _filteredItems;
  late final TextEditingController _effectiveController;
  bool _isInternalController = false;
  Set<T> _selectedValues = {};
  final MenuController menuController = MenuController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.dropdownMenuEntries);
    _isInternalController = widget.dropdownController == null;
    _effectiveController = widget.dropdownController ?? TextEditingController();

    if (widget.isCheckBox) {
      _effectiveController.addListener(_handleControllerChange);
      _initializeSelections();
      // Initialize with IDs if provided
      if (widget.initialSelectedIds != null && widget.idExtractor != null) {
        _initializeWithIds(widget.initialSelectedIds!);
      }
    } else {
      _effectiveController.addListener(_onSearchChanged);
    }
    WidgetsBinding.instance.addObserver(this);
  }

  void _closeMenuAndMaybeClear(MenuController controller) {
    controller.close();
    Future.delayed(Duration(milliseconds: 200), () {
      bool isSelectedList = false;
      for (UIDropdownMenuItem item in List.from(widget.dropdownMenuEntries)) {
        if (item.label == _effectiveController.text) {
          isSelectedList = true;
        }
      }
      if (widget.enableSearch && !isSelectedList && _selectedValues.isEmpty) {
        setState(() {
          _effectiveController.clear();
          widget.onSelected?.call(null);
          _filteredItems = List.from(widget.dropdownMenuEntries);
        });
      }
    });
  }

  void _initializeSelections() {
    if (_effectiveController.text.isNotEmpty) {
      _selectedValues = _parseControllerText();
      _updateItemsSelection();
    }
  }

  void _initializeWithIds(List<int> selectedIds) {
    if (widget.idExtractor == null || !widget.isCheckBox) return;
    
    _selectedValues.clear();
    
    // Reset all items to unselected first
    for (var item in widget.dropdownMenuEntries) {
      item.isSelected = false;
    }
    
    // If selectedIds is empty, don't select anything
    if (selectedIds.isEmpty) {
      _effectiveController.clear();
      return;
    }
    
    // Mark selected items based on IDs
    for (var item in widget.dropdownMenuEntries) {
      final itemId = widget.idExtractor!(item.value);
      if (selectedIds.contains(itemId)) {
        _selectedValues.add(item.value);
        item.isSelected = true;
      }
    }
    
    _syncControllerWithSelections();
  }

  Set<T> _parseControllerText() {
    return widget.dropdownMenuEntries
        .where((item) => _effectiveController.text
            .split(',')
            .any((part) => part.trim() == item.label))
        .map((item) => item.value)
        .toSet();
  }

  void _updateItemsSelection() {
    for (var item in widget.dropdownMenuEntries) {
      item.isSelected = _selectedValues.contains(item.value);
    }
  }

  @override
  void didChangeMetrics() {
    if (menuController.isOpen) {
      menuController.close();
    }
  }

  @override
  void didUpdateWidget(UIDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCheckBox) {
      _updateItemsSelection();

      // Check if initialSelectedIds changed
      if (!_areIntListsEqual(
          widget.initialSelectedIds ?? [], 
          oldWidget.initialSelectedIds ?? [])) {
        if (widget.initialSelectedIds != null && widget.idExtractor != null) {
          _initializeWithIds(widget.initialSelectedIds!);
        }
      }

      // Check if dropdownMenuEntries changed
      if (!_areListsEqual(
          widget.dropdownMenuEntries, oldWidget.dropdownMenuEntries)) {
        _syncControllerWithSelections();
      }
    }
  }

  bool _areListsEqual(
      List<UIDropdownMenuItem<T>> a, List<UIDropdownMenuItem<T>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value || a[i].label != b[i].label) return false;
    }
    return true;
  }

  bool _areIntListsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChange);
    if (!widget.isCheckBox) {
      _effectiveController.removeListener(_onSearchChanged);
    }
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _handleControllerChange() {
    if (widget.isCheckBox) {
      if (_effectiveController.text.isEmpty) {
        setState(() {
          _selectedValues.clear();
          _updateItemsSelection();
        });
      } else {
        setState(() {
          _selectedValues = _parseControllerText();
          _updateItemsSelection();
        });
      }
    }
  }

  void _syncControllerWithSelections() {
    if (widget.isCheckBox) {
      final selectedLabels = widget.dropdownMenuEntries
          .where((item) => item.isSelected)
          .map((item) => item.label)
          .toList();
      
      _effectiveController.text = selectedLabels.join(', ');
    }
  }

  /// Public method to set selected values by IDs
  void setSelectedByIds(List<int> selectedIds) {
    if (widget.idExtractor == null || !widget.isCheckBox) return;
    
    setState(() {
      _selectedValues.clear();
      
      // Reset all items to unselected first
      for (var item in widget.dropdownMenuEntries) {
        item.isSelected = false;
      }
      
      // If selectedIds is empty, clear everything
      if (selectedIds.isEmpty) {
        _effectiveController.clear();
        return;
      }
      
      // Mark selected items based on IDs
      for (var item in widget.dropdownMenuEntries) {
        final itemId = widget.idExtractor!(item.value);
        if (selectedIds.contains(itemId)) {
          _selectedValues.add(item.value);
          item.isSelected = true;
        }
      }
      
      // Update controller with comma-separated string
      _effectiveController.text = _selectedValues
          .map((value) => widget.dropdownMenuEntries
              .firstWhere((item) => item.value == value)
              .label)
          .join(', ');
    });
  }

  /// Public method to get currently selected IDs
  List<int> getSelectedIds() {
    if (widget.idExtractor == null || !widget.isCheckBox) return [];
    
    return _selectedValues
        .map((value) => widget.idExtractor!(value))
        .toList();
  }

  /// Public method to get currently selected values as comma-separated string
  String getSelectedValuesAsString() {
    if (!widget.isCheckBox) return '';
    
    return _selectedValues
        .map((value) => widget.dropdownMenuEntries
            .firstWhere((item) => item.value == value)
            .label)
        .join(', ');
  }

  /// Public method to clear all selections
  void clearSelections() {
    if (!widget.isCheckBox) return;
    
    setState(() {
      _selectedValues.clear();
      for (var item in widget.dropdownMenuEntries) {
        item.isSelected = false;
      }
      _effectiveController.clear();
    });
  }

  void _onSearchChanged() {
    final query = _effectiveController.text.toLowerCase().replaceAll(' ', '');
    setState(() {
      _filteredItems = widget.dropdownMenuEntries.where((item) {
        final normalizedLabel = item.label.toLowerCase().replaceAll(' ', '');
        return normalizedLabel.contains(query);
      }).toList();
    });
  }

  // void _updateSelectedText() {
  //   if (widget.isCheckBox) {
  //     _effectiveController.text = _selectedItems.map((item) => item.label).join(', ');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    _effectiveController.addListener(() {});

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   setState(() {}); // triggers rebuild after layout to get RenderBox size
    // });

    return SizedBox(
      width: widget.width,
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor:
              WidgetStateProperty.all(Colors.white),
        ),
        onClose: () {
          _closeMenuAndMaybeClear(menuController);
        },
        controller: menuController,
        menuChildren: _buildMenuChildren(menuController),
        builder: (context, controller, child) =>
            _buildAnchor(context, controller),
      ),
    );
  }

  List<Widget> _buildMenuChildren(MenuController menuController) {
    // Calculate current anchor width dynamically
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final double anchorWidth = renderBox?.size.width ?? widget.width ?? 320;

    return [
      if (widget.enableSearch)
        Container(
          width: anchorWidth, // ✅ enforce header width
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text("Please select",
                      style: primaryTextStyle(
                       
                        color: Colors.grey,
                        // overflow: TextOverflow.ellipsis,
                      )),
                ),
              ],
            ),
          ),
        ),
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: anchorWidth,
          maxWidth: anchorWidth,
          maxHeight: widget.height ?? 300,
        ),
        child: widget.enableSearch && !widget.isCheckBox
            ? _buildFilteredSearch(menuController)
            : _buildMenuItems(menuController),
      )
    ];
  }

  // List<Widget> _buildMenuChildren(MenuController menuController) {
  //   return [
  //     if (widget.enableSearch)
  //       Container(
  //         color: Colors.grey[200],
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //           child: Row(
  //             children: [
  //               Text("Please select",
  //                   style: UiTextNew.b1Regular(
  //                     "",
  //                     color: Colors.grey,
  //                   ).getTextStyle(context)),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ConstrainedBox(
  //       constraints: BoxConstraints(
  //         minWidth: widget.width ?? 320,
  //         maxWidth: widget.width ?? 320,
  //         maxHeight: widget.height ?? 300,
  //       ),
  //       child: widget.enableSearch && !widget.isCheckBox
  //           ? _buildFilteredSearch(menuController)
  //           : _buildMenuItems(menuController),
  //     )
  //   ];
  // }

  Widget _buildFilteredSearch(MenuController menuController) {
    return SingleChildScrollView(
      child: _filteredItems.isEmpty
          ? _buildNoRecordsFound()
          : _buildMenuItems(menuController),
    );
  }

  Widget _buildNoRecordsFound() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "No Records Found",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMenuItems(MenuController menuController) {
    return SingleChildScrollView(
      child: Column(
        children: _filteredItems
            .map((item) => widget.isCheckBox
                ? _buildCheckboxMenuItem(item, menuController)
                : _buildMenuItem(item, menuController))
            .toList(),
      ),
    );
  }

  Widget _buildMenuItem(
      UIDropdownMenuItem<T> item, MenuController menuController) {
    bool isSelected = _effectiveController.text == item.label;
    return MenuItemButton(
      onPressed: () {
        setState(() {
          _effectiveController.text = item.label;
        });
        widget.onSelected?.call(item.value);
        menuController.close();
      },
      child: SizedBox(
        width: widget.width,
        child: Text(
          item.label,
          style: isSelected
              ? boldTextStyle(color: Colors.blue)
              : primaryTextStyle(),
        ),
      ),
    );
  }

  Widget _buildCheckboxMenuItem(
      UIDropdownMenuItem<T> item, MenuController menuController) {
    return MenuItemButton(
      // onPressed: () {
      //   setState(() {
      //     item.isSelected = !item.isSelected;
      //     if (item.isSelected) {
      //       _selectedValues.add(item.value);
      //     } else {
      //       _selectedValues.remove(item.value);
      //     }
      //     _syncControllerWithSelections();
      //   });
      //   widget.onSelected?.call(item.value);
      // },
      child: SizedBox(
        width: widget.width,
        child: InkWell(
          onTap: () {
            setState(() {
              item.isSelected = !item.isSelected;
              if (item.isSelected) {
                _selectedValues.add(item.value);
              } else {
                _selectedValues.remove(item.value);
              }
              _syncControllerWithSelections();
            });
            widget.onSelected?.call(item.value);
          },
          child: Row(
            children: [
              Checkbox(
                value: item.isSelected,
                onChanged: (value) {
                  setState(() {
                    item.isSelected = value ?? false;
                    if (item.isSelected) {
                      _selectedValues.add(item.value);
                    } else {
                      _selectedValues.remove(item.value);
                    }
                    _syncControllerWithSelections();
                  });
                  widget.onSelected?.call(item.value);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  // style: UiTextNew.b1Medium("").getTextStyle(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnchor(BuildContext context, MenuController controller) {
    return TextFormField(
      controller: _effectiveController,
      readOnly: widget.isCheckBox,
      enabled: widget.enabled,
      validator: widget.validation,
      onChanged: widget.isCheckBox
          ? null
          : (value) {
              if (value.isEmpty) {
                setState(() {
                  widget.onSelected?.call(null);
                  _filteredItems = List.from(widget.dropdownMenuEntries);
                });
              } else {
                _onSearchChanged();
              }
              if (!controller.isOpen) controller.open();
            },
      onTap: () {
        if (widget.enabled) {
          setState(() {
            _filteredItems = List.from(widget.dropdownMenuEntries);
          });
          if (!controller.isOpen) {
            controller.open();
          }
        }
      },
      style: context.textTheme.labelMedium
          ?.copyWith(color: context.theme.highlightColor),
      autovalidateMode: widget.autovalidateMode,
      decoration: InputDecoration(
        filled: true,
        fillColor: null, //Theme.of(context).colorScheme.surfaceBright,
        // suffixIcon: controller.isOpen
        //     ? widget.selectedTrailingIcon
        //     : widget.trailingIcon,
        suffixIcon: widget.trailingIconBuilder?.call(controller.isOpen),
        border: OutlineInputBorder(
          borderSide: BorderSide(
              color:
              widget.borderColor ?? Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(15.0),
        ),
        // enabledBorder: OutlineInputBorder(
        //   borderSide: BorderSide(
        //       color:
        //       widget.borderColor ?? Theme.of(context).colorScheme.tertiary),
        //   borderRadius: BorderRadius.circular(4.0),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: BorderSide(
        //       color:
        //       widget.borderColor ?? Theme.of(context).colorScheme.tertiary),
        //   borderRadius: BorderRadius.circular(4.0),
        // ),
        hintText: widget.hintText,
        hintStyle: widget.hintTextStyle ??
            TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF898989),
            ),
        errorText: widget.errorText,
      ),
    );
  }
}
