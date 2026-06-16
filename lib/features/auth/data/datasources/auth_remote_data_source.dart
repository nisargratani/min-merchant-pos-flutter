import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for authentication API calls.
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  /// POST /login — returns user data with JWT token.
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'Invalid username or password',
          statusCode: 401,
        );
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Login failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// POST /logout
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (_) {
      // Ignore logout errors — we clear token locally regardless
    }
  }

  /// GET /users/me — returns current user profile.
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to fetch user profile',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
