// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_fast/flutter_fast_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

mixin FastDaoMixin {
  late FastDatabaseHelper dbHelper;
  late Database db;
  final Map<String, _DaoStream<dynamic>> _daoStreams = {};

  void setup(FastDatabaseHelper dbHelper) {
    this.dbHelper = dbHelper;
    db = dbHelper.db;
  }

  T? fromDb<T>(Map<String, dynamic> map, String key, {String? alias}) {
    dynamic value = map[alias ?? key] ?? map[key];
    return switch (value.runtimeType) {
      const (Null) => null,
      const (int) => dbHelper.findConverter<int, T>().fromDb(value),
      const (double) => dbHelper.findConverter<double, T>().fromDb(value),
      const (String) => dbHelper.findConverter<String, T>().fromDb(value),
      _ => throw Exception('Unsupported type: ${value.runtimeType}'),
    };
  }

  Object? toDb<R>(R? data) => dbHelper.findToConverter<R>().toDb(data);

  Future<Iterable<T>> toItemsNonNulls<T>(
      Future<List<Map<String, Object?>>> map, T? Function(Map<String, Object?>) fromMap) async {
      List<T> notNullDbItems = [];
      Iterable<T?> dbItems = (await map).map((e) => fromMap(e));
      for (T? item in dbItems) {
        if (item != null) {
          notNullDbItems.add(item);
        }
      }
      return notNullDbItems;
  }

  Future<Iterable<T?>> toItems<T>(
          Future<List<Map<String, Object?>>> map, T? Function(Map<String, Object?>) fromMap) async =>
      (await map).map((e) => fromMap(e));

  Future<T?> toSingleItem<T>(Future<List<Map<String, Object?>>> map, T? Function(Map<String, Object?>) fromMap) async {
    Map<String, Object?>? first = (await map).firstOrNull;
    return first != null ? fromMap(first) : null;
  }

  int? parseIntFromDb(Map<String, Object?> map) => fromDb(map, map.keys.firstOrNull ?? '');

  double? parseDoubleFromDb(Map<String, Object?> map) => fromDb(map, map.keys.firstOrNull ?? '');

  String? parseStringFromDb(Map<String, Object?> map) => fromDb(map, map.keys.firstOrNull ?? '');

  bool? parseBoolFromDb(Map<String, Object?> map) => fromDb(map, map.keys.firstOrNull ?? '');

  DateTime? parseDateTimeFromDb(Map<String, Object?> map) => fromDb(map, map.keys.firstOrNull ?? '');

  // ignore: non_constant_identifier_names
  List<int>? parseList_Int_FromDb(Map<String, Object?> map) => fromDb(map, map.keys.firstOrNull ?? '');

  void onTableUpdated(String tableName) {
    _daoStreams.forEach((key, value) => value.refresh(tableName));
  }

  notifyTableChange(FastDatabaseHelper helper, String tableName) {
    helper.notifyTableChange(tableName);
  }

  Stream<T> streamResult<T>(String key, List<String> tables, Future<T> Function() refreshData) {
    _DaoStream<T> daoStream = _daoStreams.putIfAbsent(
      key,
      () => _DaoStream<T>(tables, refreshData).._controller.onCancel = () => _daoStreams.remove(key),
    ) as _DaoStream<T>;
    return daoStream.stream;
  }

  Future<void> _insert<T>(
    String tableName,
    T data,
    Map<String, Object?> Function(T data) toMap, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    await db.insert(tableName, toMap(data), conflictAlgorithm: conflictAlgorithm);
    notifyTableChange(dbHelper, tableName);
  }

  Future<void> _insertAll<T>(
    String tableName,
    Iterable<T> data,
    Map<String, Object?> Function(T data) toMap, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    await db.transaction((txn) async {
      for (T item in data) {
        txn.insert(tableName, toMap(item), conflictAlgorithm: conflictAlgorithm);
      }
    });
    notifyTableChange(dbHelper, tableName);
  }

  Future<void> insertOrReplace<T>(
    String tableName,
    T data,
    Map<String, Object?> Function(T data) toMap,
  ) async =>
      _insert(tableName, data, toMap, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> insertOrIgnore<T>(
    String tableName,
    T data,
    Map<String, Object?> Function(T data) toMap,
  ) async =>
      _insert(tableName, data, toMap, conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<void> insertOrReplaceAll<T>(
    String tableName,
    Iterable<T> data,
    Map<String, Object?> Function(T data) toMap,
  ) async =>
      _insertAll(tableName, data, toMap, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> insertOrIgnoreAll<T>(
    String tableName,
    Iterable<T> data,
    Map<String, Object?> Function(T data) toMap,
  ) async =>
      _insertAll(tableName, data, toMap, conflictAlgorithm: ConflictAlgorithm.ignore);
}

class _DaoStream<T> {
  final StreamController<T> _controller = StreamController.broadcast();
  final Future<T> Function() _refreshData;
  final List<String> tablesListened;

  _DaoStream(this.tablesListened, this._refreshData) {
    _controller.onListen = () async {
      _controller.add(await _refreshData());
    };
  }

  Stream<T> get stream => _controller.stream;

  void refresh(String tableName) async {
    if (tablesListened.contains(tableName)) {
      _controller.add(await _refreshData());
    }
  }
}
