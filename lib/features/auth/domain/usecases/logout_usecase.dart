import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Logs out the current user.
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  @override
  Future<void> call(NoParams params) {
    return _repository.logout();
  }
}
