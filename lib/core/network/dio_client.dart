import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Provider for SharedPreferences — overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferences must be overridden at startup');
});

/// Provider for the configured Dio instance
final dioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Auth & Logging interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        AppLogger.debug('--> ${options.method} ${options.uri}', tag: 'Dio');
        if (options.data != null) {
          AppLogger.debug('Request Body: ${options.data}', tag: 'Dio');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.debug('<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}', tag: 'Dio');
        AppLogger.debug('Response Body: ${response.data}', tag: 'Dio');
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error('<-- ERROR ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}', tag: 'Dio');
        AppLogger.error('Error Message: ${error.message}', tag: 'Dio');
        if (error.response?.data != null) {
          AppLogger.error('Error Response: ${error.response?.data}', tag: 'Dio');
        }
        if (error.response?.statusCode == 401) {
          prefs.remove('jwt_token');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
