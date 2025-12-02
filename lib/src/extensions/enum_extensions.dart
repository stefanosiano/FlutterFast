extension EnumIterations<T extends Enum> on Iterable<T> {
  /// Finds the enum value in this list with name [name],
  ///   or [defValue] if no such enum was found.
  T byNameOr(String name, T defValue) {
    for (var value in this) {
      if (value.name == name) return value;
    }
    return defValue;
  }
}
