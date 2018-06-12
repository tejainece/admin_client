import 'dart:async';
import 'package:admin_client/admin_client.dart';

typedef FutureOr<TableRow> ListPageRowMaker<T>(T model);

class ListPageMaker<T> {
  List<ColumnSpec> colSpec;

  ListPageRowMaker<T> rowMaker;

  // TODO actions
  // TODO filters
  // TODO table
  // TODO pagination

  ListPageMaker({this.colSpec, this.rowMaker});

  View makeHeader() {
    return Box();
  }

  View makeFilter() {
    return Box();
  }

  Future<View> makeTable(List<T> model) async {
    return Box(children: [
      Table(spec: colSpec, rows: [])
    ]);
  }

  View makePaginator() {
    return Box();
  }

  Future<View> makeView(List<T> model) async {
    return Box(children: [
      makeHeader(),
      makeFilter(),
      await makeTable(model),
      makePaginator(),
    ]);
  }
}