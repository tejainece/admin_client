import 'controls.dart';

typedef T ValueGetter<T>();

typedef void ValueSetter<T>(T value);

abstract class EditView<T> implements View {
  ValueGetter<T> readValue = () => null;

  ValueSetter<T> setValue = (_) => null;
}

class TextEdit extends EditView<String> {
  String key;
  String initial;
  String placeholder;
  bool bold;
  TextEdit({this.initial, this.placeholder, this.bold: false, this.key});
}

class IntEdit extends EditView<int> {
  String key;
  int initial;
  String placeholder;
  bool bold;
  IntEdit({this.initial, this.placeholder, this.bold: false, this.key});
}

class LabeledTextEdit extends EditView<String> {
  String key;
  final TextField labelField;
  final TextEdit editField;
  final int height;
  final VAlign vAlign;
  LabeledTextEdit(
      {String label,
      TextField labelField,
      TextEdit editField,
      String initial,
      String placeholder,
      this.height,
      this.vAlign,
      this.key})
      : editField =
            editField ?? TextEdit(initial: initial, placeholder: placeholder),
        labelField = labelField ?? TextField(label) {
    this.labelField.classes.add('label');
  }

  ValueGetter<String> get readValue => editField.readValue;

  set readValue(ValueGetter<String> value) => editField.readValue = value;

  ValueSetter<String> get setValue => editField.setValue;

  set setValue(ValueSetter<String> value) => editField.setValue = value;
}

class LabeledIntEdit extends EditView<int> {
  String key;
  final TextField labelField;
  final IntEdit editField;
  final int height;
  final VAlign vAlign;
  LabeledIntEdit(
      {String label,
        TextField labelField,
        IntEdit editField,
        int initial,
        String placeholder,
        this.height,
        this.vAlign,
        this.key})
      : editField =
      editField ?? IntEdit(initial: initial, placeholder: placeholder),
        labelField = labelField ?? TextField(label) {
    this.labelField.classes.add('label');
  }

  ValueGetter<int> get readValue => editField.readValue;

  set readValue(ValueGetter<int> value) => editField.readValue = value;

  ValueSetter<int> get setValue => editField.setValue;

  set setValue(ValueSetter<int> value) => editField.setValue = value;
}
