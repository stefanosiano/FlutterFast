/// Generate the [FastDao] implementation, with all the queries, and the [FastDatabaseHelper] extension to instantiate it.
/// The annotated class must implement [FastDao].
/// The table dao generates the insert methods of the specified [entityClass] in the table named [tableName]. The inserts will also update all the queries listening on that table.
/// E.g. to generate a dao:
/// ```dart
/// @Dao.table(
///   entityClass: MyClass,
///   tableName: 'table',
/// )
/// abstract class MyDao implements FastDao {
///   @Query.update('update table set field = :value', updateTable: 'table')
///   Future<void> updateMyTable({required String value});
///
///   @Query.stream('select name from table join table2', tables: ['table', 'table2'])
///   Stream<Iterable<String>> findAllNamesStream();
///
///   @Query('select name from table')
///   Future<Iterable<String>> findAllNames();
///
///   @Query.stream('select * from table where name = :name', tables: ['table'])
///   Stream<MyClass?> findOneStream({required String name});
///
///   @Query('select * from table where name = :name')
///   Future<MyClass?> findOne([String? name]);
/// }
/// ```
class Dao {
  final Type? entityClass;
  final String? tableName;

  /// Generate the [FastDao] implementation, with all the queries, and the [FastDatabaseHelper] extension to instantiate it.
  /// The annotated class must implement [FastDao].
  /// It also generates the insert methods of the specified [entityClass] in the table named [tableName]. The inserts will also update all the queries listening on that table.
  /// E.g. to generate a dao:
  /// ```dart
  /// @Dao.table(
  ///   entityClass: MyClass,
  ///   tableName: 'table',
  /// )
  /// abstract class MyDao implements FastDao {
  /// }
  /// ```
  const Dao.table({
    required this.entityClass,
    required this.tableName,
  });

  /// Generate the [FastDao] implementation, with all the queries, and the [FastDatabaseHelper] extension to instantiate it.
  /// The annotated class must implement [FastDao].
  /// E.g. to generate a dao:
  /// ```dart
  /// @Dao()
  /// abstract class MyDao implements FastDao {
  /// }
  /// ```
  const Dao()
      : entityClass = null,
        tableName = null;

  @override
  String toString() {
    return 'Dao{tableName: $tableName, entityClass: $entityClass}';
  }
}
