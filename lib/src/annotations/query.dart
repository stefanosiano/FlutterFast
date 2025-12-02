/// Generate the [Query] implementation.
/// Parameters of the method can be used in the query by prefixing them with ':'.
///
/// There are the following types of Query:
///
/// Query() - A select query. It returns a Future.
///   If the return type is a single type, then the first element retrieved by the query will be parsed as the specified type, if present, otherwise null is returned.
///   If the return type is an Iterable\<Type?> then all elements retrieved by the query will be parsed as the specified type.
///   If the return type is an Iterable\<Type> then all elements retrieved by the query will be parsed as the specified type. Null elements will be removed automatically.
///
/// Query.stream() - A select query that is executed everytime a table among [tables] is updated. The same strategy of the Query() applies with regard to return types.
///
/// Query.update() - An update query. Returns a Future\<void>. It will also update all the queries listening on the specified table.
///
/// E.g. to generate a query implementation:
/// ```dart
/// @Query.update('update table set field = :value', updateTable: 'table')
/// Future<void> updateMyTable({required String value});
///
/// @Query.stream('select name from table join table2', tables: ['table', 'table2'])
/// Stream<Iterable<String>> findAllNamesStream();
///
/// @Query('select * from table where name = :name')
/// Future<MyClass?> findOne([String? name]);
/// ```
class Query {
  final String value;
  final Iterable<String> tables;
  final String updateTable;
  final bool isInsertOrUpdate;
  final bool isSelect;
  final bool isStream;

  /// Generate the [Query] implementation.
  /// Parameters of the method can be used in the query by prefixing them with ':'.
  ///
  /// It returns a Future.
  ///   If the return type is a single type, then the first element retrieved by the query will be parsed as the specified type, if present, otherwise null is returned.
  ///   If the return type is an Iterable\<Type?> then all elements retrieved by the query will be parsed as the specified type.
  ///   If the return type is an Iterable\<Type> then all elements retrieved by the query will be parsed as the specified type. Null elements will be removed automatically.
  ///
  /// To automatically execute the select everytime the table is updated use Query.stream().
  ///
  /// E.g. to generate a query implementation:
  /// ```dart
  /// @Query('select name from table')
  /// Future<Iterable<String>> findAllNamesExcludingNulls();
  ///
  /// @Query('select name from table')
  /// Future<Iterable<String?>> findAllNames();
  ///
  /// @Query('select * from table where name = :name')
  /// Future<MyClass?> findOne([String? name]);
  /// ```
  const Query(this.value)
      : isInsertOrUpdate = false,
        updateTable = '',
        tables = const [],
        isSelect = true,
        isStream = false;

  /// Generate the [Query] implementation.
  /// Parameters of the method can be used in the query by prefixing them with ':'.
  ///
  /// It generates an update query, and returns Future\<void>. It will also update all the queries listening on the specified [updateTable].
  ///
  /// E.g. to generate a query implementation:
  /// ```dart
  /// @Query.update('update table set field = :value', updateTable: 'table')
  /// Future<void> updateMyTable({required String value});
  /// ```
  const Query.update(this.value, {required this.updateTable})
      : isInsertOrUpdate = true,
        tables = const [],
        isSelect = false,
        isStream = false;

  /// Generate the [Query] implementation.
  /// Parameters of the method can be used in the query by prefixing them with ':'.
  ///
  /// It returns a Future and is executed everytime one of [tables] is updated.
  ///
  /// If the return type is a single type, then the first element retrieved by the query will be parsed as the specified type, if present, otherwise null is returned.
  /// If the return type is an Iterable\<Type?> then all elements retrieved by the query will be parsed as the specified type.
  /// If the return type is an Iterable\<Type> then all elements retrieved by the query will be parsed as the specified type. Null elements will be removed automatically.
  ///
  /// To update a table so that the stream is refreshed, use Query.update() or one of the generated insert methods. They will call FastDatabaseHelper.notifyTableChange() under the hood.
  ///
  /// If you want a query that doesn't refresh, use Query()
  ///
  /// E.g. to generate a query implementation:
  /// ```dart
  /// @Query.stream('select name from table join table2', tables: ['table', 'table2'])
  /// Stream<Iterable<String>> findAllNamesStreamExcludingNulls();
  ///
  /// @Query.stream('select name from table join table2', tables: ['table', 'table2'])
  /// Stream<Iterable<String?>> findAllNamesStream();
  ///
  /// @Query.stream('select * from table where name = :name', tables: ['table'])
  /// Stream<MyClass?> findOneStream({required String name});
  /// ```
  const Query.stream(this.value, {required this.tables})
      : isInsertOrUpdate = false,
        updateTable = '',
        isSelect = false,
        isStream = true;
}
