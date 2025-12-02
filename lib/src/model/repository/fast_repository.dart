import 'dart:async';

import 'package:flutter/material.dart';

abstract class FastRepository {
  final Map<String, StreamController<dynamic>> _controllers = {};
  final Map<String, Future<dynamic> Function()> _refreshingFunctions = {};

  @protected
  StreamSubscription<T> subscribe<T>(String key, Future<T> Function() refreshData, void Function(T) onData) {
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
    _controllers[key]?.add(_refreshingFunctions[key]);
  }
}
