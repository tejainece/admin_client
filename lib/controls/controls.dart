abstract class View {}

abstract class Control implements View {}

abstract class Display implements Control {}

class TextField implements Display {
  final String text;

  final String label;

  TextField(text, this.label) : text = text.toString();
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
