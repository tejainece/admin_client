abstract class View {
  String get key;
}

enum VAlign { top, middle, bottom }
enum HAlign { left, center, right }

abstract class SortableView implements View {
  // TODO
}

// TODO abstract class Control implements View {}

abstract class Input implements View {}

class TextField implements View {
  String key;
  String text;
  bool bold;

  TextField(this.text, {this.bold: false, this.key});
}

class LabeledTextField implements View {
  String key;
  String text;
  String label;

  LabeledTextField(this.text, this.label, {this.key});
}

class VLabeledTextField implements View {
  String key;
  final String text;
  final String label;

  VLabeledTextField(this.text, this.label, {this.key});
}

class IntField implements View {
  String key;
  final int text;
  final bool bold;

  IntField(this.text, {this.bold, this.key});
}

class LabeledIntField implements View {
  String key;
  final int text;
  final String label;

  LabeledIntField(this.text, this.label, {this.key});
}

class VLabeledIntField implements View {
  String key;
  final int text;
  final String label;

  VLabeledIntField(this.text, this.label, {this.key});
}

typedef dynamic Callback();

class Button implements View {
  String key;
  final String icon;

  final String text;

  final Callback onClick;

  final String tip;

  final String color;

  final int fontSize;

  Button(
      {this.icon,
      this.text,
      this.onClick,
      this.tip,
      this.color: blue,
      this.fontSize,
      this.key});

  static const String blue = '#2687c1';

  static const String red = 'rgb(208, 51, 51)';
}

abstract class Container implements View {
  T getByKey<T extends View>(String key);
  T deepGetByKey<T extends View>(Iterable<String> keys);
}

class Box implements Container {
  final String key;
  final List<View> children;
  Box({List<View> children, this.key}) : children = children ?? <View>[];
  void addChild(View v) => children.add(v);
  void addChildren(Iterable<View> v) => children.addAll(v);
  T getByKey<T extends View>(String key) =>
      children.firstWhere((v) => v.key == key, orElse: () => null);
  T deepGetByKey<T extends View>(Iterable<String> keys) {
    if (key.length == 0) return null;
    View ret =
        children.firstWhere((v) => v.key == keys.first, orElse: () => null);
    if (ret == null) return null;
    if (keys.length == 1) return ret;
    if (ret is Container) {
      if (keys.length == 2) return ret.getByKey<T>(keys.last);
      return ret.deepGetByKey<T>(keys.skip(1));
    }
    return null;
  }
}

class HBox implements View {
  String key;
  final List<View> children;

  HBox({List<View> children, this.key}) : children = children ?? <View>[];
  void addChild(View v) => children.add(v);
  void addChildren(Iterable<View> v) => children.addAll(v);
  T getByKey<T extends View>(String key) =>
      children.firstWhere((v) => v.key == key, orElse: () => null);
  T deepGetByKey<T extends View>(Iterable<String> keys) {
    if (key.length == 0) return null;
    View ret =
        children.firstWhere((v) => v.key == keys.first, orElse: () => null);
    if (ret == null) return null;
    if (keys.length == 1) return ret;
    if (ret is Container) {
      if (keys.length == 2) return ret.getByKey<T>(keys.last);
      return ret.deepGetByKey<T>(keys.skip(1));
    }
    return null;
  }
}
