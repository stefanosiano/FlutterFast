// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter_fast/flutter_fast_database.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

abstract class FastDatabaseHelper {
  bool _isInitialized = false;
  late Set<FastDaoMixin> _daos;
  late Database _database;

  final Set<FastDaoConverter<dynamic, dynamic>> _converters = {
    FastDaoConverterInt<int>(
      fromDb: (int? data) => data,
      toDb: (int? data) => data,
    ),
    FastDaoConverterReal<double>(
      fromDb: (double? data) => data,
      toDb: (double? data) => data,
    ),
    FastDaoConverterText<String>(
      fromDb: (String? data) => data,
      toDb: (String? data) => data,
    ),
    FastDaoConverterInt<bool>(
      fromDb: (int? data) => data == null ? null : data == 1,
      toDb: (bool? data) => data == null ? null : (data ? 1 : 0),
    ),
    FastDaoConverterInt<DateTime>(
      fromDb: (int? data) => data != null ? DateTime.fromMillisecondsSinceEpoch(data) : null,
      toDb: (DateTime? data) => data?.millisecondsSinceEpoch,
    ),
    FastDaoConverterText<List<int>>(
      fromDb: (String? data) => data?.split(',').map((e) => int.parse(e)).toList(),
      toDb: (List<int>? data) => data?.join(','),
    ),
  };

  /// Initialize the database
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _daos = Set.castFrom(daos);

    // Initialize FFI
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
    }
    // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
    // this step, it will use the sqlite version available on the system.
    databaseFactory = kIsWeb ? databaseFactoryFfiWeb : databaseFactoryFfi;

    String dbPath = dbName;
    if (dbDirPath != null) {
      dbPath = '$dbDirPath/$dbPath';
    } else if (!kIsWeb) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      dbPath = '${appDocDir.path}/$dbPath';
    }
    debugPrint('Database open in $dbPath');

    _database = await openDatabase(dbPath, version: version, onUpgrade: _upgradeDb);
    for (FastDaoMixin dao in _daos) {
      dao.setup(this);
    }

    _converters.addAll(customConverters);

    Set<Type> found = {};
    Set<Type> duplicates = {};

    for (FastDaoConverter converter in _converters) {
      if (found.contains(converter.dartType)) {
        duplicates.add(converter.dartType);
      } else {
        found.add(converter.dartType);
      }
    }
    if (duplicates.isNotEmpty) {
      throw Exception(
          'Multiple database converters found for the following types: $duplicates. Please, specify only one for each of them.');
    }
  }

  // Generate a range of numbers between from and to, including from and excluding to
  // e.g. from = 1, to = 5 -> range = [1, 2, 3, 4]
  List<int> _range(int from, int to) => List.generate(to - from, (i) => i + from);

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    // Iterate over the versions between old and new, excluding oldVersion and including newVersion
    // e.g. oldVersion = 1, newVersion = 5 -> range = [2, 3, 4, 5]
    db.transaction((txn) async {
      _range(oldVersion, newVersion).forEach((i) async {
        debugPrint('Running migration from $i to ${i + 1}');
        await migrate(txn, i + 1);
      });
    });
  }

  /// Get the database
  get db => _database;

  FastDaoConverter<T, R> findConverter<T, R>() =>
      _converters.firstWhere((element) => element.sqlType == T && element.dartType == R) as FastDaoConverter<T, R>;

  FastDaoConverter<Object, R> findToConverter<R>() =>
      _converters.firstWhere((element) => element.dartType == R) as FastDaoConverter<Object, R>;

  /// Notify all daos that a table has been updated, so they can update their streams
  void notifyTableChange(String tableName) {
    for (FastDaoMixin dao in _daos) {
      dao.onTableUpdated(tableName);
    }
  }

  /// The migration function. It will be invoked once per version between the old and current version.
  ///   If version bumped by 4, the migration will be invoked 4 times, with the new version as parameter.
  Future<void> migrate(Transaction txn, int newVersion);

  /// The current version of the database
  int get version;

  /// Set of daos, retrieved through extensions like [databaseHelper.myDao()]
  Set<FastDao> get daos;

  /// Name of the database
  String get dbName;

  /// Path to the database directory. If null, the documents dir path is used
  String? get dbDirPath => null;

  /// [customConverters] the set of custom converters
  Set<FastDaoConverter<dynamic, dynamic>> get customConverters => {};
}
