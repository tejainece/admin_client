abstract class View {}

abstract class SortableView implements View {
  // TODO
}

// TODO abstract class Control implements View {}

abstract class Input implements View {}

class TextField implements View {
  final String text;
  final bool bold;

  TextField(this.text, {this.bold: false});
}

class LabeledTextField implements View {
  final String text;
  final String label;

  LabeledTextField(this.text, this.label);
}

class VLabeledTextField implements View {
  final String text;
  final String label;

  VLabeledTextField(this.text, this.label);
}

class IntField implements View {
  final int text;
  final bool bold;

  IntField(this.text, {this.bold});
}

class LabeledIntField implements View {
  final int text;
  final String label;

  LabeledIntField(this.text, this.label);
}

class VLabeledIntField implements View {
  final int text;
  final String label;

  VLabeledIntField(this.text, this.label);
}

typedef dynamic Callback();

class Button implements View {
  final String icon;

  final String text;

  final Callback callback;

  final String tip;

  final String color;

  final int fontSize;

  Button(
      {this.icon,
      this.text,
      this.callback,
      this.tip,
      this.color: blue,
      this.fontSize});

  static const String blue = '#2687c1';

  static const String red = 'rgb(208, 51, 51)';
}

class Box implements View {
  final List<View> children;

  Box({List<View> children}) : children = children ?? <View>[];
}

class HBox implements View {
  final List<View> children;

  HBox({List<View> children}) : children = children ?? <View>[];
}
