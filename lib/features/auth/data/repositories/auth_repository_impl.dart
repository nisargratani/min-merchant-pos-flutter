import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<User> login(String username, String password) async {
    final data = await _remoteDataSource.login(username, password);
    final user = User.fromJson(data);

    // Store token securely
    if (user.token != null) {
      await _localDataSource.saveToken(user.token!);
    }

    // Cache user info
    await _localDataSource.cacheUser(data);

    return user;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!isAuthenticated) return null;

    try {
      final data = await _remoteDataSource.getMe();
      // Add token from local storage since /users/me doesn't return it
      final token = _localDataSource.getToken();
      data['token'] = token;
      final user = User.fromJson(data);
      await _localDataSource.cacheUser(data);
      return user;
    } catch (_) {
      // If API call fails, try cached user
      final cached = _localDataSource.getCachedUser();
      if (cached != null) {
        return User.fromJson(cached);
      }
      // Token might be expired — clear it
      await _localDataSource.clearAll();
      return null;
    }
  }

  @override
  bool get isAuthenticated => _localDataSource.hasToken;
}
