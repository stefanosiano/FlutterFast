/// Generate the parse methods that will be used by the daos.
/// It also generates a comment with the query to create the table, to help with the migration creation.
/// The [constructorName] will be called when parsing from the database map. It defaults to '', which means the default constructor will be called.
///
/// Each field behaviour can be specified through [QueryableField].
///
/// E.g. to generate a query implementation:
/// ```dart
/// @Queryable(constructorName = 'fromDb')
/// class MyClass implements FastQueryable {
///   final int id;
///   @QueryableField(ignore: true)
///   final String ignored;
///
///   MyClass.fromDb({
///     required this.id,
///   }) : ignored = 'ignore';
/// ```
class Queryable {
  final String constructorName;

  /// Generate the parse methods that will be used by the daos.
  /// It also generates a comment with the query to create the table, to help with the migration creation.
  /// The [constructorName] will be called when parsing from the database map. It defaults to '', which means the default constructor will be called.
  ///
  /// Each field behaviour can be specified through [QueryableField].
  ///
  /// E.g. to generate a query implementation:
  /// ```dart
  /// @Queryable(constructorName = 'fromDb')
  /// class MyClass implements FastQueryable {
  ///   final int id;
  ///   @QueryableField(ignore: true)
  ///   final String ignored;
  ///
  ///   MyClass.fromDb({
  ///     required this.id,
  ///   }) : ignored = 'ignore';
  /// ```
  const Queryable({this.constructorName = ''});
}

/// Specifies the behaviour of the [Queryable] generator for each field.
///
/// You can specify:
///
/// [columnName] - Used to map the field to the column name. Defaults to the field name
/// [ignore] - If true, this field will be ignored by the generator. Defaults to false
/// [fromDb] - Custom function to decode the object retrieved from the database to the field type.
///   Its return type must be the same of the field and of the [toDb] parameter.
///   Its parameter type must be the same of the [toDb] return type.
/// [toDb] - Custom function to encode the field into an object to save in the database.
///   Its parameter type must be the same of the field and of the [toDb] return type.
///   Its return type must be the same of the [fromDb] parameter type.
///
/// E.g. to generate a query implementation:
/// ```dart
/// final int id;
///
/// @QueryableField(columnName: '_id')
/// final int id2;
///
/// @QueryableField(ignore: true)
/// final String ignored;
/// ```
class QueryableField<ColumnType, FieldType> {
  final String? columnName;
  final bool ignore;
  final FieldType Function(ColumnType dbData)? fromDb;
  final ColumnType Function(FieldType data)? toDb;

  /// Specifies the behaviour of the [Queryable] generator for each field.
  ///
  /// You can specify:
  ///
  /// [columnName] - Used to map the field to the column name. Defaults to the field name
  /// [ignore] - If true, this field will be ignored by the generator. Defaults to false
  /// [fromDb] - Custom function to decode the object retrieved from the database to the field type.
  ///   Its return type must be the same of the field and of the [toDb] parameter.
  ///   Its parameter type must be the same of the [toDb] return type.
  /// [toDb] - Custom function to encode the field into an object to save in the database.
  ///   Its parameter type must be the same of the field and of the [toDb] return type.
  ///   Its return type must be the same of the [fromDb] parameter type.
  ///
  /// E.g. to generate a query implementation:
  /// ```dart
  /// final int id;
  ///
  /// @QueryableField(columnName: '_id')
  /// final int id2;
  ///
  /// @QueryableField(ignore: true)
  /// final String ignored;
  /// ```
  const QueryableField({this.columnName, this.ignore = false, this.fromDb, this.toDb});
}
