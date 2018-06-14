import 'controls.dart';

typedef T ValueGetter<T>();

abstract class EditView<T> implements View {
  ValueGetter<T> get valueGetter;
  T readValue() => valueGetter != null ? valueGetter() : null;
}

class TextEdit extends EditView<String> {
  String key;
  String initial;
  String placeholder;
  bool bold;
  ValueGetter<String> valueGetter;
  TextEdit({this.initial, this.placeholder, this.bold: false, this.key});
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
        labelField = labelField ?? TextField(label);

  ValueGetter<String> get valueGetter => editField.valueGetter;
}
