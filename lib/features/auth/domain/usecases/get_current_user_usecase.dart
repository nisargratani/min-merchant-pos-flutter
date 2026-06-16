import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Returns the currently authenticated user, or null if not authenticated.
class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<User?> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
