import 'controls.dart';

// TODO:
// 1) Sortable
// 2) Resizable columns

class TableRow implements View {
  final Size height;
  final FixedSize minHeight;
  final FixedSize maxHeight;
  Map<String, View> cells;
  TableRow(this.cells, {this.height, this.minHeight, this.maxHeight});
}

class ColumnSpec<T> {
  final String label;
  final String name;
  final Size width;
  final FixedSize minWidth;
  final FixedSize maxWidth;
  final bool isResizable;
  // TODO

  ColumnSpec(this.label,
      {String name,
      this.width,
      this.minWidth,
      this.maxWidth,
      this.isResizable: true})
      : name = name ?? label;

  bool operator==(other) {
    if(other is ColumnSpec) return name == other.name;
    return false;
  }

  int get hashCode => name.hashCode;
}

class Table implements View {
  List<ColumnSpec> spec;

  List<TableRow> rows;

  final bool isResponsive;

  Table({this.spec, this.rows, this.isResponsive: false});

  int get numCols => spec.length;

  int get numRows => rows.length;
}

abstract class Size {
  num get size;
}

class FixedSize implements Size {
  final num size;
  FixedSize(this.size);
}

class FlexSize implements Size {
  final num size;
  FlexSize(this.size);
}
