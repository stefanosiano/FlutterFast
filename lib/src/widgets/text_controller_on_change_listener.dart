import 'package:flutter/material.dart';

/// Controller that calls a function when its value changes, only if the new value is different than the previous one.
/// Example:
/// ```dart
/// // outside build
/// TextEditingControllerOnChange _myController = TextEditingControllerOnChange();
/// ...
/// // inside build
/// TextField(
///   controller: _myController.update((text) { ... }),
/// ),
/// ```
class TextEditingControllerOnChange extends TextEditingController {
  String _lastText = "";
  void Function(String text)? _onChange;
  late final void Function() _listener = _onTextChanged;

  TextEditingControllerOnChange() {
    addListener(_listener);
  }

  /// Updates the controller value with [currentValue], and calls [onChange] whenever the text changes.
  TextEditingControllerOnChange update(void Function(String text) onChange) {
    _onChange = onChange;
    _listener();
    return this;
  }

  void _onTextChanged() {
    final String newText = value.text;
    if (_lastText != newText && _onChange != null) {
      _lastText = newText;
      _onChange?.call(newText);
    }
  }
}
