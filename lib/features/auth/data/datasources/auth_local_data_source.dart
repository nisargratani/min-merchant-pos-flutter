import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local data source for auth — manages JWT token and cached user info.
class AuthLocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'cached_user';

  AuthLocalDataSource(this._prefs);

  /// Save JWT token securely.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get stored JWT token.
  Future<String?> getToken() async => await _secureStorage.read(key: _tokenKey);

  /// Check if a token is stored.
  Future<bool> hasToken() async => await _secureStorage.containsKey(key: _tokenKey);

  /// Clear the stored token.
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Cache user JSON for quick access.
  Future<void> cacheUser(Map<String, dynamic> userJson) async {
    await _prefs.setString(_userKey, jsonEncode(userJson));
  }

  /// Get cached user JSON.
  Map<String, dynamic>? getCachedUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Clear all auth data.
  Future<void> clearAll() async {
    await clearToken();
    await _prefs.remove(_userKey);
  }
}
