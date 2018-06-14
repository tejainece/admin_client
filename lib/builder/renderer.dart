import 'dart:html';
import 'package:admin_client/controls/controls.dart';
import 'package:admin_client/builder/renderer.dart';

final Renderers defaultRenderers = new Renderers()
  ..register<Box>(boxRenderer)
  ..register<HBox>(hBoxRenderer)
  ..register<TextField>(textFieldRenderer)
  ..register<LabeledTextField>(labeledTextFieldRenderer)
  ..register<VLabeledTextField>(vLabeledTextFieldRenderer)
  ..register<Button>(buttonRenderer)
  ..register<IntField>(intFieldRenderer)
  ..register<Table>(tableRenderer)
  ..register<LabeledIntField>(labeledIntFieldRenderer)
  ..register<VLabeledIntField>(vLabeledIntFieldRenderer)
  ..register<TextEdit>(textEditRenderer)
  ..register<LabeledTextEdit>(labeledTextEditRenderer);

Element textEditRenderer(final field, Renderers renderers) {
  if (field is TextEdit) {
    var ret = new TextInputElement()
      ..classes.add('jaguar-admin-textinput')
      ..value = field.initial;
    if (ret.placeholder != null) ret.placeholder = field.placeholder;
    if (field.bold) ret.style.fontWeight = 'bold';
    field.valueGetter = () => ret.value;
    return ret;
  }
  throw new Exception();
}

Element labeledTextEditRenderer(final field, Renderers renderers) {
  if (field is LabeledTextEdit) {
    ViewRenderer<HBox> hBoxRend = renderers.get<HBox>();
    var ret = hBoxRend(
        HBox(children: [
          field.labelField,
          field.editField,
        ]),
        renderers);
    ret.classes.add('jaguar-admin-labeled-textinput');
    return ret;
  }
  throw new Exception();
}

Element textFieldRenderer(final field, _) {
  if (field is TextField) {
    var ret = new DivElement()
      ..classes.add('jaguar-admin-text')
      ..text = field.text;
    if (field.bold) ret.style.fontWeight = 'bold';
    return ret;
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

Element labeledTextFieldRenderer(final field, Renderers renderers) {
  if (field is LabeledTextField) {
    ViewRenderer<HBox> hBoxRend = renderers.get<HBox>();
    var ret = new DivElement()
      ..classes.add('jaguar-admin-labeled-text')
      ..append(hBoxRend(
          HBox(children: [
            TextField(field.label, bold: true),
            TextField(field.text)
          ]),
          renderers));
    return ret;
  }
  throw new Exception();
}

Element vLabeledTextFieldRenderer(final field, Renderers renderers) {
  if (field is VLabeledTextField) {
    return new DivElement()
      ..classes.add('jaguar-admin-text')
      ..text = field.text;
  }
  throw new Exception();
}

Element labeledIntFieldRenderer(final field, Renderers renderers) {
  if (field is LabeledIntField) {
    ViewRenderer<HBox> hBoxRend = renderers.get<HBox>();
    var ret = new DivElement()
      ..classes.add('jaguar-admin-labeled-text')
      ..append(hBoxRend(
          HBox(children: [
            TextField(field.label, bold: true),
            IntField(field.text)
          ]),
          renderers));
    return ret;
  }
  throw new Exception();
}

Element vLabeledIntFieldRenderer(final field, Renderers renderers) {
  if (field is VLabeledIntField) {
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

Element hBoxRenderer(final field, Renderers renderers) {
  if (field is HBox) {
    var ret = new DivElement()..classes.add('jaguar-admin-hbox');
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
    var ret = new SpanElement()
      ..classes.add('jaguar-admin-button')
      ..style.color = field.color;
    if (field.icon != null) ret.append(new SpanElement()); // TODO set icon
    if (field.text != null) ret.append(new SpanElement()..text = field.text);
    if (field.fontSize != null) ret.style.fontSize = '${field.fontSize}px';
    if (field.tip != null) ret.title = field.tip;
    if (field.onClick != null) ret.onClick.listen((_) => field.onClick());
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
    return new DivElement()
      ..classes.add('jaguar-admin-table-frame')
      ..append(new TableElement()
        ..classes.add('jaguar-admin-table')
        ..append(header)
        ..append(body)
        ..attributes.addAll({
          "cellspacing": "0",
          "cellpadding": "0",
        }));
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
