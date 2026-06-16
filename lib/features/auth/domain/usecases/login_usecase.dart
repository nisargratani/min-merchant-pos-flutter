import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Parameters for [LoginUseCase].
class LoginParams {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});
}

/// Authenticates a user with username and password.
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<User> call(LoginParams params) {
    return _repository.login(params.username, params.password);
  }
}
