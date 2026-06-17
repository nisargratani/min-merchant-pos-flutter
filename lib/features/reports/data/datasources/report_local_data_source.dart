import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for caching reports.
class ReportLocalDataSource {
  final SharedPreferences _prefs;

  ReportLocalDataSource(this._prefs);

  static const _todaySalesKey = 'TODAY_SALES_REPORT';

  /// Caches the today sales API response.
  Future<void> saveTodaySales(Map<String, dynamic> data) async {
    await _prefs.setString(_todaySalesKey, jsonEncode(data));
  }

  /// Retrieves the cached today sales data.
  Future<Map<String, dynamic>> getTodaySales() async {
    final jsonString = _prefs.getString(_todaySalesKey);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      throw Exception('No local data available');
    }
  }
}
