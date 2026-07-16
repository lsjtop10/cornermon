import 'package:flutter/material.dart';

class SortableDataTableColumn<T> {
  const SortableDataTableColumn({
    required this.label,
    required this.valueOf,
    required this.cellBuilder,
  });

  final String label;
  final Comparable<dynamic>? Function(T item) valueOf;
  final Widget Function(T item) cellBuilder;
}

/// 관리자 목록 화면의 정렬 헤더, 필터 바, 건수 표시를 통일한다.
class SortableDataTable<T> extends StatefulWidget {
  const SortableDataTable({
    required this.items,
    required this.columns,
    required this.filterBar,
    super.key,
  });

  final List<T> items;
  final List<SortableDataTableColumn<T>> columns;
  final Widget filterBar;

  @override
  State<SortableDataTable<T>> createState() => _SortableDataTableState<T>();
}

class _SortableDataTableState<T> extends State<SortableDataTable<T>> {
  int? _sortColumnIndex;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    final items = [...widget.items];
    if (_sortColumnIndex case final index?) {
      final column = widget.columns[index];
      items.sort((left, right) {
        final result =
            (column.valueOf(left)?.compareTo(column.valueOf(right)) ?? 0);
        return _ascending ? result : -result;
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.filterBar,
        const SizedBox(height: 12),
        Text('${items.length}/${widget.items.length}건'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _ascending,
            columns: [
              for (var index = 0; index < widget.columns.length; index++)
                DataColumn(
                  label: Text(widget.columns[index].label),
                  onSort: (_, ascending) => setState(() {
                    _sortColumnIndex = index;
                    _ascending = ascending;
                  }),
                ),
            ],
            rows: [
              for (final item in items)
                DataRow(
                  cells: [
                    for (final column in widget.columns)
                      DataCell(column.cellBuilder(item)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
