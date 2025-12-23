import 'dart:async';

import 'package:flutter/material.dart';

abstract class FastRepository {
  final Map<String, StreamController<dynamic>> _controllers = {};
  final Map<String, FutureOr<dynamic> Function()> _refreshingFunctions = {};

  @protected
  StreamSubscription<T> subscribe<T>(String key, FutureOr<T> Function() refreshData, void Function(T) onData) {
    StreamController<T> controller = StreamController<T>();
    _controllers[key] = controller
      ..onListen = () async {
        controller.add(await refreshData());
      }
      ..onCancel = () => controller.close();
    _refreshingFunctions[key] = refreshData;
    return controller.stream.listen((data) => onData(data));
  }

  @protected
  void refreshStream(String key) {
    if (_refreshingFunctions[key] is Future<dynamic> Function()) {
      (_refreshingFunctions[key] as Future<dynamic> Function())().then((data) {
        _controllers[key]?.add(data);
      });
    } else {
      _controllers[key]?.add(_refreshingFunctions[key]?.call());
    }
  }
}
