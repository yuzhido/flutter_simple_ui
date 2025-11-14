import 'package:flutter/material.dart';

class TableShow extends StatefulWidget {
  final List<Map<String, dynamic>> columns;
  final List<Map<String, dynamic>> data;
  final double rowHeight;
  final double headerHeight;
  final double defaultColumnWidth;
  final Color borderColor;
  final BorderRadiusGeometry borderRadius;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final double Function(int rowIndex, Map<String, dynamic> row)? rowHeightBuilder;
  final int? total;
  final int pageSize;
  final int currentPage;
  final ValueChanged<int>? onPageChange;

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
    this.total,
    this.pageSize = 10,
    this.currentPage = 1,
    this.onPageChange,
  });

  @override
  State<TableShow> createState() => _TableShowState();
}

class _TableShowState extends State<TableShow> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
  }

  @override
  void didUpdateWidget(covariant TableShow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPageChange != null) {
      _currentPage = widget.currentPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fixedColumns = widget.columns.where((c) => (c['fixed'] == true)).toList();
    final List<Map<String, dynamic>> scrollColumns = widget.columns.where((c) => (c['fixed'] != true)).toList();

    final bool internalPaging = widget.total != null && widget.onPageChange == null;
    final bool showPagination = widget.total != null && (widget.total! > widget.pageSize);
    final List<Map<String, dynamic>> visibleData = internalPaging ? _sliceData(widget.data, _currentPage, widget.pageSize) : widget.data;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor, width: 1),
        borderRadius: widget.borderRadius,
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fixedColumns.isNotEmpty) _buildFixedColumns(fixedColumns, visibleData),
              Expanded(child: _buildScrollableTable(scrollColumns, visibleData)),
            ],
          ),
          if (showPagination) _buildPaginationBar(internalPaging),
        ],
      ),
    );
  }

  Widget _buildFixedColumns(List<Map<String, dynamic>> fixedCols, List<Map<String, dynamic>> visibleData) {
    // Build column width map for Table
    final Map<int, TableColumnWidth> columnWidths = {};
    for (int i = 0; i < fixedCols.length; i++) {
      final double width = _getWidth(fixedCols[i]);
      columnWidths[i] = FixedColumnWidth(width);
    }

    final TextStyle headerStyle = widget.headerTextStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
    final TextStyle cellStyle = widget.cellTextStyle ?? const TextStyle(fontSize: 14);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: _extractRadius(widget.borderRadius)?.topLeft ?? Radius.zero, bottomLeft: _extractRadius(widget.borderRadius)?.bottomLeft ?? Radius.zero),
      ),
      child: Table(
        columnWidths: columnWidths,
        border: TableBorder(
          right: BorderSide(color: widget.borderColor, width: 1),
          horizontalInside: BorderSide(color: widget.borderColor, width: 1),
          verticalInside: BorderSide(color: widget.borderColor, width: 1),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          TableRow(
            children: fixedCols
                .map(
                  (c) => SizedBox(
                    height: widget.headerHeight,
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
          ...List.generate(visibleData.length, (rowIndex) {
            final row = visibleData[rowIndex];
            final double rh = widget.rowHeightBuilder?.call(rowIndex, row) ?? widget.rowHeight;
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

  Widget _buildScrollableTable(List<Map<String, dynamic>> scrollCols, List<Map<String, dynamic>> visibleData) {
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

    final TextStyle headerStyle = widget.headerTextStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
    final TextStyle cellStyle = widget.cellTextStyle ?? const TextStyle(fontSize: 14);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: columnWidths,
        border: TableBorder(
          horizontalInside: BorderSide(color: widget.borderColor, width: 1),
          verticalInside: BorderSide(color: widget.borderColor, width: 1),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          TableRow(
            children: scrollCols
                .map(
                  (c) => SizedBox(
                    height: widget.headerHeight,
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
          ...List.generate(visibleData.length, (rowIndex) {
            final row = visibleData[rowIndex];
            final double rh = widget.rowHeightBuilder?.call(rowIndex, row) ?? widget.rowHeight;
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
    return widget.defaultColumnWidth;
  }

  BorderRadius? _extractRadius(BorderRadiusGeometry radius) {
    if (radius is BorderRadius) return radius;
    return null;
  }

  Widget _buildCellText(dynamic value, {int? maxLines, TextStyle? style}) {
    return Text(value == null ? '' : value.toString(), maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
  }

  Widget _buildPaginationBar(bool internalPaging) {
    final int t = widget.total ?? 0;
    final int ps = widget.pageSize;
    final int cp = internalPaging ? _currentPage : widget.currentPage;
    final int totalPages = ((t + ps - 1) ~/ ps);
    final bool hasPrev = cp > 1;
    final bool hasNext = cp < totalPages;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: widget.borderColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text('共 $t 条'),
          const SizedBox(width: 12),
          Text('第 $cp/$totalPages 页'),
          const Spacer(),
          TextButton(
            onPressed: hasPrev
                ? () {
                    if (internalPaging) {
                      setState(() {
                        _currentPage = cp - 1;
                      });
                    } else {
                      widget.onPageChange?.call(cp - 1);
                    }
                  }
                : null,
            child: const Text('上一页'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: hasNext
                ? () {
                    if (internalPaging) {
                      setState(() {
                        _currentPage = cp + 1;
                      });
                    } else {
                      widget.onPageChange?.call(cp + 1);
                    }
                  }
                : null,
            child: const Text('下一页'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _sliceData(List<Map<String, dynamic>> source, int page, int size) {
    final int start = (page - 1) * size;
    final int end = start + size;
    if (start >= source.length) return const [];
    final int realEnd = end > source.length ? source.length : end;
    return source.sublist(start, realEnd);
  }
}
