import 'package:flutter/material.dart';
import 'decoration.dart';
import '../constants/app_colors.dart';
import '../../components/app_text_style/app_text_style.dart';
import 'responsive_widget.dart';

class ScrollableDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color backgroundColor;
  final double? minWidth;
  final double columnSpacing;
  final double horizontalMargin;
  final double dividerThickness;
  final double headingRowHeight;
  final TextStyle? headingTextStyle;
  final Color? headingRowColor;
  final bool expand;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;
  final bool topEdgesOnly;
  final bool showHorizontalScrollbar;
  final bool showVerticalScrollbar;

  const ScrollableDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.margin = const EdgeInsets.only(left: 16),
    this.borderRadius = 8,
    this.backgroundColor = Colors.white,
    this.minWidth,
    this.columnSpacing = 10,
    this.horizontalMargin = 16,
    this.dividerThickness = 0.5,
    this.headingRowHeight = 48,
    this.headingTextStyle,
    this.headingRowColor,
    this.expand = true,
    this.verticalController,
    this.horizontalController,
    this.topEdgesOnly = true,
    this.showHorizontalScrollbar = false,
    this.showVerticalScrollbar = true,
  });

  @override
  Widget build(BuildContext context) {
    final vCtrl = verticalController ?? ScrollController();
    final hCtrl = horizontalController ?? ScrollController();
    final BorderRadius border = topEdgesOnly ? BorderRadius.only(topLeft: Radius.circular(borderRadius), topRight: Radius.circular(borderRadius)) : BorderRadius.circular(borderRadius);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width considering margins and sidebar
        final screenWidth = MediaQuery.of(context).size.width;
        final sidebarWidth = ResponsiveWidget.isLargeScreen(context) ? 300 : 80;
        final marginValue = margin is EdgeInsets ? (margin as EdgeInsets).horizontal : 0;
        final availableWidth = screenWidth - sidebarWidth - marginValue - 32;

        final table = ClipRRect(
          borderRadius: border,
          child: Container(
            width: availableWidth,
            decoration: boxDecorationWithRoundedCorners(backgroundColor: backgroundColor, borderRadius: border),
            child: Scrollbar(
              thumbVisibility: showVerticalScrollbar,
              controller: vCtrl,
              child: SingleChildScrollView(
                controller: vCtrl,
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  thumbVisibility: showHorizontalScrollbar,
                  controller: hCtrl,
                  child: SingleChildScrollView(
                    controller: hCtrl,
                    scrollDirection: Axis.horizontal,
                    child: _SmartWidthTable(
                      minWidth: minWidth,
                      availableWidth: availableWidth,
                      columns: columns,
                      rows: rows,
                      headingRowColor: headingRowColor,
                      headingTextStyle: headingTextStyle,
                      headingRowHeight: headingRowHeight,
                      columnSpacing: columnSpacing,
                      horizontalMargin: horizontalMargin,
                      dividerThickness: dividerThickness,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        if (expand) return Expanded(child: table);
        return table;
      },
    );
  }
}

class _SmartWidthTable extends StatefulWidget {
  final double? minWidth;
  final double availableWidth;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Color? headingRowColor;
  final TextStyle? headingTextStyle;
  final double headingRowHeight;
  final double columnSpacing;
  final double horizontalMargin;
  final double dividerThickness;

  const _SmartWidthTable({
    this.minWidth,
    required this.availableWidth,
    required this.columns,
    required this.rows,
    this.headingRowColor,
    this.headingTextStyle,
    required this.headingRowHeight,
    required this.columnSpacing,
    required this.horizontalMargin,
    required this.dividerThickness,
  });

  @override
  State<_SmartWidthTable> createState() => _SmartWidthTableState();
}

class _SmartWidthTableState extends State<_SmartWidthTable> {
  double? _measuredWidth;
  final GlobalKey _measureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Measure table width after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureWidth();
    });
  }

  void _measureWidth() {
    final RenderBox? renderBox = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _measuredWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If minWidth is explicitly provided, use it
    if (widget.minWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: widget.minWidth!),
        child: _buildTable(),
      );
    }

    // When minWidth is null, measure table and decide:
    // - If measured width < availableWidth, use measured width (fit to content)
    // - If measured width >= availableWidth, use availableWidth (full width)
    if (_measuredWidth == null) {
      // First render: measure natural width, but cap at availableWidth to prevent overflow
      return IntrinsicWidth(
        key: _measureKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.availableWidth),
          child: _buildTable(),
        ),
      );
    }

    // After measurement: use appropriate width
    final targetWidth = _measuredWidth! < widget.availableWidth ? _measuredWidth! : widget.availableWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: targetWidth, maxWidth: targetWidth),
      child: _buildTable(),
    );
  }

  Widget _buildTable() {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(widget.headingRowColor ?? appColors.dataTableHeaderColor),
      headingTextStyle: widget.headingTextStyle ?? boldTextStyle(fontWeight: FontWeight.w600, size: 14),
      headingRowHeight: widget.headingRowHeight,
      columnSpacing: widget.columnSpacing,
      horizontalMargin: widget.horizontalMargin,
      dividerThickness: widget.dividerThickness,
      columns: widget.columns,
      rows: widget.rows,
    );
  }
}
