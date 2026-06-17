import '../error/failures.dart';
import '../utils/either.dart';

/// Base use case interface.
/// [Type] is the return type, [Params] is the parameter type.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use when a use case requires no parameters.
class NoParams {
  const NoParams();
}
