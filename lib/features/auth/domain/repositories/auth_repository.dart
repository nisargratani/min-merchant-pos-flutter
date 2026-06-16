import '../entities/user.dart';

/// Abstract auth repository — domain layer contract.
abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  bool get isAuthenticated;
}
