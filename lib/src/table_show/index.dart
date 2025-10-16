import 'package:flutter/material.dart';

class TableShow extends StatelessWidget {
  final List<Map<String, dynamic>> columns; // [{label, prop, width?, fixed?}]
  final List<Map<String, dynamic>> data; // data list
  // Default row/header height; can be overridden per row via rowHeightBuilder
  final double rowHeight;
  final double headerHeight;
  final double defaultColumnWidth;
  final Color borderColor;
  final BorderRadiusGeometry borderRadius;
  // New: customizable text styles
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  // New: per-row height control
  final double Function(int rowIndex, Map<String, dynamic> row)? rowHeightBuilder;

  const TableShow({
    super.key,
    required this.columns,
    required this.data,
    this.rowHeight = 44,
    this.headerHeight = 44,
    this.defaultColumnWidth = 140,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.headerTextStyle,
    this.cellTextStyle,
    this.rowHeightBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fixedColumns = columns.where((c) => (c['fixed'] == true)).toList();
    final List<Map<String, dynamic>> scrollColumns = columns.where((c) => (c['fixed'] != true)).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: borderRadius,
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fixedColumns.isNotEmpty) _buildFixedColumns(fixedColumns),
          Expanded(child: _buildScrollableTable(scrollColumns)),
        ],
      ),
    );
  }

  Widget _buildFixedColumns(List<Map<String, dynamic>> fixedCols) {
    // Build column width map for Table
    final Map<int, TableColumnWidth> columnWidths = {};
    for (int i = 0; i < fixedCols.length; i++) {
      final double width = _getWidth(fixedCols[i]);
      columnWidths[i] = FixedColumnWidth(width);
    }

    final TextStyle headerStyle = headerTextStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
    final TextStyle cellStyle = cellTextStyle ?? const TextStyle(fontSize: 14);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: _extractRadius(borderRadius)?.topLeft ?? Radius.zero, bottomLeft: _extractRadius(borderRadius)?.bottomLeft ?? Radius.zero),
      ),
      child: Table(
        columnWidths: columnWidths,
        border: TableBorder(
          right: BorderSide(color: borderColor, width: 1),
          horizontalInside: BorderSide(color: borderColor, width: 1),
          verticalInside: BorderSide(color: borderColor, width: 1),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          TableRow(
            children: fixedCols
                .map(
                  (c) => SizedBox(
                    height: headerHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text((c['label'] ?? '').toString(), style: headerStyle, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Data rows
          ...List.generate(data.length, (rowIndex) {
            final row = data[rowIndex];
            final double rh = rowHeightBuilder?.call(rowIndex, row) ?? rowHeight;
            return TableRow(
              children: fixedCols
                  .map(
                    (c) => SizedBox(
                      height: rh,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildCellText(row[c['prop']], maxLines: 1, style: cellStyle),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableTable(List<Map<String, dynamic>> scrollCols) {
    if (scrollCols.isEmpty) {
      // If no scrollable columns, still render an empty area to align heights
      return const SizedBox.shrink();
    }

    // Build column width map for Table
    final Map<int, TableColumnWidth> columnWidths = {};
    for (int i = 0; i < scrollCols.length; i++) {
      final double width = _getWidth(scrollCols[i]);
      columnWidths[i] = FixedColumnWidth(width);
    }

    final TextStyle headerStyle = headerTextStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
    final TextStyle cellStyle = cellTextStyle ?? const TextStyle(fontSize: 14);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: columnWidths,
        border: TableBorder(
          horizontalInside: BorderSide(color: borderColor, width: 1),
          verticalInside: BorderSide(color: borderColor, width: 1),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          TableRow(
            children: scrollCols
                .map(
                  (c) => SizedBox(
                    height: headerHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text((c['label'] ?? '').toString(), style: headerStyle, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Data rows
          ...List.generate(data.length, (rowIndex) {
            final row = data[rowIndex];
            final double rh = rowHeightBuilder?.call(rowIndex, row) ?? rowHeight;
            return TableRow(
              children: scrollCols
                  .map(
                    (c) => SizedBox(
                      height: rh,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildCellText(row[c['prop']], maxLines: 1, style: cellStyle),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  double _getWidth(Map<String, dynamic> col) {
    final dynamic w = col['width'];
    if (w is num) return w.toDouble();
    return defaultColumnWidth;
  }

  BorderRadius? _extractRadius(BorderRadiusGeometry radius) {
    if (radius is BorderRadius) return radius;
    return null;
  }

  Widget _buildCellText(dynamic value, {int? maxLines, TextStyle? style}) {
    return Text(value == null ? '' : value.toString(), maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
  }
}
