import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for auth — manages JWT token and cached user info.
class AuthLocalDataSource {
  final SharedPreferences _prefs;

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'cached_user';

  AuthLocalDataSource(this._prefs);

  /// Save JWT token securely.
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Get stored JWT token.
  String? getToken() => _prefs.getString(_tokenKey);

  /// Check if a token is stored.
  bool get hasToken => _prefs.containsKey(_tokenKey);

  /// Clear the stored token.
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
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
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
