extension IntExtensions on int {
  /// Multiply [this] for [other].
  int iMul(int other) => this * other;

  /// Multiply [this] for [other].
  double mul(double other) => this * other;

  /// Add [other] to [this].
  int iAdd(int other) => this + other;

  /// Add [other] to [this].
  double add(double other) => this + other;

  /// Subtract [other] from [this].
  int iSub(int other) => this - other;

  /// Subtract [other] from [this].
  double sub(double other) => this - other;
}

extension DoubleExtensions on double {
  /// Multiply [this] for [other].
  double mul(num other) => this * other;

  /// Add [other] to [this].
  double add(num other) => this + other;

  /// Subtract [other] from [this].
  double sub(num other) => this - other;
}
