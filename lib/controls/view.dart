abstract class View {}

abstract class SortableView implements View {
  // TODO
}

// TODO abstract class Control implements View {}

abstract class Input implements View {}

class TextField implements View {
  final String text;

  final String label;

  TextField(this.text, {this.label});
}

class IntField implements View {
  final int text;

  final String label;

  IntField(this.text, {this.label});
}

typedef dynamic Callback();

class Button implements View {
  final String icon;

  final String text;

  final Callback callback;

  final String tip;

  Button({this.icon, this.text, this.callback, this.tip});
}

class Box implements View {
  final List<View> children;

  Box({List<View> children}) : children = children ?? <View>[];
}
