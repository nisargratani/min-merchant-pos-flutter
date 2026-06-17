abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn);
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    return leftFn(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left<L, R> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    return rightFn(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right<L, R> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
