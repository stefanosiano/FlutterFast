class FastDaoConverterInt<DartType> extends FastDaoConverter<int, DartType> {
  FastDaoConverterInt({required super.fromDb, required super.toDb});
}

class FastDaoConverterReal<DartType> extends FastDaoConverter<double, DartType> {
  FastDaoConverterReal({required super.fromDb, required super.toDb});
}

class FastDaoConverterText<DartType> extends FastDaoConverter<String, DartType> {
  FastDaoConverterText({required super.fromDb, required super.toDb});
}

sealed class FastDaoConverter<ColumnType, ClassType> {
  final Type sqlType;
  final Type dartType;
  final ClassType? Function(ColumnType?) fromDb;
  final ColumnType? Function(ClassType?) toDb;

  const FastDaoConverter({required this.fromDb, required this.toDb})
      : sqlType = ColumnType,
        dartType = ClassType;

  @override
  operator ==(Object other) {
    return other is FastDaoConverter && other.sqlType == sqlType && other.dartType == dartType;
  }

  @override
  int get hashCode => sqlType.hashCode ^ dartType.hashCode;
}
