import 'package:collection/collection.dart';

abstract class Size {
  num get size;
}

class FixedSize implements Size {
  final num size;
  const FixedSize(this.size);
  String toString() => '${size.toString()}px';
}

class FlexSize implements Size {
  final double size;
  FlexSize(this.size);
  String toString() => '${size.toString()}';
}

class PercentageSize implements Size {
  final num size;
  PercentageSize(this.size);
  String toString() => '${size.toString()}%';
}

abstract class View {
  String get key;
}

abstract class ViewWithWidth implements View {
  Size width;
  Size minWidth;
  Size maxWidth;
}

abstract class ViewMaker {
  View makeView();
}

enum VAlign { top, middle, bottom }
enum HAlign { left, center, right }

abstract class SortableView implements View {
  // TODO
}

// TODO abstract class Control implements View {}

class TextField implements View, ViewWithWidth {
  String key;
  String text;
  bool bold;
  String fontFamily;
  String color;
  final IfSet<String> classes;
  Size width;
  Size minWidth;
  Size maxWidth;

  TextField(this.text,
      {this.bold: false,
      this.key,
      this.fontFamily,
      this.color,
      String class_,
      Iterable<String> classes,
      this.width,
      this.minWidth,
      this.maxWidth})
      : classes = IfSet<String>.oneOf(classes, class_);
}

abstract class LabeledView implements View {
  View get labelField;
}

abstract class VLabeledView implements LabeledView {}

abstract class HLabeledView implements LabeledView {}

class LabeledTextField implements HLabeledView {
  String key;
  TextField labelField;
  TextField textField;
  Size height;
  VAlign vAlign;

  LabeledTextField(
      {String label,
      TextField labelField,
      TextField textField,
      String text,
      this.height,
      this.vAlign,
      this.key})
      : textField = textField ?? TextField(text),
        labelField = labelField ?? TextField(label) {
    this.labelField.classes.add('label');
  }
}

class VLabeledTextField implements VLabeledView {
  String key;
  TextField labelField;
  TextField textField;
  Size width;
  HAlign hAlign;

  VLabeledTextField(
      {String label,
      TextField labelField,
      TextField textField,
      String text,
      this.width,
      this.hAlign,
      this.key})
      : textField = textField ?? TextField(text),
        labelField = labelField ?? TextField(label) {
    this.labelField.classes.add('label');
  }
}

class IntField implements View {
  String key;
  final int text;
  final bool bold;

  IntField(this.text, {this.bold, this.key});
}

class LabeledIntField implements HLabeledView {
  String key;
  TextField labelField;
  IntField intField;
  Size height;
  VAlign vAlign;

  LabeledIntField(
      {String label,
      TextField labelField,
      IntField intField,
      int text,
      this.height,
      this.vAlign,
      this.key})
      : intField = intField ?? IntField(text),
        labelField = labelField ?? TextField(label) {
    this.labelField.classes.add('label');
  }
}

class VLabeledIntField implements VLabeledView {
  String key;
  TextField labelField;
  IntField intField;
  Size width;
  HAlign hAlign;

  VLabeledIntField(
      {String label,
      TextField labelField,
      IntField intField,
      int text,
      this.width,
      this.hAlign,
      this.key})
      : intField = intField ?? IntField(text),
        labelField = labelField ?? TextField(label) {
    this.labelField.classes.add('label');
  }
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

  static const String green = '#19ac19';
}

abstract class Container implements View {
  T getByKey<T extends View>(String key);
  T deepGetByKey<T extends View>(Iterable<String> keys);
}

class EdgeInset {
  Size top;
  Size right;
  Size bottom;
  Size left;
  EdgeInset({Size top, Size right, Size bottom, Size left, Size rest})
      : top = top ?? rest,
        right = right ?? rest,
        bottom = bottom ?? rest,
        left = left ?? rest;
  EdgeInset.v(Size pad, {Size rest})
      : top = pad,
        bottom = pad,
        right = rest,
        left = rest;
  EdgeInset.h(Size pad, {Size rest})
      : right = pad,
        left = pad,
        top = rest,
        bottom = rest;
  EdgeInset.all(Size pad)
      : top = pad,
        right = pad,
        bottom = pad,
        left = pad;
}

class Box implements Container {
  final String key;
  final List<View> children;
  final IfSet<String> classes; // TODO: Make it, bi-directional
  final Size width;
  final Size height;
  HAlign hAlign;
  VAlign vAlign;
  final EdgeInset pad;
  final EdgeInset margin;
  Box(
      {View child,
      List<View> children,
      this.key,
      Iterable<String> classes: const [],
      this.width,
      this.height,
      this.hAlign,
      this.vAlign,
      this.pad,
      this.margin})
      : children =
            children ?? (child != null ? <View>[child] : null) ?? <View>[],
        classes = IfSet<String>.from(classes);
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
  final IfList<View> children;
  final IfSet<String> classes;
  final Size width;
  final Size height;
  HAlign hAlign;
  VAlign vAlign;
  final EdgeInset pad;
  final EdgeInset margin;
  HBox(
      {View child,
      Iterable<View> children,
      this.key,
      Iterable<String> classes: const [],
      this.width,
      this.height,
      this.hAlign,
      this.vAlign: VAlign.middle,
      this.pad,
      this.margin})
      : children = IfList<View>.from(
            children ?? (child != null ? <View>[child] : null) ?? <View>[]),
        classes = IfSet<String>.from(classes);
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

typedef bool Condition();

class IfList<E> extends DelegatingList<E> implements List<E> {
  IfList([int length]) : super(List<E>(length));

  IfList.filled(int length, E fill, {bool growable: false})
      : super(List<E>.filled(length, fill, growable: growable));

  IfList.from(Iterable<E> elements, {bool growable: true})
      : super(List<E>.from(elements, growable: growable));

  IfList.oneOf(Iterable<E> elements, [E element])
      : super(elements?.toList() ?? <E>[element] ?? <E>[]);

  IfList.of(Iterable<E> elements, {bool growable: true})
      : super(List<E>.of(elements, growable: growable));

  IfList.generate(int length, E generator(int index), {bool growable: true})
      : super(List<E>.generate(length, generator, growable: growable));

  void addIf(/* bool | Condition */ condition, E element) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(element);
  }

  void addAllIf(/* bool | Condition */ condition, Iterable<E> elements) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(elements);
  }
}

class IfMap<K, V> extends DelegatingMap<K, V> implements Map<K, V> {
  IfMap() : super(<K, V>{});

  IfMap.from(Map other) : super(Map<K, V>.from(other));

  IfMap.of(Map<K, V> other) : super(Map<K, V>.of(other));

  IfMap.fromIterable(Iterable iterable, {K key(element), V value(element)})
      : super(Map<K, V>.fromIterable(iterable, key: key, value: value));

  IfMap.fromIterables(Iterable<K> keys, Iterable<V> values)
      : super(Map<K, V>.fromIterables(keys, values));

  IfMap.fromEntries(Iterable<MapEntry<K, V>> entries)
      : super(Map<K, V>.fromEntries(entries));

  void add(K key, V value) => this[key] = value;

  void addIf(/* bool | Condition */ condition, K key, V value) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) this[key] = value;
  }

  void addAllIf(/* bool | Condition */ condition, Map<K, V> values) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(values);
  }
}

class IfSet<E> extends DelegatingSet<E> implements Set<E> {
  IfSet() : super(new Set<E>());

  IfSet.from(Iterable elements) : super(Set<E>.from(elements));

  IfSet.oneOf(Iterable<E> elements, [E element])
      : super(Set<E>.from(elements ?? <E>[element] ?? <E>[]));

  IfSet.of(Iterable<E> elements) : super(Set<E>.of(elements));
}
