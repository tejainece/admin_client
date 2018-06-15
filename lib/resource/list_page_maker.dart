import 'dart:async';
import 'package:admin_client/admin_client.dart';
import 'package:admin_client/controls/fa_solid.dart';

typedef FutureOr<TableRow> ListPageRowMaker<T>(T model);

class ListPageMaker<T> {
  List<ColumnSpec> colSpec;

  ListPageRowMaker<T> rowMaker;

  // TODO actions
  // TODO filters
  // TODO table
  // TODO pagination

  ListPageMaker({this.colSpec, this.rowMaker}) {
    colSpec.insert(0, ColumnSpec(''));
  }

  View makeHeader(List<T> model, Resource<T> r, Context ctx) {
    return HBox(
        children: [
          HBox(
              children: [
                TextField(FASolid.list, fontFamily: 'fa5-free'),
                TextField(r.label, classes: ['jaguar-admin-title'])
              ],
              width: FlexSize(1.0),
              height: PercentageSize(100),
              vAlign: VAlign.middle),
          HBox(children: [
            Button(
                text: '\uf0b0 Filter',
                color: Button.green,
                fontSize: 12,
                onClick: () {
                  // TODO filter
                }),
            Button(
                text: '\uf067 Add',
                color: Button.green,
                fontSize: 12,
                onClick: () {
                  ctx.navigator.add(Route(r.createUrl));
                })
          ], height: PercentageSize(100), vAlign: VAlign.middle),
        ],
        width: PercentageSize(100),
        height: FixedSize(52),
        vAlign: VAlign.middle,
        classes: ['jaguar-admin-titlebar']);
  }

  Future<View> makeTable(List<T> model, Resource<T> r, Context ctx) async {
    final rows = new List<TableRow>.filled(model.length, null, growable: true);
    for (int i = 0; i < model.length; i++) {
      TableRow row = await rowMaker(model[i]);
      row.cells[''] = Box(children: [
        Button(
            text: '\uf06e',
            onClick: () {
              ctx.navigator.add(Route(r.readUrl));
            }),
        Button(
            text: '\uf303',
            onClick: () {
              ctx.navigator.add(Route(r.updateUrl));
            }),
        Button(
            text: '\uf2ed',
            color: Button.red,
            onClick: () {
              // TODO delete
            }),
      ]);
      rows[i] = row;
    }
    return Box(
        child: Box(
            child: Table(spec: colSpec, rows: rows),
            classes: ['admin-content-body']));
  }

  View makePaginator(List<T> model, Resource<T> r, Context ctx) {
    return Box();
  }

  Future<View> makeView(List<T> model, Resource<T> r, Context ctx) async {
    return Box(children: [
      makeHeader(model, r, ctx),
      await makeTable(model, r, ctx),
      makePaginator(model, r, ctx),
    ]);
  }
}
