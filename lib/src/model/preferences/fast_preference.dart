import 'dart:async';

import 'package:flutter/material.dart';

class FastPreference<T> extends ValueNotifier<T> {
  FastPreference(
    T value,
    this.key, {
    this.decode,
    this.deferLoad = false,
    Future<T> Function()? future,
    final String Function(T value)? enc,
    this.saveDelayMillis = 0,
  }) : super(value) {
    if (decode != null || enc != null) {
      if (decode == null) {
        debugPrint("Prefence with key $key has defined encode, but no decode function.");
      }
      if (enc == null) {
        debugPrint("Prefence with key $key has defined decode, but no encode function.");
      } else {
        encode = (v) => enc(v as T);
      }
    }
    // If another value was set when the future completes (e.g. read preference), don't update the value.
    future?.call().then((v) => super.value = super.value == value ? v : super.value);
  }

  final String key;
  final int saveDelayMillis;
  late final T Function(String value)? decode;
  late final String Function(dynamic value)? encode;
  final bool deferLoad;
  final StreamController<T> streamController = StreamController.broadcast();
  late Stream<T> stream = streamController.stream;
}
