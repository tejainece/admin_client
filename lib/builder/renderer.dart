import 'dart:html';
import 'package:admin_client/controls/controls.dart';
import 'package:admin_client/builder/renderer.dart';

final Renderers defaultRenderers = new Renderers()
  ..register<TextField>(textFieldRenderer)
  ..register<Box>(boxRenderer)
  ..register<Button>(buttonRenderer)
  ..register<IntField>(intFieldRenderer)
  ..register<Table>(tableRenderer);

Element textFieldRenderer(final field, _) {
  if (field is TextField) {
    return new DivElement()
      ..classes.add('jaguar-admin-text')
      ..text = field.text;
  }
  throw new Exception();
}

Element intFieldRenderer(final field, _) {
  if (field is IntField) {
    return new DivElement()
      ..classes.add('jaguar-admin-int')
      ..text = field.text.toString();
  }
  throw new Exception();
}

Element boxRenderer(final field, Renderers renderers) {
  if (field is Box) {
    var ret = new DivElement()..classes.add('jaguar-admin-box');
    for (View child in field.children) {
      ViewRenderer rend = renderers.getFor(child);
      if (rend == null)
        throw new Exception("Renderer for ${child.runtimeType} not found!");
      ret.append(rend(child, renderers));
    }
    return ret;
  }
  throw new Exception();
}

Element buttonRenderer(final field, Renderers renderers) {
  if (field is Button) {
    var ret = new DivElement()..classes.add('jaguar-admin-button');
    if (field.icon != null) ret.append(new DivElement()); // TODO set icon
    if (field.text != null) ret.append(new Text(field.text));
    if (field.tip != null) ret.title = field.tip;
    if (field.callback != null) ret.onClick.listen((_) => field.callback());
    return ret;
  }
  throw new Exception();
}

Element tableRenderer(final field, Renderers renderers) {
  if (field is Table) {
    // TODO resizable tables
    ViewRenderer<TextField> textRend = renderers.get<TextField>();
    if (textRend == null)
      throw new Exception("Renderer for TextField not found!");
    var header = new Element.tag('thead')
      ..classes.add('jaguar-admin-table-head');
    for (int i = 0; i < field.numCols; i++) {
      ColumnSpec spec = field.spec[i];
      var th = new Element.th()
        ..classes.add('jaguar-admin-table-head-item')
        ..append(textRend(TextField(spec.label), renderers));
      if (spec.width is FixedSize) {
        th.style.width = spec.width.size.toString() + 'px';
      } else if (spec.width is FlexSize) {
        th.style.width = spec.width.size.toString() + '%';
      }
      header.append(th);
    }
    header.append(
        new Element.th()..classes.add('jaguar-admin-table-head-item-enddummy'));
    var body = new Element.tag('tbody')..classes.add('jaguar-admin-table-body');
    for (int r = 0; r < field.numRows; r++) {
      TableRow row = field.rows[r];
      // TODO set height
      var el = new TableRowElement()..classes.add('jaguar-admin-table-row');
      for (int c = 0; c < field.numCols; c++) {
        ColumnSpec spec = field.spec[c];
        View v = row.cells[spec.name];
        if (v != null) {
          ViewRenderer ren = renderers.getFor(v);
          el.append(new TableCellElement()..append(ren(v, renderers)));
        } else {
          el.append(new TableCellElement()
            ..append(textRend(TextField(""), renderers)));
        }
      }
      body.append(el);
    }
    return new TableElement()
      ..classes.add('jaguar-admin-table')
      ..append(header)
      ..append(body)
      ..attributes.addAll({
        "cellspacing": "0",
        "cellpadding": "0",
      })
      ..style.width = '100%';
  }
  throw new Exception();
}

typedef Element ViewRenderer<T>(T view, Renderers renderers);

class Renderers {
  final _renderers = <Type, ViewRenderer>{};

  void register<T>(ViewRenderer<T> renderer) {
    _renderers[T] = renderer;
  }

  ViewRenderer<T> get<T>() => _renderers[T];

  ViewRenderer getFor(View view) => _renderers[view.runtimeType];

  void merge(Renderers other) {
    _renderers.addAll(other._renderers);
  }

  Renderers clone() {
    var ret = new Renderers();
    ret.merge(this);
    return ret;
  }
}
